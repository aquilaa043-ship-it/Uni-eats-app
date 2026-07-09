import 'package:flutter/material.dart';
import 'package:uni_eats/features/shared/domain/models/firebase_models.dart';
import '../../data/firebase_auth_service.dart';
import '../../../../core/routes/route_generator.dart';

class UniEatsAuthScreen extends StatefulWidget {
  const UniEatsAuthScreen({Key? key}) : super(key: key);

  @override
  State<UniEatsAuthScreen> createState() => _UniEatsAuthScreenState();
}

class _UniEatsAuthScreenState extends State<UniEatsAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  String _selectedUserType = 'cliente';
  String _selectedCity = 'capital';

  static const Color brandDarkBg = Color(0xFF121212);
  static const Color brandCardBg = Color(0xFF1E1E1E);
  static const Color brandGoldOld = Color(0xFFD4AF37);
  static const Color brandTextLight = Color(0xFFFAF9F6);
  static const Color brandTextMuted = Color(0xFF9E9E9E);
  static const Color brandErrorRed = Color(0xFFD32F2F);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _processarLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final UsuarioModel? usuario = await _authService.loginComEmailESenha(
        email: _emailController.text,
        senha: _senhaController.text,
      );

      if (usuario != null) {
        _mostrarMensagemSucesso("Bem-vindo de volta, ${usuario.nome}!");
        _direcionarUsuarioParaModulo(usuario);
      }
    } catch (e) {
      _mostrarMensagemErro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        _mostrarMensagemSucesso("Conta criada como: ${_converterTipoUsuarioLabel(usuario.tipoUsuario)}!");
        _direcionarUsuarioParaModulo(usuario);
      }
    } catch (e) {
      _mostrarMensagemErro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _direcionarUsuarioParaModulo(UsuarioModel usuario) {
    if (!RouteGuard.verificarAcesso(usuario.tipoUsuario, usuario.statusAssinatura)) {
      _mostrarMensagemErro("Acesso Negado: Sua assinatura está ${_converterStatusLabel(usuario.statusAssinatura)}.");
      _authService.deslogar();
      return;
    }

    switch (usuario.tipoUsuario) {
      case 'cliente':
        Navigator.pushReplacementNamed(context, RouteGenerator.homeCliente);
        break;
      case 'lojista':
        Navigator.pushReplacementNamed(context, RouteGenerator.homeLojista);
        break;
      case 'motoboy':
        Navigator.pushReplacementNamed(context, RouteGenerator.homeMotoboy);
        break;
      case 'super_admin':
        Navigator.pushReplacementNamed(context, RouteGenerator.superAdmin);
        break;
      default:
        _mostrarMensagemErro("Perfil inválido na base de dados.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandDarkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: brandCardBg,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: brandGoldOld.withOpacity(0.18), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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

                      if (_isRegisterMode) ...[
                        _buildInputField(
                          controller: _nomeController,
                          label: "NOME COMPLETO OU DA MARCA",
                          icon: Icons.person_outline,
                          validator: (val) => val == null || val.trim().isEmpty ? "Insira seu nome completo" : null,
                        ),
                        const SizedBox(height: 16),
                      ],

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

                      if (_isRegisterMode) ...[
                        _buildInputField(
                          controller: _telefoneController,
                          label: "TELEFONE PARA CONTATO",
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val == null || val.trim().isEmpty ? "Insira seu telefone" : null,
                        ),
                        const SizedBox(height: 16),

                        _buildSectionHeader("FUNÇÃO NO ECOSSISTEMA"),
                        const SizedBox(height: 8),
                        _buildUserTypeSelector(),
                        const SizedBox(height: 16),

                        _buildSectionHeader("CIDADE DA OPERAÇÃO"),
                        const SizedBox(height: 8),
                        _buildCitySelector(),
                        const SizedBox(height: 24),
                      ],

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
                              ),
                              onPressed: _isRegisterMode ? _processarRegistro : _processarLogin,
                              child: Text(
                                _isRegisterMode ? "CADASTRAR E CONECTAR" : "ENTRAR NO ECOSSISTEMA",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.1),
                              ),
                            ),
                      const SizedBox(height: 24),

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

                      const Divider(color: Color(0xFF333333), height: 32),
                      
                      const Text(
                        "AMBIENTE DE TESTE / DEMONSTRAÇÃO",
                        style: TextStyle(
                          color: brandTextMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF121212),
                          foregroundColor: brandGoldOld,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: brandGoldOld.withOpacity(0.4), width: 1.2),
                          ),
                        ),
                        onPressed: () => _mostrarSeletorDemo(),
                        icon: const Icon(Icons.bolt_rounded, size: 20),
                        label: const Text(
                          "ENTRAR SEM FIREBASE (MODO DEMO)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0),
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

  void _mostrarSeletorDemo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: brandCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SELECIONE O MÓDULO DEMO",
                    style: TextStyle(
                      color: brandTextLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: brandTextMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Experimente os recursos premium offline do UniEats e do motor de liquidação UniLink imediatamente.",
                style: TextStyle(color: brandTextMuted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              _buildDemoRoleItem(
                title: "Cliente Parceiro",
                description: "Carrinho de compras, deep link e checkout integrado",
                icon: Icons.shopping_bag_outlined,
                onTap: () {
                  Navigator.pop(context);
                  _entrarComoDemo('cliente');
                },
              ),
              const SizedBox(height: 12),
              _buildDemoRoleItem(
                title: "Lojista / Restaurante",
                description: "Gerenciamento de cardápio e extrato financeiro",
                icon: Icons.storefront_outlined,
                onTap: () {
                  Navigator.pop(context);
                  _entrarComoDemo('lojista');
                },
              ),
              const SizedBox(height: 12),
              _buildDemoRoleItem(
                title: "Entregador / Motoboy",
                description: "Roteiro de entregas, rotas no mapa e carteira",
                icon: Icons.motorcycle_outlined,
                onTap: () {
                  Navigator.pop(context);
                  _entrarComoDemo('motoboy');
                },
              ),
              const SizedBox(height: 12),
              _buildDemoRoleItem(
                title: "Super Administrador",
                description: "Monitoramento de todas as carteiras e rotas",
                icon: Icons.admin_panel_settings_outlined,
                onTap: () {
                  Navigator.pop(context);
                  _entrarComoDemo('super_admin');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDemoRoleItem({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: brandDarkBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandGoldOld.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: brandGoldOld.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: brandGoldOld, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: brandTextLight, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: brandTextMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: brandGoldOld, size: 14),
          ],
        ),
      ),
    );
  }

  void _entrarComoDemo(String tipoUsuario) {
    final UsuarioModel mockUser = UsuarioModel(
      id: "usr_mock_${tipoUsuario}_123",
      nome: "Demonstração: ${tipoUsuario.toUpperCase()}",
      email: "demo@unieats.com",
      tipoUsuario: tipoUsuario,
      telefone: "(11) 99999-9999",
      cidade: "capital",
      statusAssinatura: "ativo",
      criadoEm: DateTime.now(),
    );

    _authService.definirUsuarioMock(mockUser);
    _mostrarMensagemSucesso("Logado em Modo Demo como: ${_converterTipoUsuarioLabel(tipoUsuario)}");
    _direcionarUsuarioParaModulo(mockUser);
  }

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

class RouteGuard {
  static const Map<String, List<String>> _roleRoutes = {
    'cliente': ['/checkout', '/historico_pedidos', '/acompanhamento'],
    'lojista': ['/extrato_loja', '/configuracoes_loja', '/cardapio'],
    'motoboy': ['/rotas_logistica', '/carteira_motoboy', '/gps_rastreamento'],
    'super_admin': ['/checkout', '/extrato_loja', '/rotas_logistica', '/super_painel_admin'],
  };

  static bool podeAcessarRota({
    required String tipoUsuario,
    required String rotaDesejada,
    required String statusAssinatura,
  }) {
    if (statusAssinatura == 'suspenso' || statusAssinatura == 'inativo') {
      return false;
    }

    if (tipoUsuario == 'super_admin') return true;

    final List<String>? rotasPermitidas = _roleRoutes[tipoUsuario];
    if (rotasPermitidas == null) return false;

    return rotasPermitidas.contains(rotaDesejada);
  }

  static bool verificarAcesso(String tipoUsuario, String statusAssinatura) {
    if (statusAssinatura == 'suspenso' || statusAssinatura == 'inativo') {
      return false;
    }
    return true;
  }
}
