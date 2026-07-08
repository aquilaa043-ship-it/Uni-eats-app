import 'package:flutter/material.dart';

// ============================================================================
// CONFIGURAÇÕES DO LOJISTA - ECOSSISTEMA UNI EATS
// ============================================================================
// Visual: Elitizado, minimalista e de alto luxo (Tons de grafite, ouro e off-white).
// Desenvolvido por: Engenheiro de Software Full Stack Sênior & UI/UX Designer.
// ============================================================================

void main() {
  runApp(const MaterialApp(
    home: MerchantSettingsScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class MerchantSettingsScreen extends StatefulWidget {
  const MerchantSettingsScreen({Key? key}) : super(key: key);

  @override
  State<MerchantSettingsScreen> createState() => _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  // --------------------------------------------------------------------------
  // CONTROLLERS & ESTADOS (Seção 1: Perfil do Estabelecimento)
  // --------------------------------------------------------------------------
  final TextEditingController _restaurantNameController =
      TextEditingController(text: "UniEats Gourmet");
  final TextEditingController _phoneController =
      TextEditingController(text: "(11) 98765-4321");
  final TextEditingController _specialtyController =
      TextEditingController(text: "Alta Gastronomia Contemporânea");
  final TextEditingController _prepTimeController =
      TextEditingController(text: "25-35 min");

  // --------------------------------------------------------------------------
  // ESTADOS (Seção 2: Modelo de Logística e Entrega)
  // --------------------------------------------------------------------------
  // "proprio" -> Utilizar Entregadores Próprios (Fixo da Loja)
  // "unieats" -> Utilizar Rede de Motoboys Uni eats (GPS em tempo real)
  String _selectedLogistics = "unieats";

  // --------------------------------------------------------------------------
  // ESTADOS (Seção 3: Integração Financeira Mercado Pago)
  // --------------------------------------------------------------------------
  bool _mpConnected = false;
  bool _mpConnecting = false;

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

  // Simulação de conexão com o SDK do Mercado Pago
  void _toggleMercadoPagoConnection() async {
    if (_mpConnected) {
      // Fluxo de desconexão
      setState(() {
        _mpConnected = false;
      });
      _showPremiumSnackbar(
        "🔌 Conta Mercado Pago desconectada com sucesso.",
        isSuccess: false,
      );
    } else {
      // Fluxo de conexão simulada
      setState(() {
        _mpConnecting = true;
      });

      // Simula o tempo de resposta do handshake OAuth2 / Split do Mercado Pago
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _mpConnecting = false;
        _mpConnected = true;
      });

      _showPremiumSnackbar(
        "✓ Conta Mercado Pago integrada com split de pagamentos! (aquilaa043@gmail.com)",
        isSuccess: true,
      );
    }
  }

  // Salvar as configurações gerais da loja
  void _saveAllSettings() {
    if (_restaurantNameController.text.trim().isEmpty) {
      _showPremiumSnackbar("❌ O nome do restaurante não pode ficar vazio.", isSuccess: false);
      return;
    }
    
    _showPremiumSnackbar(
      "✨ Todas as configurações do lojista foram salvas e publicadas com sucesso!",
      isSuccess: true,
    );
  }

  // SnackBar visualmente refinada (Padrão de Design Uni eats)
  void _showPremiumSnackbar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.info_outline,
              color: isSuccess ? const Color(0xFFD4AF37) : Colors.redAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFFAF9F6),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1C1C1C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSuccess ? const Color(0xFFD4AF37).withOpacity(0.4) : Colors.redAccent.withOpacity(0.4),
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Paleta de Cores Premium (Uni eats)
    const Color brandGraphiteDark = Color(0xFF121212); // Base ultra-dark
    const Color brandGraphiteSurface = Color(0xFF1C1C1C); // Cards
    const Color brandGoldOld = Color(0xFFD4AF37); // Ouro Velho Premium
    const Color brandTextLight = Color(0xFFFAF9F6); // Off-White
    const Color brandTextMuted = Color(0xFF71717A); // Cinza Zincado

    return Scaffold(
      backgroundColor: brandGraphiteDark,
      appBar: AppBar(
        title: const Text(
          "Configurações da Loja",
          style: TextStyle(
            color: brandTextLight,
            fontWeight: FontWeight.w300,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: brandGraphiteDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFF2C2C2C),
            height: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // INTRODUÇÃO / SUBTÍTULO
              const Text(
                "PAINEL DE OPERAÇÃO DO PARCEIRO",
                style: TextStyle(
                  color: brandGoldOld,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Gerencie a identidade gastronômica do seu estabelecimento, defina as diretrizes logísticas de entrega e conecte sua conta bancária de forma segura.",
                style: TextStyle(
                  color: brandTextMuted,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // ===============================================================
              // SEÇÃO 1: PERFIL DO ESTABELECIMENTO
              // ===============================================================
              _buildSectionCard(
                title: "Perfil do Estabelecimento",
                icon: Icons.storefront_outlined,
                goldColor: brandGoldOld,
                surfaceColor: brandGraphiteSurface,
                textColor: brandTextLight,
                children: [
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _restaurantNameController,
                    label: "Nome do Restaurante",
                    placeholder: "Ex: Famiglia Du Nord",
                    goldColor: brandGoldOld,
                    mutedColor: brandTextMuted,
                    textColor: brandTextLight,
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _phoneController,
                    label: "Telefone de Atendimento",
                    placeholder: "(11) 99999-9999",
                    keyboardType: TextInputType.phone,
                    goldColor: brandGoldOld,
                    mutedColor: brandTextMuted,
                    textColor: brandTextLight,
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _specialtyController,
                    label: "Especialidade / Tipo de Culinária",
                    placeholder: "Ex: Carnes Nobres, Massas Artesanais",
                    goldColor: brandGoldOld,
                    mutedColor: brandTextMuted,
                    textColor: brandTextLight,
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumTextField(
                    controller: _prepTimeController,
                    label: "Tempo Médio de Preparo",
                    placeholder: "Ex: 30-40 min",
                    goldColor: brandGoldOld,
                    mutedColor: brandTextMuted,
                    textColor: brandTextLight,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ===============================================================
              // SEÇÃO 2: MODELO DE LOGÍSTICA E ENTREGA
              // ===============================================================
              _buildSectionCard(
                title: "Logística & Entrega",
                icon: Icons.local_shipping_outlined,
                goldColor: brandGoldOld,
                surfaceColor: brandGraphiteSurface,
                textColor: brandTextLight,
                children: [
                  const SizedBox(height: 16),
                  // CARD OPTION 1: Entregadores Próprios
                  _buildLogisticsCard(
                    id: "proprio",
                    title: "Utilizar Entregadores Próprios (Fixo da Loja)",
                    description: "Taxa de entrega definida e gerenciada de forma independente pela sua própria equipe interna.",
                    isSelected: _selectedLogistics == "proprio",
                    goldColor: brandGoldOld,
                    textColor: brandTextLight,
                    mutedColor: brandTextMuted,
                    onTap: () {
                      setState(() {
                        _selectedLogistics = "proprio";
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // CARD OPTION 2: Rede UniEats
                  _buildLogisticsCard(
                    id: "unieats",
                    title: "Utilizar Rede de Motoboys Uni eats",
                    description: "Conexão com nossa frota compartilhada de alta performance e rastreamento dinâmico via GPS em tempo real.",
                    isSelected: _selectedLogistics == "unieats",
                    goldColor: brandGoldOld,
                    textColor: brandTextLight,
                    mutedColor: brandTextMuted,
                    onTap: () {
                      setState(() {
                        _selectedLogistics = "unieats";
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ===============================================================
              // SEÇÃO 3: INTEGRAÇÃO FINANCEIRA MERCADO PAGO
              // ===============================================================
              _buildSectionCard(
                title: "Gateway de Split de Pagamento",
                icon: Icons.account_balance_wallet_outlined,
                goldColor: brandGoldOld,
                surfaceColor: brandGraphiteSurface,
                textColor: brandTextLight,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: brandGoldOld.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: BorderSide(
                        color: brandGoldOld.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Mercado Pago Gateway",
                              style: TextStyle(
                                color: brandTextLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            // INDICADOR DE STATUS DISCRETO
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _mpConnected
                                    ? const Color(0xFF2E7D32).withOpacity(0.15)
                                    : brandTextMuted.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: BorderSide(
                                  color: _mpConnected
                                      ? const Color(0xFF81C784)
                                      : brandTextMuted.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                _mpConnected ? "Status: Conectado" : "Status: Não Conectado",
                                style: TextStyle(
                                  color: _mpConnected
                                      ? const Color(0xFF81C784)
                                      : brandTextMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _mpConnected
                              ? "✓ Conta integrada: aquilaa043@gmail.com\nRepasses de valores liquidados direto em conta via split automatizado."
                              : "Conecte sua conta Mercado Pago para receber depósitos diretos de transações de clientes sem complicação.",
                          style: const TextStyle(
                            color: brandTextMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // BOTÃO DE CONEXÃO PREMIUM ADAPTADO
                        if (_mpConnecting)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: brandGoldOld,
                                  strokeWidth = 2,
                                ),
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _mpConnected
                                  ? const Color(0xFFEF5350).withOpacity(0.1)
                                  : const Color(0xFF009EE3), // Azul MP adaptado de forma premium
                              foregroundColor: _mpConnected ? const Color(0xFFEF5350) : Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: _mpConnected
                                    ? const BorderSide(color: Color(0xFFEF5350), width: 1)
                                    : BorderSide.none,
                              ),
                            ),
                            onPressed: _toggleMercadoPagoConnection,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!_mpConnected) ...[
                                  const Icon(Icons.security, size: 16),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  _mpConnected
                                      ? "DESCONECTAR MINHA CONTA"
                                      : "CONECTAR MINHA CONTA MERCADO PAGO",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // NOTA INFORMATIVA SUTIL NO RODAPÉ
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Taxa da plataforma: R\$ 0,80 retidos por transação de forma automatizada via Split de Pagamento",
                      style: TextStyle(
                        color: brandTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ===============================================================
              // BOTÃO PRINCIPAL DE SALVAR CONFIGURAÇÕES
              // ===============================================================
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGoldOld,
                  foregroundColor: brandGraphiteDark,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                  shadowColor: brandGoldOld.withOpacity(0.1),
                ),
                onPressed: _saveAllSettings,
                child: const Text(
                  "SALVAR CONFIGURAÇÕES",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // WIDGET HELPERS (UI/UX)
  // --------------------------------------------------------------------------

  // Builder para cards de seção com bordas finas e cantos arredondados suaves
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color goldColor,
    required Color surfaceColor,
    required Color textColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: BorderSide(
          color: goldColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: goldColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  // Builder para Campos de Texto Elitizados
  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    required Color goldColor,
    required Color mutedColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: mutedColor,
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: mutedColor.withOpacity(0.5),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFF222222).withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF2C2C2C),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: goldColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Card customizado para escolha de logística
  Widget _buildLogisticsCard({
    required String id,
    required String title,
    required String description,
    required bool isSelected,
    required Color goldColor,
    required Color textColor,
    required Color mutedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? goldColor.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: BorderSide(
            color: isSelected ? goldColor : const Color(0xFF2C2C2C),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Radio Icon Indicator
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? goldColor : mutedColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? goldColor : textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
