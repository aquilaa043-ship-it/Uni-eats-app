/// ====================================================================
/// UNI EATS - SERVIÇO DE AUTENTICAÇÃO INTEGRADO (FIREBASE AUTH & FIRESTORE)
/// ====================================================================
/// Este arquivo implementa a arquitetura de autenticação e controle de acesso
/// do ecossistema "Uni Eats" utilizando Firebase Auth e Cloud Firestore.
///
/// Como arquitetado, cada usuário é registrado no Firebase Auth (autenticação segura)
/// e seu perfil estendido (papel/tipo_usuario, telefone, cidade, status_assinatura)
/// é persistido na coleção NoSQL `/usuarios` para permitir que nossas telas de 
/// Checkout, Extrato do Lojista, Painel do Motoboy e Super Admin ajam com base no
/// perfil autenticado.
///
/// Requisitos técnicos atendidos:
/// - Registro modular de usuários com definição explícita do Tipo de Usuário.
/// - Login unificado com verificação de perfil e validação de permissões/status.
/// - Carregamento dinâmico do estado de login atual com persistência de sessão.
/// - Tratamento e tradução didática de erros nativos do Firebase (FirebaseAuthException).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_models.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton pattern para garantir uma única instância em todo o ciclo de vida do app
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  /// Escuta em tempo real o estado de autenticação do usuário.
  /// Útil para roteamento automático de telas no Flutter (Auth Guard).
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();

  /// ====================================================================
  /// 1. MÉTODO DE REGISTRO / CADASTRO DE USUÁRIOS
  /// ====================================================================
  /// Cria um usuário no Firebase Auth e insere o perfil correspondente
  /// no Firestore com as regras de negócio de cada perfil.
  Future<UsuarioModel?> registrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String tipoUsuario, // "cliente" | "lojista" | "motoboy" | "super_admin"
    required String telefone,
    required String cidade,      // "capital" | "interior" (Afeta cálculos de taxa)
  }) async {
    try {
      // 1. Criar credencial de autenticação segura no Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Falha ao obter o usuário recém-criado do Firebase Auth.',
        );
      }

      // 2. Atualizar o nome de exibição no Firebase Auth Core para redundância segura
      await firebaseUser.updateDisplayName(nome);

      // 3. Definir regras administrativas iniciais padrão baseadas no Tipo de Usuário
      // - Lojistas iniciam com assinatura "ativo" para testes rápidos, mas controlados por Admin.
      // - Clientes não precisam de assinatura ("ativo" por padrão para uso geral).
      // - Motoboys têm o status livre.
      String statusInicial = "ativo";
      if (tipoUsuario == "lojista") {
        statusInicial = "ativo"; // Pode ser "pendente_aprovacao" em produção real
      }

      // 4. Instanciar o modelo de usuário estendido usando nossa biblioteca de modelos
      final UsuarioModel novoUsuario = UsuarioModel(
        id: firebaseUser.uid, // O ID do documento é EXATAMENTE o uid do Firebase Auth
        nome: nome.trim(),
        email: email.trim().toLowerCase(),
        tipoUsuario: tipoUsuario,
        telefone: telefone.trim(),
        cidade: cidade,
        statusAssinatura: statusInicial,
        criadoEm: DateTime.now(),
      );

      // 5. Salvar o perfil na coleção NoSQL '/usuarios' no Firestore
      await _db.collection('usuarios').doc(firebaseUser.uid).set(novoUsuario.toMap());

      // 6. Se o usuário for do tipo "lojista", já criamos a estrutura do restaurante inicial
      if (tipoUsuario == "lojista") {
        await _criarRestaurantePadraoParaLojista(firebaseUser.uid, nome, cidade);
      }

      return novoUsuario;
    } on FirebaseAuthException catch (e) {
      _tratarExceptionAuth(e);
      rethrow;
    } catch (e) {
      throw Exception('Erro inesperado no servidor durante o registro: $e');
    }
  }

  /// ====================================================================
  /// 2. MÉTODO DE LOGIN UNIFICADO
  /// ====================================================================
  /// Realiza o login com e-mail e senha, valida a existência do documento
  /// no Firestore e retorna o perfil completo para controle de rotas de telas.
  Future<UsuarioModel?> loginComEmailESenha({
    required String email,
    required String senha,
  }) async {
    try {
      // 1. Autenticar no Firebase Auth
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      // 2. Buscar o perfil correspondente na coleção NoSQL '/usuarios'
      final DocumentSnapshot doc = await _db.collection('usuarios').doc(firebaseUser.uid).get();

      if (!doc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found-firestore',
          message: 'Conta de autenticação existe, mas o perfil do banco NoSQL não foi encontrado.',
        );
      }

      // 3. Converter os dados brutos obtidos no snapshot em nosso modelo tipado
      final UsuarioModel usuario = UsuarioModel.fromMap(doc.data() as Map<String, dynamic>);

      // 4. Validação de bloqueio de segurança administrado pelo Painel do Super Admin
      if (usuario.statusAssinatura == "suspenso" || usuario.statusAssinatura == "inativo") {
        await _auth.signOut(); // Desloga imediatamente se a conta estiver restrita
        throw FirebaseAuthException(
          code: 'user-disabled-by-admin',
          message: 'Sua conta está suspensa ou inativa. Entre em contato com o suporte do Uni Eats.',
        );
      }

      return usuario;
    } on FirebaseAuthException catch (e) {
      _tratarExceptionAuth(e);
      rethrow;
    } catch (e) {
      throw Exception('Erro inesperado ao realizar login: $e');
    }
  }

  /// ====================================================================
  /// 3. CARREGAR PERFIL DO USUÁRIO ATUAL (SESSÃO ATIVA)
  /// ====================================================================
  /// Útil para o início da aplicação (Splash Screen) para verificar se o
  /// usuário já está logado, pulando a tela de login se a sessão for válida.
  Future<UsuarioModel?> obterUsuarioAtual() async {
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final DocumentSnapshot doc = await _db.collection('usuarios').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;

      return UsuarioModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      // Falha silenciosa para fluxo de inicialização não quebrar
      return null;
    }
  }

  /// ====================================================================
  /// 4. RECUPERAÇÃO DE SENHA (ESQUECI MINHA SENHA)
  /// ====================================================================
  /// Envia um e-mail de redefinição de senha seguro gerenciado pelo Firebase.
  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      _tratarExceptionAuth(e);
      rethrow;
    } catch (e) {
      throw Exception('Erro ao enviar e-mail de recuperação: $e');
    }
  }

  /// ====================================================================
  /// 5. ENCERRAMENTO DE SESSÃO (LOGOUT / SAIR)
  /// ====================================================================
  Future<void> deslogar() async {
    await _auth.signOut();
  }

  /// ====================================================================
  /// MÉTODOS AUXILIARES PRIVADOS
  /// ====================================================================

  /// Cria uma instância básica de restaurante na coleção `/restaurantes`
  /// vinculada ao ID do lojista criado para integrar com o `ExtratoLojistaModule`.
  Future<void> _criarRestaurantePadraoParaLojista(String lojistaId, String nomeLojista, String cidade) async {
    final String restauranteId = 'rest_$lojistaId';
    
    final RestauranteModel novoRestaurante = RestauranteModel(
      id: restauranteId,
      nomeLugar: 'Cozinha Gourmet de $nomeLojista',
      tipoCozinha: 'Culinária Contemporânea / Pratos Finos',
      tempoPreparo: 30,
      cidade: cidade,
      statusConexaoMercadoPago: 'desconectado', // Lojista precisa conectar seu token na tela de configurações
      statusPlano: 'ativo',
      criadoEm: DateTime.now(),
    );

    await _db.collection('restaurantes').doc(restauranteId).set(novoRestaurante.toMap());
  }

  /// Traduz códigos de erro padrão do Firebase Auth para mensagens amigáveis em Português
  void _tratarExceptionAuth(FirebaseAuthException e) {
    String mensagemAmigavel;

    switch (e.code) {
      case 'invalid-email':
        mensagemAmigavel = 'O formato do e-mail inserido é inválido.';
        break;
      case 'user-disabled':
        mensagemAmigavel = 'Esta conta foi desativada no sistema principal.';
        break;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        mensagemAmigavel = 'E-mail ou senha incorretos. Por favor, verifique suas credenciais.';
        break;
      case 'email-already-in-use':
        mensagemAmigavel = 'Este endereço de e-mail já está sendo utilizado por outra conta.';
        break;
      case 'weak-password':
        mensagemAmigavel = 'A senha escolhida é muito fraca. Escolha uma senha de pelo menos 6 caracteres.';
        break;
      case 'operation-not-allowed':
        mensagemAmigavel = 'O login com e-mail e senha não está habilitado no console do Firebase.';
        break;
      case 'user-not-found-firestore':
        mensagemAmigavel = 'Erro de sincronização: perfil de banco de dados NoSQL ausente.';
        break;
      case 'user-disabled-by-admin':
        mensagemAmigavel = e.message ?? 'Acesso negado pela administração central.';
        break;
      default:
        mensagemAmigavel = e.message ?? 'Ocorreu um erro de autenticação desconhecido.';
    }

    // Lança um novo erro com a mensagem amigável que as telas do app podem ler e exibir em snackbars ou diálogos
    throw FirebaseAuthException(
      code: e.code,
      message: mensagemAmigavel,
    );
  }
}
