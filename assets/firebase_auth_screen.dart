import 'package:flutter/material.dart';
import 'firebase_models.dart';
import 'firebase_auth_service.dart';

/// ====================================================================
/// UNI EATS - TELA DE AUTENTICAÇÃO PREMIUM & PROTEÇÃO DE ROTAS (M3)
/// ====================================================================
/// Este módulo implementa a interface de Login e Cadastro do ecossistema "Uni Eats".
/// Adota as diretrizes do Material Design 3, com paleta de cores elitizada (Grafite,
/// Off-White, Ouro Velho), efeitos de desfoque, transições fluidas e segurança
/// de ponta no tratamento e verificação de rotas.
///
/// Principais recursos inclusos:
/// 1. Tela de Login Premium (Campos estilizados com validação estrita).
/// 2. Registro integrado com expansão suave para seleção de tipos de usuário (Cliente, Restaurante, Motoboy).
/// 3. Lógica de Direcionamento (Switch de Rotas reativo após validação do Firestore).
/// 4. Guarda de Rotas (Route Guards) para impedir acessos cruzados não autorizados.

class UniEatsAuthScreen extends StatefulWidget {
  const UniEatsAuthScreen({Key? key}) : super(key: key);

  @override
  State<UniEatsAuthScreen> createState() => _UniEatsAuthScreenState();
}

class _UniEatsAuthScreenState extends State<UniEatsAuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Estados de controle da interface
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Controllers para captura de dados
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  // Campos padrão para o registro extendido do Firestore
  String _selectedUserType = 'cliente'; // 'cliente' | 'lojista' | 'motoboy'
  String _selectedCity = 'capital';    // 'capital' | 'interior'

  // Paleta de Cores Elitizada "Uni Eats"
  static const Color brandDarkBg = Color(0xFF121212);        // Grafite Ultra Escuro (Fundo)
  static const Color brandCardBg = Color(0xFF1E1E1E);        // Grafite Nobre (Cartões)
  static const Color brandGoldOld = Color(0xFFD4AF37);       // Ouro Velho (Destaques e Botões Principais)
  static const Color brandTextLight = Color(0xFFFAF9F6);     // Off-White (Textos Principais)
  static const Color brandTextMuted = Color(0xFF9E9E9E);     // Cinza Sedoso (Subtítulos e Dicas)
  static const Color brandErrorRed = Color(0xFFD32F2F);      // Vermelho Alerta (Avisos de Validação)

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  /// ====================================================================
  /// 1. LÓGICA DE LOGIN COM SWITCH DE ROTAS (SEGURANÇA REATIVA)
  /// ====================================================================
  Future<void> _processarLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Executa login real no Firebase Auth e recupera modelo NoSQL do Firestore
      final UsuarioModel? usuario = await _authService.loginComEmailESenha(
        email: _emailController.text,
        senha: _senhaController.text,
      );

      if (usuario != null) {
        _mostrarMensagemSucesso("Bem-vindo de volta, ${usuario.nome}! Autenticação efetuada com sucesso.");
        
        // 2. Aciona o Switch de Rotas Protegidas baseado no papel estrito do usuário
        _direcionarUsuarioParaModulo(usuario);
      }
    } catch (e) {
      _mostrarMensagemErro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ====================================================================
  /// 2. LÓGICA DE REGISTRO / CADASTRO DE PERFIL
  /// ====================================================================
  Future<void> _processarRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final UsuarioModel? usuario = await _authService.registrarUsuario(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        tipoUsuario: _selectedUserType,
        telefone: _telefoneController.text,
        cidade: _selectedCity,
      );

      if (usuario != null) {
        _mostrarMensagemSucesso("Conta criada com sucesso como: ${_converterTipoUsuarioLabel(usuario.tipoUsuario)}!");
        
        // Direciona imediatamente ao módulo correspondente
        _direcionarUsuarioParaModulo(usuario);
      }
    } catch (e) {
      _mostrarMensagemErro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ====================================================================
  /// 3. SWITCH DE DIRECIONAMENTO DE ROTAS & GUARDA DE SEGURANÇA (GATES)
  /// ====================================================================
  /// Direciona o fluxo do usuário para sua respectiva área restringindo acessos.
  /// No Flutter real, isto se integra com o sistema de navegação (GoRouter, AutoRoute ou Navigator 2.0).
  void _direcionarUsuarioParaModulo(UsuarioModel usuario) {
    if (!RouteGuard.verificarAcesso(usuario.tipoUsuario, usuario.statusAssinatura)) {
      _mostrarMensagemErro("Acesso Negado: Sua assinatura está ${_converterStatusLabel(usuario.statusAssinatura)}.");
      _authService.deslogar();
      return;
    }

    // Navegação contextual baseada no tipo físico de usuário
    switch (usuario.tipoUsuario) {
      case 'cliente':
        _navegarPara('CheckoutSimuladoModule / Home de Pedidos', usuario);
        break;
      case 'lojista':
        _navegarPara('ExtratoLojistaModule / Painel de Vendas', usuario);
        break;
      case 'motoboy':
        _navegarPara('MotoboyDeliveryModule / Painel de Rotas 🏍️', usuario);
        break;
      case 'super_admin':
        _navegarPara('SuperAdminModule / Painel de Controle de Taxas', usuario);
        break;
      default:
        _mostrarMensagemErro("Perfil de usuário inválido detectado na base de dados.");
    }
  }

  /// Simula a ação de troca de tela/módulo
  void _navegarPara(String destino, UsuarioModel usuario) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: brandCardBg,
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: brandGoldOld),
            SizedBox(width: 10),
            Text("Uni Eats Security Guard", style: TextStyle(color: brandTextLight, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Sessão Autenticada de Forma Segura!", style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text("Usuário: ${usuario.nome}", style: const TextStyle(color: brandTextLight)),
            Text("E-mail: ${usuario.email}", style: const TextStyle(color: brandTextMuted, fontSize: 13)),
            Text("Nível de Acesso: ${usuario.tipoUsuario.toUpperCase()}", style: const TextStyle(color: brandGoldOld, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text("Redirecionando de forma estritamente protegida para:\n👉 $destino", style: const TextStyle(color: brandTextLight, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Em um app de produção com rotas estruturadas, faríamos:
              // Navigator.pushReplacementNamed(context, '/${usuario.tipoUsuario}');
            },
            child: const Text("CONECTAR E ENTRAR", style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandDarkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: brandCardBg,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: brandGoldOld.withOpacity(0.18), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logotipo Premium e Elegante do Uni Eats
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: brandDarkBg,
                                shape: BoxShape.circle,
                                border: Border.all(color: brandGoldOld.withOpacity(0.5), width: 1.5),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu_rounded,
                                size: 40,
                                color: brandGoldOld,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "UNI EATS",
                              style: TextStyle(
                                color: brandTextLight,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isRegisterMode
                                  ? "SOLICITAR ENTRADA NO ECOSSISTEMA"
                                  : "AUTENTICAÇÃO DE ACESSO SEGURO",
                              style: const TextStyle(
                                color: brandTextMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Campo: Nome Completo (Apenas no Registro)
                      if (_isRegisterMode) ...[
                        _buildInputField(
                          controller: _nomeController,
                          label: "NOME COMPLETO OU DA MARCA",
                          icon: Icons.person_outline,
                          validator: (val) => val == null || val.trim().isEmpty ? "Insira seu nome completo" : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Campo: E-mail (Sempre ativo)
                      _buildInputField(
                        controller: _emailController,
                        label: "ENDEREÇO DE E-MAIL",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Insira seu e-mail";
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                            return "Insira um formato de e-mail válido";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo: Senha (Sempre ativo)
                      _buildInputField(
                        controller: _senhaController,
                        label: "CHAVE DE ACESSO (SENHA)",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: brandGoldOld.withOpacity(0.7),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Digite sua senha";
                          if (val.length < 6) return "A senha deve conter no mínimo 6 caracteres";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo: Telefone (Apenas no Registro)
                      if (_isRegisterMode) ...[
                        _buildInputField(
                          controller: _telefoneController,
                          label: "TELEFONE PARA CONTATO",
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val == null || val.trim().isEmpty ? "Insira seu telefone" : null,
                        ),
                        const SizedBox(height: 16),

                        // Seleção de Tipo de Usuário (Modo Registro)
                        _buildSectionHeader("FUNÇÃO NO ECOSSISTEMA"),
                        const SizedBox(height: 8),
                        _buildUserTypeSelector(),
                        const SizedBox(height: 16),

                        // Seleção de Cidade para Regras de Negócio de Frete e Repasse
                        _buildSectionHeader("CIDADE DA OPERAÇÃO"),
                        const SizedBox(height: 8),
                        _buildCitySelector(),
                        const SizedBox(height: 24),
                      ],

                      // Botão de Ação Principal (Login ou Registro)
                      _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: CircularProgressIndicator(color: brandGoldOld),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandGoldOld,
                                foregroundColor: brandDarkBg,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              onPressed: _isRegisterMode ? _processarRegistro : _processarLogin,
                              child: Text(
                                _isRegisterMode ? "CADASTRAR E CONECTAR" : "ENTRAR NO ECOSSISTEMA",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.1),
                              ),
                            ),
                      const SizedBox(height: 24),

                      // Botão para Alternar entre Login e Cadastro
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          _isRegisterMode
                              ? "Já possui uma credencial? Faça login"
                              : "Não tem uma conta? Crie uma agora",
                          style: const TextStyle(color: brandGoldOld, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construtor modular de campos de entrada estilizados para a UI Premium
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: brandTextMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: brandTextLight, fontSize: 14),
          cursorColor: brandGoldOld,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: brandGoldOld.withOpacity(0.7), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: brandDarkBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: brandGoldOld.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: brandGoldOld, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: brandErrorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: brandErrorRed, width: 1.5),
            ),
            errorStyle: const TextStyle(color: brandErrorRed, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(color: brandTextMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
    );
  }

  /// Seletor de Tipo de Usuário (Modo Registro)
  Widget _buildUserTypeSelector() {
    final List<Map<String, dynamic>> types = [
      {'value': 'cliente', 'label': 'Cliente', 'icon': Icons.shopping_bag_outlined},
      {'value': 'lojista', 'label': 'Lojista', 'icon': Icons.storefront_outlined},
      {'value': 'motoboy', 'label': 'Motoboy', 'icon': Icons.motorcycle_outlined},
    ];

    return Row(
      children: types.map((type) {
        final bool isSelected = _selectedUserType == type['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedUserType = type['value']),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? brandGoldOld.withOpacity(0.15) : brandDarkBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? brandGoldOld : brandGoldOld.withOpacity(0.15),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(type['icon'], color: isSelected ? brandGoldOld : brandTextMuted, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    type['label'],
                    style: TextStyle(
                      color: isSelected ? brandTextLight : brandTextMuted,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Seletor de Cidade para as regras de negócio de taxas
  Widget _buildCitySelector() {
    final List<Map<String, String>> cities = [
      {'value': 'capital', 'label': 'Capital (Frete R\$ 3 / Repasse R\$ 6)'},
      {'value': 'interior', 'label': 'Interior (Frete R\$ 2 / Repasse R\$ 4)'},
    ];

    return Column(
      children: cities.map((city) {
        final bool isSelected = _selectedCity == city['value'];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: brandDarkBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? brandGoldOld : brandGoldOld.withOpacity(0.15),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: RadioListTile<String>(
            title: Text(
              city['label']!,
              style: TextStyle(
                color: isSelected ? brandTextLight : brandTextMuted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            value: city['value']!,
            groupValue: _selectedCity,
            activeColor: brandGoldOld,
            onChanged: (val) {
              if (val != null) setState(() => _selectedCity = val);
            },
          ),
        );
      }).toList(),
    );
  }

  // Auxiliares de Tradução Visual
  String _converterTipoUsuarioLabel(String tipo) {
    switch (tipo) {
      case 'cliente': return 'Cliente Parceiro';
      case 'lojista': return 'Restaurante/Lojista';
      case 'motoboy': return 'Entregador/Motoboy';
      case 'super_admin': return 'Super Admin do Sistema';
      default: return tipo;
    }
  }

  String _converterStatusLabel(String status) {
    switch (status) {
      case 'suspenso': return 'SUSPENSA por inconformidade';
      case 'inativo': return 'INATIVA ou aguardando pagamento';
      default: return status;
    }
  }

  void _mostrarMensagemSucesso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _mostrarMensagemErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: brandErrorRed,
      ),
    );
  }
}

/// ====================================================================
/// 4. ROUTE GUARD (MECANISMO DE PROTEÇÃO DE ROTAS SEGURO)
/// ====================================================================
/// Abstração de segurança que previne que usuários de nível inferior 
/// acessem telas administrativas ou modifiquem estados de terceiros.
class RouteGuard {
  /// Lista de permissões e rotas autorizadas
  static const Map<String, List<String>> _roleRoutes = {
    'cliente': ['/checkout', '/historico_pedidos', '/acompanhamento'],
    'lojista': ['/extrato_loja', '/configuracoes_loja', '/cardapio'],
    'motoboy': ['/rotas_logistica', '/carteira_motoboy', '/gps_rastreamento'],
    'super_admin': ['/checkout', '/extrato_loja', '/rotas_logistica', '/super_painel_admin'],
  };

  /// Valida se o usuário autenticado tem permissão para navegar até o módulo/rota solicitado
  static bool podeAcessarRota({
    required String tipoUsuario,
    required String rotaDesejada,
    required String statusAssinatura,
  }) {
    // 1. Verificação de trava administrativa (assinatura inadimplente ou suspensa)
    if (statusAssinatura == 'suspenso' || statusAssinatura == 'inativo') {
      return false; // Trava imediata de acesso a qualquer parte privada do ecossistema
    }

    // 2. Verificação de privilégios de nível (Super Admin possui passe total)
    if (tipoUsuario == 'super_admin') return true;

    // 3. Verificação de rotas permitidas para o respectivo perfil
    final List<String>? rotasPermitidas = _roleRoutes[tipoUsuario];
    if (rotasPermitidas == null) return false;

    return rotasPermitidas.contains(rotaDesejada);
  }

  /// Função simplificada usada no fluxo de login para validação direta de status do banco
  static bool verificarAcesso(String tipoUsuario, String statusAssinatura) {
    if (statusAssinatura == 'suspenso' || statusAssinatura == 'inativo') {
      return false;
    }
    return true;
  }
}
