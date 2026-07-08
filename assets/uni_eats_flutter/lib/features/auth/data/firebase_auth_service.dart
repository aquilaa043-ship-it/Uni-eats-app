import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/domain/models/firebase_models.dart';

/// ====================================================================
/// UNI EATS - SERVIÇO DE AUTENTICAÇÃO INTEGRADO (FIREBASE AUTH & FIRESTORE)
/// ====================================================================
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UsuarioModel? _mockUser;

  // Singleton pattern para garantir uma única instância em todo o ciclo de vida do app
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  /// Define um usuário simulado para fins de teste/demo offline no emulador
  void definirUsuarioMock(UsuarioModel? usuario) {
    _mockUser = usuario;
  }

  /// Escuta em tempo real o estado de autenticação do usuário.
  /// Útil para roteamento automático de telas no Flutter (Auth Guard).
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();

  /// ====================================================================
  /// 1. MÉTODO DE REGISTRO / CADASTRO DE USUÁRIOS
  /// ====================================================================
  Future<UsuarioModel?> registrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String tipoUsuario, // "cliente" | "lojista" | "motoboy" | "super_admin"
    required String telefone,
    required String cidade,      // "capital" | "interior"
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

      // 3. Definir status padrão inicial como "ativo"
      String statusInicial = "ativo";

      // 4. Instanciar o modelo de usuário estendido
      final UsuarioModel novoUsuario = UsuarioModel(
        id: firebaseUser.uid, // O ID do documento é o uid do Firebase Auth
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

      // 3. Converter dados obtidos no snapshot em nosso modelo tipado
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
  Future<UsuarioModel?> obterUsuarioAtual() async {
    if (_mockUser != null) return _mockUser;
    try {
      final User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final DocumentSnapshot doc = await _db.collection('usuarios').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;

      return UsuarioModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// ====================================================================
  /// 4. RECUPERAÇÃO DE SENHA (ESQUECI MINHA SENHA)
  /// ====================================================================
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
  Future<void> _criarRestaurantePadraoParaLojista(String lojistaId, String nomeLojista, String cidade) async {
    final String restauranteId = 'rest_$lojistaId';
    
    final RestauranteModel novoRestaurante = RestauranteModel(
      id: restauranteId,
      nomeLugar: 'Cozinha Gourmet de $nomeLojista',
      tipoCozinha: 'Culinária Contemporânea / Pratos Finos',
      tempoPreparo: 30,
      cidade: cidade,
      statusConexaoMercadoPago: 'desconectado',
      statusPlano: 'ativo',
      criadoEm: DateTime.now(),
    );

    await _db.collection('restaurantes').doc(restauranteId).set(novoRestaurante.toMap());
  }

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

    throw FirebaseAuthException(
      code: e.code,
      message: messageAmigavel,
    );
  }
}
