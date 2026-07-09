import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ============================================================================
// SISTEMA DE ENTREGAS, CHECKOUT SIMULADO & SUPER ADMIN - ECOSSISTEMA UNI EATS
// ============================================================================
// Módulo 1: Checkout Simulado (Sacola do Cliente com Trava de Segurança)
// Módulo 2: Painel do Motoboy (Corrida, Rastreamento GPS Simulado & Ganho Dinâmico)
// Módulo 3: Painel Super Admin (Planos, Split Financeiro Transparente & Gestão de Cidades)
// Visual: Premium, elitizado, minimalista com tons sóbrios (grafite, ouro velho)
// ============================================================================

void main() {
  runApp(const MaterialApp(
    home: UniEatsControlHub(),
    debugShowCheckedModeBanner: false,
  ));
}

/// Enum para definir o porte da cidade do estabelecimento
enum TipoCidade { interior, capital }

/// Modelo de Venda Simulada para o Extrato do Lojista
class SimulatedSale {
  final String orderId;
  final double orderValue;
  final DateTime date;
  final TipoCidade cityType;

  SimulatedSale({
    required this.orderId,
    required this.orderValue,
    required this.date,
    required this.cityType,
  });
}

/// Modelo de Rota Concluída para a Carteira do Motoboy
class CompletedRoute {
  final String name;
  final int addressesCount;
  final double earnings;
  final DateTime date;
  final String status;

  CompletedRoute({
    required this.name,
    required this.addressesCount,
    required this.earnings,
    required this.date,
    required this.status,
  });
}

/// Motor de Cálculo de Logística e Cobrança do Uni eats
class CalculadoraLogisticaService {
  /// Taxa total fixa por endereço cobrada pela logística
  static double calcularTaxaPorEndereco(TipoCidade tipo) {
    return tipo == TipoCidade.interior ? 4.00 : 6.00;
  }

  /// Parcela cobrada do cliente no checkout
  static double calcularParcelaCliente(TipoCidade tipo) {
    return tipo == TipoCidade.interior ? 2.00 : 3.00;
  }

  /// Parcela deduzida do restaurante parceiro
  static double calcularParcelaRestaurante(TipoCidade tipo) {
    return tipo == TipoCidade.interior ? 2.00 : 3.00;
  }

  /// Trava de Segurança contra Prejuízo: Impede entregas para pedidos < R$ 15,00
  static bool verificarElegibilidadeEntrega(double subtotal) {
    return subtotal >= 15.00;
  }
}

/// Tela Hub que unifica os 5 módulos do ecossistema Uni eats
class UniEatsControlHub extends StatefulWidget {
  final int initialModule;
  const UniEatsControlHub({Key? key, this.initialModule = 0}) : super(key: key);

  @override
  State<UniEatsControlHub> createState() => _UniEatsControlHubState();
}

class _UniEatsControlHubState extends State<UniEatsControlHub> {
  late int _currentModuleIndex;

  @override
  void initState() {
    super.initState();
    _currentModuleIndex = widget.initialModule;
  }

  // Estados Globais Sincronizados
  TipoCidade _selectedCityType = TipoCidade.capital;
  double _cartSubtotal = 115.00; // Valor inicial simulado (Wagyu Truffle Burger)
  String _deliveryMethod = "motoboy"; // "motoboy" ou "retirada"
  bool _orderPlacedSuccessfully = false;

  // Estados Globais de Simulação de Corrida / Rastreamento GPS Sincronizados
  String _deliveryState = "idle"; // "idle", "offered", "accepted"
  int _journeyStep = 1; // 1 = Retirada, 2 = Preparo, 3 = Rota Cliente, 4 = Entregue
  double _simulationProgress = 0.0;

  // Estatísticas de Faturamento do Super Admin (atualizadas dinamicamente)
  double _totalAdminCollectedFees = 1240.80;
  int _totalOrdersProcessedCount = 1551;

  // Estados Financeiros (Lojista e Motoboy)
  double _lojistaBalance = 155.00;
  double _motoboyBalance = 48.00;

  late final List<SimulatedSale> _lojistaSales = [
    SimulatedSale(orderId: "9842", orderValue: 50.00, date: DateTime.now().subtract(const Duration(hours: 1)), cityType: TipoCidade.capital),
    SimulatedSale(orderId: "9839", orderValue: 120.00, date: DateTime.now().subtract(const Duration(hours: 5)), cityType: TipoCidade.interior),
    SimulatedSale(orderId: "9835", orderValue: 85.00, date: DateTime.now().subtract(const Duration(days: 1)), cityType: TipoCidade.capital),
  ];

  late final List<CompletedRoute> _motoboyRoutes = [
    CompletedRoute(name: "Rota Centro-Oeste", addressesCount: 3, earnings: 18.00, date: DateTime.now().subtract(const Duration(hours: 2)), status: "Pago 100%"),
    CompletedRoute(name: "Rota Al. Gabriel", addressesCount: 2, earnings: 12.00, date: DateTime.now().subtract(const Duration(hours: 4)), status: "Pago 100%"),
    CompletedRoute(name: "Rota Jardins", addressesCount: 3, earnings: 18.00, date: DateTime.now().subtract(const Duration(days: 1)), status: "Pago 100%"),
  ];

  // Mock de Dados do Usuário para Simular Trava de Segurança
  final Map<String, dynamic> _currentUser = {
    "name": "Guilherme Prado (Owner)",
    "email": "aquilaa043@gmail.com",
    "isSuperAdmin": true,
  };

  @override
  Widget build(BuildContext context) {
    const Color brandDarkBg = Color(0xFF121212);
    const Color brandGoldOld = Color(0xFFD4AF37);
    const Color brandTextLight = Color(0xFFFAF9F6);

    return Scaffold(
      backgroundColor: brandDarkBg,
      body: IndexedStack(
        index: _currentModuleIndex,
        children: [
          // 0. Sacola & Checkout
          CheckoutSimuladoModule(
            selectedCityType: _selectedCityType,
            onCityTypeChanged: (tipo) {
              setState(() {
                _selectedCityType = tipo;
              });
            },
            cartSubtotal: _cartSubtotal,
            onCartSubtotalChanged: (val) {
              setState(() {
                _cartSubtotal = val;
              });
            },
            deliveryMethod: _deliveryMethod,
            onDeliveryMethodChanged: (method) {
              setState(() {
                _deliveryMethod = method;
              });
            },
            onOrderPlaced: () {
              final double taxaRestaurante = CalculadoraLogisticaService.calcularParcelaRestaurante(_selectedCityType);
              final double netValue = _cartSubtotal - 0.80 - taxaRestaurante;
              setState(() {
                _orderPlacedSuccessfully = true;
                _totalOrdersProcessedCount += 1;
                _totalAdminCollectedFees += taxaRestaurante;

                // Inserção dinâmica no Extrato do Lojista
                _lojistaSales.insert(0, SimulatedSale(
                  orderId: "${9843 + Random().nextInt(1000)}",
                  orderValue: _cartSubtotal,
                  date: DateTime.now(),
                  cityType: _selectedCityType,
                ));
                _lojistaBalance += netValue;

                // Inicializa Estados de Simulação Sincronizados
                _deliveryState = "offered";
                _journeyStep = 1;
                _simulationProgress = 0.0;

                _currentModuleIndex = 1; // Redireciona para o Rastreamento de Pedido (index 1)
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✓ Pedido integrado ao sistema! Nova corrida enviada para os motoboys."),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
          ),
          // 1. Rastreamento (Acompanhamento do Cliente)
          AcompanhamentoPedidoModule(
            deliveryState: _deliveryState,
            journeyStep: _journeyStep,
            simulationProgress: _simulationProgress,
            selectedCityType: _selectedCityType,
            orderPlaced: _orderPlacedSuccessfully,
            cartSubtotal: _cartSubtotal,
            onNavigateToCheckout: () {
              setState(() {
                _currentModuleIndex = 0;
              });
            },
          ),
          // 2. Extrato Lojista (Novo)
          ExtratoLojistaModule(
            balance: _lojistaBalance,
            sales: _lojistaSales,
            selectedCityType: _selectedCityType,
          ),
          // 3. Painel Motoboy (Entregas & GPS)
          MotoboyDeliveryModule(
            selectedCityType: _selectedCityType,
            hasActiveOffer: _orderPlacedSuccessfully,
            onCompleteDelivery: () {
              final double ratePerAddress = CalculadoraLogisticaService.calcularTaxaPorEndereco(_selectedCityType);
              final double routeEarnings = ratePerAddress * 3;
              setState(() {
                _orderPlacedSuccessfully = false;
                _deliveryState = "idle";
                _journeyStep = 4;
                _simulationProgress = 1.0;

                // Inserção dinâmica na Carteira do Motoboy
                _motoboyRoutes.insert(0, CompletedRoute(
                  name: "Rota Checkout Simulado",
                  addressesCount: 3,
                  earnings: routeEarnings,
                  date: DateTime.now(),
                  status: "Pago 100%",
                ));
                _motoboyBalance += routeEarnings;
              });
            },
            onDeliverySimulationUpdate: (state, step, progress) {
              setState(() {
                _deliveryState = state;
                _journeyStep = step;
                _simulationProgress = progress;
              });
            },
          ),
          // 4. Carteira Motoboy (Novo)
          CarteiraMotoboyModule(
            balance: _motoboyBalance,
            routes: _motoboyRoutes,
            selectedCityType: _selectedCityType,
            onRequestWithdrawal: () {
              setState(() {
                _motoboyBalance = 0.00;
              });
            },
          ),
          // 5. Super Admin
          SuperAdminModule(
            user: _currentUser,
            selectedCityType: _selectedCityType,
            onCityTypeChanged: (tipo) {
              setState(() {
                _selectedCityType = tipo;
              });
            },
            totalFees: _totalAdminCollectedFees,
            totalOrders: _totalOrdersProcessedCount,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2C2C2C), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentModuleIndex,
          onTap: (index) {
            setState(() {
              _currentModuleIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1C1C1C),
          selectedItemColor: brandGoldOld,
          unselectedItemColor: const Color(0xFF71717A),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined, size: 20),
              activeIcon: Icon(Icons.shopping_bag, color: brandGoldOld, size: 20),
              label: "Checkout",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined, size: 20),
              activeIcon: Icon(Icons.location_on, color: brandGoldOld, size: 20),
              label: "Rastreio",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined, size: 20),
              activeIcon: Icon(Icons.receipt_long, color: brandGoldOld, size: 20),
              label: "Finanças Loja",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining_outlined, size: 20),
              activeIcon: Icon(Icons.delivery_dining, color: brandGoldOld, size: 20),
              label: "Painel Motoboy",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined, size: 20),
              activeIcon: Icon(Icons.account_balance_wallet, color: brandGoldOld, size: 20),
              label: "Carteira Boy",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined, size: 20),
              activeIcon: Icon(Icons.admin_panel_settings, color: brandGoldOld, size: 20),
              label: "Super Admin",
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MÓDULO 1: CHECKOUT SIMULADO (Sacola do Cliente com Trava de Segurança)
// ============================================================================

class CheckoutSimuladoModule extends StatelessWidget {
  final TipoCidade selectedCityType;
  final ValueChanged<TipoCidade> onCityTypeChanged;
  final double cartSubtotal;
  final ValueChanged<double> onCartSubtotalChanged;
  final String deliveryMethod;
  final ValueChanged<String> onDeliveryMethodChanged;
  final VoidCallback onOrderPlaced;

  const CheckoutSimuladoModule({
    Key? key,
    required this.selectedCityType,
    required this.onCityTypeChanged,
    required this.cartSubtotal,
    required this.onCartSubtotalChanged,
    required this.deliveryMethod,
    required this.onDeliveryMethodChanged,
    required this.onOrderPlaced,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color brandGoldOld = Color(0xFFD4AF37);
    const Color brandGraphiteSurface = Color(0xFF1C1C1C);
    const Color brandTextLight = Color(0xFFFAF9F6);
    const Color brandTextMuted = Color(0xFF71717A);

    // Cálculos de Logística
    final bool elegivelParaEntrega = CalculadoraLogisticaService.verificarElegibilidadeEntrega(cartSubtotal);
    final bool isDeliverySelected = deliveryMethod == "motoboy";
    final bool safetyLockActive = isDeliverySelected && !elegivelParaEntrega;

    final double taxaCliente = isDeliverySelected
        ? CalculadoraLogisticaService.calcularParcelaCliente(selectedCityType)
        : 0.00;

    final double taxaRestaurante = isDeliverySelected
        ? CalculadoraLogisticaService.calcularParcelaRestaurante(selectedCityType)
        : 0.00;

    final double totalFinal = cartSubtotal + taxaCliente;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Checkout Uni eats",
              style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.w300, fontSize: 18, letterSpacing: 1),
            ),
            Text(
              "SIMULADOR DE CHECKOUT DO CLIENTE",
              style: TextStyle(color: brandTextMuted, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD 1: SELETOR DE PREÇO DO CARRINHO (SIMULAÇÃO)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandGraphiteSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, color: brandGoldOld, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Simulador de Valor da Sacola",
                        style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Arraste para alterar o subtotal e testar a Trava de Segurança contra Prejuízo (mínimo de R\$ 15,00 para entrega).",
                    style: TextStyle(color: brandTextMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal do Carrinho:",
                        style: TextStyle(color: brandTextLight.withOpacity(0.8), fontSize: 12),
                      ),
                      Text(
                        "R\$ ${cartSubtotal.toStringAsFixed(2)}",
                        style: const TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  Slider(
                    value: cartSubtotal,
                    min: 5.0,
                    max: 200.0,
                    divisions: 39,
                    activeColor: cartSubtotal < 15.00 ? Colors.redAccent : brandGoldOld,
                    inactiveColor: const Color(0xFF2C2C2C),
                    onChanged: onCartSubtotalChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Exemplos rápidos:",
                        style: TextStyle(color: brandTextLight.withOpacity(0.5), fontSize: 10),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => onCartSubtotalChanged(10.00),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                              ),
                              child: const Text("Coxinha Simples: R\$ 10,00", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => onCartSubtotalChanged(115.00),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                              ),
                              child: const Text("Premium Burger: R\$ 115,00", style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CARD 2: CONFIGURAÇÃO DE CIDADE & LOGÍSTICA DO ESTABELECIMENTO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandGraphiteSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_city, color: brandGoldOld, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Porte da Cidade do Estabelecimento",
                        style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Interior Button
                      Expanded(
                        child: InkWell(
                          onTap: () => onCityTypeChanged(TipoCidade.interior),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedCityType == TipoCidade.interior
                                  ? brandGoldOld.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedCityType == TipoCidade.interior
                                    ? brandGoldOld
                                    : const Color(0xFF2C2C2C),
                                width: selectedCityType == TipoCidade.interior ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text("🌳", style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                const Text("Interior", style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  "Split R\$ 4,00\n(R\$ 2 cliente / R\$ 2 loja)",
                                  style: TextStyle(color: brandTextLight.withOpacity(0.4), fontSize: 8),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Capital Button
                      Expanded(
                        child: InkWell(
                          onTap: () => onCityTypeChanged(TipoCidade.capital),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedCityType == TipoCidade.capital
                                  ? brandGoldOld.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedCityType == TipoCidade.capital
                                    ? brandGoldOld
                                    : const Color(0xFF2C2C2C),
                                width: selectedCityType == TipoCidade.capital ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text("🏢", style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                const Text("Capital", style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  "Split R\$ 6,00\n(R\$ 3 cliente / R\$ 3 loja)",
                                  style: TextStyle(color: brandTextLight.withOpacity(0.4), fontSize: 8),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CARD 3: ESCOLHA DO MÉTODO DE ENTREGA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandGraphiteSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.delivery_dining, color: brandGoldOld, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Modalidade de Logística",
                        style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Motoboy Delivery
                      Expanded(
                        child: InkWell(
                          onTap: () => onDeliveryMethodChanged("motoboy"),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: deliveryMethod == "motoboy"
                                  ? brandGoldOld.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: deliveryMethod == "motoboy"
                                    ? brandGoldOld
                                    : const Color(0xFF2C2C2C),
                                width: deliveryMethod == "motoboy" ? 1.5 : 1.0,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.delivery_dining, color: brandGoldOld, size: 20),
                                SizedBox(height: 4),
                                Text("Entrega Uni eats", style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 11)),
                                SizedBox(height: 2),
                                Text("Motoboy do ecossistema", style: TextStyle(color: brandTextMuted, fontSize: 8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Takeout
                      Expanded(
                        child: InkWell(
                          onTap: () => onDeliveryMethodChanged("retirada"),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: deliveryMethod == "retirada"
                                  ? brandGoldOld.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: deliveryMethod == "retirada"
                                    ? brandGoldOld
                                    : const Color(0xFF2C2C2C),
                                width: deliveryMethod == "retirada" ? 1.5 : 1.0,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.storefront, color: brandGoldOld, size: 20),
                                SizedBox(height: 4),
                                Text("Retirada no Local", style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 11)),
                                SizedBox(height: 2),
                                Text("Lojista não paga entrega", style: TextStyle(color: brandTextMuted, fontSize: 8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CARD 4: AUDITORIA DE PREÇOS E RESUMO DO SPLIT (DETALHADO E TRANSPARENTE)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: brandGraphiteSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2D2D2D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Resumo do Pedido & Split de Logística",
                    style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Subtotal dos pratos:", style: TextStyle(color: brandTextMuted, fontSize: 11)),
                      Text("R\$ ${cartSubtotal.toStringAsFixed(2)}", style: const TextStyle(color: brandTextLight, fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Taxa de Entrega (Pago pelo Cliente):", style: TextStyle(color: brandTextMuted, fontSize: 11)),
                      Text(
                        isDeliverySelected ? "R\$ ${taxaCliente.toStringAsFixed(2)}" : "Grátis",
                        style: TextStyle(
                          color: isDeliverySelected ? brandGoldOld : Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: isDeliverySelected ? FontWeight.normal : FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  if (isDeliverySelected) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Taxa de Logística (Paga pelo Restaurante):", style: TextStyle(color: brandTextMuted, fontSize: 11)),
                        Text(
                          "R\$ ${taxaRestaurante.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Ganho Total do Motoboy por Endereço:", style: TextStyle(color: brandTextMuted, fontSize: 11)),
                        Text(
                          "R\$ ${(taxaCliente + taxaRestaurante).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(height: 0.5, color: const Color(0xFF2C2C2C)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total do Cliente:",
                        style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        "R\$ ${totalFinal.toStringAsFixed(2)}",
                        style: const TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ALERTA VISUAL DA TRAVA DE SEGURANÇA (Se aplicável)
            if (safetyLockActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("⚠️", style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ALERTA DE SEGURANÇA CONTRA PREJUÍZO",
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "A taxa de split de entrega exige um valor mínimo de R\$ 15,00 em pratos. A modalidade de entrega foi bloqueada para evitar prejuízos na corrida.",
                            style: TextStyle(color: Color(0xFFFAF9F6), fontSize: 11, height: 1.4),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => onDeliveryMethodChanged("retirada"),
                            child: const Text(
                              "Sugestão: Altere para 'Retirada no Local' para prosseguir.",
                              style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // BOTÃO DE PAGAMENTO MERCADO PAGO
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: safetyLockActive ? null : onOrderPlaced,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGoldOld,
                  disabledBackgroundColor: const Color(0xFF1E1E1F),
                  foregroundColor: Colors.black,
                  disabledForegroundColor: const Color(0xFF71717A),
                  shape: RoundedCornerShape(27),
                  elevation: 2,
                ),
                child: Text(
                  safetyLockActive
                      ? "PEDIDO ABAIXO DO MÍNIMO DE R\$ 15,00"
                      : "PAGAR R\$ ${totalFinal.toStringAsFixed(2)} COM MERCADO PAGO",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MÓDULO 2: PAINEL DO MOTOBOY (Painel de Entregas & Simulação GPS)
// ============================================================================

class MotoboyDeliveryModule extends StatefulWidget {
  final TipoCidade selectedCityType;
  final bool hasActiveOffer;
  final VoidCallback onCompleteDelivery;
  final Function(String, int, double) onDeliverySimulationUpdate;

  const MotoboyDeliveryModule({
    Key? key,
    required this.selectedCityType,
    required this.hasActiveOffer,
    required this.onCompleteDelivery,
    required this.onDeliverySimulationUpdate,
  }) : super(key: key);

  @override
  State<MotoboyDeliveryModule> createState() => _MotoboyDeliveryModuleState();
}

class _UniEatsOffset {
  final double x;
  final double y;
  const _UniEatsOffset(this.x, this.y);
}

class _MotoboyDeliveryModuleState extends State<MotoboyDeliveryModule> with SingleTickerProviderStateMixin {
  String _deliveryState = "idle"; // "idle", "offered", "accepted"
  int _journeyStep = 1; // 1 = A caminho do restaurante, 2 = Coletando pedido, 3 = Rota ativa do cliente, 4 = Finalizada
  double _simulationProgress = 0.0;
  Timer? _gpsTimer;

  void _syncToParent() {
    widget.onDeliverySimulationUpdate(_deliveryState, _journeyStep, _simulationProgress);
  }

  // Pontos de GPS simulados no mapa dark
  final List<_UniEatsOffset> _gpsRoutePoints = [
    const _UniEatsOffset(30.0, 220.0),  // Posição Inicial Motoboy
    const _UniEatsOffset(150.0, 140.0), // Restaurante UniEats Signature
    const _UniEatsOffset(320.0, 60.0),  // Cliente (Al. Gabriel Monteiro)
  ];

  @override
  void initState() {
    super.initState();
    if (widget.hasActiveOffer) {
      _deliveryState = "offered";
    }
  }

  @override
  void didUpdateWidget(covariant MotoboyDeliveryModule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasActiveOffer && _deliveryState == "idle") {
      setState(() {
        _deliveryState = "offered";
      });
    }
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  void _startGpsSimulation() {
    _gpsTimer?.cancel();
    setState(() {
      _deliveryState = "accepted";
      _journeyStep = 1;
      _simulationProgress = 0.0;
    });
    _syncToParent();

    _gpsTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      setState(() {
        _simulationProgress += 0.03;
        if (_simulationProgress >= 1.0) {
          _simulationProgress = 0.0;
          _journeyStep += 1;
          if (_journeyStep > 3) {
            timer.cancel();
            _deliveryState = "idle";
            widget.onCompleteDelivery();
            _showDeliverySuccessDialog();
          }
        }
      });
      _syncToParent();
    });
  }

  void _showDeliverySuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedCornerShape(16),
        title: const Row(
          children: [
            Text("🎉 ", style: TextStyle(fontSize: 20)),
            Text("Corrida Concluída!", style: TextStyle(color: Color(0xFFFAF9F6), fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Parabéns! A entrega foi realizada com sucesso e o pagamento do split financeiro foi transferido instantaneamente para sua carteira Uni eats.",
          style: TextStyle(color: Color(0xFFFAF9F6), fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("EXCELENTE", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGoldOld = Color(0xFFD4AF37);
    const Color brandGraphiteSurface = Color(0xFF1C1C1C);
    const Color brandTextLight = Color(0xFFFAF9F6);
    const Color brandTextMuted = Color(0xFF71717A);

    // Ganho dinâmico do motoboy de acordo com a regra de negócios unificada
    // Multiplicado por 3 destinos
    final double taxaCidade = CalculadoraLogisticaService.calcularTaxaPorEndereco(widget.selectedCityType);
    final double ganhosTotais = taxaCidade * 3;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Módulo do Motoboy",
              style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.w300, fontSize: 18, letterSpacing: 1),
            ),
            Text(
              "PAINEL DE LOGÍSTICA & ENTREGAS",
              style: TextStyle(color: brandTextMuted, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. STATUS HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: brandGraphiteSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: brandGoldOld.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _deliveryState == "idle" ? Colors.green : brandGoldOld,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _deliveryState == "idle"
                            ? "Disponível para entregas"
                            : _deliveryState == "offered"
                                ? "Analisando proposta..."
                                : "Em rota ativa (Passo $_journeyStep/3)",
                        style: const TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const Text(
                    "ONLINE",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. ESTADO IDLE (BUSCANDO)
            if (_deliveryState == "idle") ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        color: brandGoldOld,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Rastreando pedidos em tempo real...",
                      style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sua geolocalização está ativa. Vá para a aba 'Sacola & Checkout', simule um pedido e clique em pagar para gerar uma nova rota!",
                      style: TextStyle(color: brandTextMuted, fontSize: 11, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            // 3. CARD DE CORRIDA DISPONÍVEL (Proposta Flutuante Premium)
            if (_deliveryState == "offered") ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: brandGraphiteSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandGoldOld, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: brandGoldOld.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: brandGoldOld.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "NOVA CORRIDA DISPONÍVEL",
                            style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1),
                          ),
                        ),
                        const Text(
                          "3.2 km (3 endereços)",
                          style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "R\$ ${ganhosTotais.toStringAsFixed(2)}",
                      style: const TextStyle(color: brandTextLight, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -0.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Ganho Líquido: 3 destinos x R\$ ${taxaCidade.toStringAsFixed(2)}",
                      style: const TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(height: 0.5, color: const Color(0xFF2C2C2C)),
                    const SizedBox(height: 16),
                    // Detalhes da Coleta
                    Row(
                      children: [
                        const Text("🏰", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Coleta no estabelecimento:", style: TextStyle(color: brandTextMuted, fontSize: 9)),
                            const SizedBox(height: 2),
                            Text(
                              "UniEats Signature (${widget.selectedCityType == TipoCidade.capital ? "Capital" : "Interior"})",
                              style: const TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Detalhes da Entrega
                    Row(
                      children: [
                        const Text("🛵", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Entrega nos destinos:", style: TextStyle(color: brandTextMuted, fontSize: 9)),
                            SizedBox(height: 2),
                            Text(
                              "3 endereços agrupados na região central",
                              style: TextStyle(color: brandTextLight, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Ações elegantes do card flutuante
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _deliveryState = "idle";
                              });
                              _syncToParent();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Corrida recusada. Retornando ao status disponível.")),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEF5350)),
                              shape: RoundedCornerShape(24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("RECUSAR", style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _startGpsSimulation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandGoldOld,
                              foregroundColor: Colors.black,
                              shape: RoundedCornerShape(24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("ACEITAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // 4. MAPA DE RASTREAMENTO GPS ATIVO EM TEMPO REAL
            if (_deliveryState == "accepted") ...[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C2C2C)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Representação de Linhas do Mapa Dark
                      CustomPaint(
                        size: const Size(double.infinity, 300),
                        painter: MapPainter(
                          routePoints: _gpsRoutePoints,
                          currentStep: _journeyStep,
                          progress: _simulationProgress,
                          gold: brandGoldOld,
                        ),
                      ),
                      // Overlay de Status do GPS
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: brandGoldOld.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _journeyStep == 1
                                        ? "A caminho do restaurante..."
                                        : _journeyStep == 2
                                            ? "Retirando embalagem..."
                                            : "A caminho dos destinos...",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                  Text(
                                    "${(_simulationProgress * 100).toInt()}%",
                                    style: const TextStyle(color: brandGoldOld, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _simulationProgress,
                                backgroundColor: const Color(0xFF2C2C2C),
                                color: brandGoldOld,
                                minHeight: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // CARD DE JORNADA DO MOTOBOY
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: brandGraphiteSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C2C2C)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Progresso da Rota Ativa",
                      style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    _buildJourneyStepRow(
                      stepNum: 1,
                      title: "Fase 1: Coleta na Cozinha",
                      desc: "Deslocamento até a UniEats Signature",
                      active: _journeyStep >= 1,
                      completed: _journeyStep > 1,
                      gold: brandGoldOld,
                    ),
                    _buildJourneyStepRow(
                      stepNum: 2,
                      title: "Fase 2: Conferência",
                      desc: "Verificação de itens e split fiscal",
                      active: _journeyStep >= 2,
                      completed: _journeyStep > 2,
                      gold: brandGoldOld,
                    ),
                    _buildJourneyStepRow(
                      stepNum: 3,
                      title: "Fase 3: Rota de Entrega Multi-endereço",
                      desc: "Entrega física de 3 pratos agrupados",
                      active: _journeyStep >= 3,
                      completed: _journeyStep > 3,
                      gold: brandGoldOld,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyStepRow({
    required int stepNum,
    required String title,
    required String desc,
    required bool active,
    required bool completed,
    required Color gold,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: completed
                  ? Colors.green
                  : active
                      ? gold
                      : const Color(0xFF2C2C2C),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : Text(
                      stepNum.toString(),
                      style: TextStyle(
                        color: active ? Colors.black : const Color(0xFF71717A),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
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
                    color: active ? const Color(0xFFFAF9F6) : const Color(0xFF71717A),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: const Color(0xFF71717A),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter para desenhar ruas e simular deslocamento GPS do Motoboy no mapa dark
class MapPainter extends CustomPainter {
  final List<_UniEatsOffset> routePoints;
  final int currentStep;
  final double progress;
  final Color gold;

  MapPainter({
    required this.routePoints,
    required this.currentStep,
    required this.progress,
    required this.gold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint routePaint = Paint()
      ..color = gold.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint activeRoutePaint = Paint()
      ..color = gold
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Desenhar ruas de fundo (simuladas)
    canvas.drawLine(const Offset(10, 50), const Offset(350, 50), linePaint);
    canvas.drawLine(const Offset(10, 150), const Offset(350, 150), linePaint);
    canvas.drawLine(const Offset(10, 250), const Offset(350, 250), linePaint);
    canvas.drawLine(const Offset(80, 10), const Offset(80, 290), linePaint);
    canvas.drawLine(const Offset(220, 10), const Offset(220, 290), linePaint);

    // Desenhar rota total
    final Path totalPath = Path();
    totalPath.moveTo(routePoints[0].x, routePoints[0].y);
    totalPath.lineTo(routePoints[1].x, routePoints[1].y);
    totalPath.lineTo(routePoints[2].x, routePoints[2].y);
    canvas.drawPath(totalPath, routePaint);

    // Calcular posição atual do motoboy baseada no passo da jornada
    double currentX = routePoints[0].x;
    double currentY = routePoints[0].y;

    if (currentStep == 1) {
      currentX = routePoints[0].x + (routePoints[1].x - routePoints[0].x) * progress;
      currentY = routePoints[0].y + (routePoints[1].y - routePoints[0].y) * progress;

      // Desenha rota ativa percorrida
      canvas.drawLine(Offset(routePoints[0].x, routePoints[0].y), Offset(currentX, currentY), activeRoutePaint);
    } else if (currentStep == 2) {
      // Coleta no restaurante (parado)
      currentX = routePoints[1].x;
      currentY = routePoints[1].y;

      canvas.drawLine(Offset(routePoints[0].x, routePoints[0].y), Offset(routePoints[1].x, routePoints[1].y), activeRoutePaint);
    } else if (currentStep >= 3) {
      currentX = routePoints[1].x + (routePoints[2].x - routePoints[1].x) * progress;
      currentY = routePoints[1].y + (routePoints[2].y - routePoints[1].y) * progress;

      // Desenha rota ativa percorrida
      canvas.drawLine(Offset(routePoints[0].x, routePoints[0].y), Offset(routePoints[1].x, routePoints[1].y), activeRoutePaint);
      canvas.drawLine(Offset(routePoints[1].x, routePoints[1].y), Offset(currentX, currentY), activeRoutePaint);
    }

    // Desenhar Marcador de Coleta (Restaurante)
    final Paint restPaint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(Offset(routePoints[1].x, routePoints[1].y), 8, restPaint);

    // Desenhar Marcador de Entrega (Cliente)
    final Paint clientPaint = Paint()..color = Colors.green;
    canvas.drawCircle(Offset(routePoints[2].x, routePoints[2].y), 8, clientPaint);

    // Desenhar Marcador do Motoboy (Rider)
    final Paint riderPaint = Paint()..color = gold;
    canvas.drawCircle(Offset(currentX, currentY), 10, riderPaint);

    final Paint riderPulse = Paint()..color = gold.withOpacity(0.4);
    canvas.drawCircle(Offset(currentX, currentY), 16, riderPulse);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}

// ============================================================================
// MÓDULO 3: PAINEL SUPER ADMIN (Painel do Proprietário / Faturamento)
// ============================================================================

class SuperAdminModule extends StatefulWidget {
  final Map<String, dynamic> user;
  final TipoCidade selectedCityType;
  final ValueChanged<TipoCidade> onCityTypeChanged;
  final double totalFees;
  final int totalOrders;

  const SuperAdminModule({
    Key? key,
    required this.user,
    required this.selectedCityType,
    required this.onCityTypeChanged,
    required this.totalFees,
    required this.totalOrders,
  }) : super(key: key);

  @override
  State<SuperAdminModule> createState() => _SuperAdminModuleState();
}

class _SuperAdminModuleState extends State<SuperAdminModule> {
  bool _modoGratuitoSemAssinatura = true;
  bool _isUserVerifiedOwner = false;

  final TextEditingController _bronzeController = TextEditingController(text: "129.90");
  final TextEditingController _prataController = TextEditingController(text: "249.90");
  final TextEditingController _ouroController = TextEditingController(text: "499.90");

  @override
  Widget build(BuildContext context) {
    const Color brandGoldOld = Color(0xFFD4AF37);
    const Color brandGraphiteSurface = Color(0xFF1C1C1C);
    const Color brandTextLight = Color(0xFFFAF9F6);
    const Color brandTextMuted = Color(0xFF71717A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Painel do Proprietário",
              style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.w300, fontSize: 18, letterSpacing: 1),
            ),
            Text(
              "SUPER ADMIN MANAGEMENT SYSTEM",
              style: TextStyle(color: brandTextMuted, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AUTENTICAÇÃO COMO SUPER ADMIN (TRAVA DE IDENTIDADE SE VERIFICADO)
            if (!_isUserVerifiedOwner) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: brandGraphiteSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandGoldOld.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    const Text("🔒", style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    const Text(
                      "Acesso Altamente Restrito",
                      style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Esta área de faturamento, split financeiro e precificação de planos exige autenticação biométrica em ambiente produtivo.",
                      style: TextStyle(color: brandTextMuted, fontSize: 11, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isUserVerifiedOwner = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✓ Identidade de Proprietário autenticada com sucesso!"),
                              backgroundColor: Color(0xFF2E7D32),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGoldOld,
                          foregroundColor: Colors.black,
                          shape: RoundedCornerShape(24),
                        ),
                        child: const Text(
                          "AUTENTICAR COMO PROPRIETÁRIO",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // PERFIL DO PROPRIETÁRIO LOGADO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: brandGoldOld.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: brandGoldOld.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Text("🛡️", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user["name"].toString().toUpperCase(),
                          style: const TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        Text(
                          widget.user["email"].toString(),
                          style: const TextStyle(color: brandTextMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // CONFIGURAÇÃO DE CIDADE & SPLIT DE LOGÍSTICA (REGRAS DO MOTOR DE LOGÍSTICA)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: brandGraphiteSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C2C2C)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_city, color: brandGoldOld, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "Porte de Cidade & Taxas de Split",
                          style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Altere a configuração global da cidade para testar como o split se comporta na sacola e no faturamento do motoboy em tempo real.",
                      style: TextStyle(color: brandTextMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Interior Option
                        Expanded(
                          child: InkWell(
                            onTap: () => widget.onCityTypeChanged(TipoCidade.interior),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.selectedCityType == TipoCidade.interior
                                    ? brandGoldOld.withOpacity(0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: widget.selectedCityType == TipoCidade.interior
                                      ? brandGoldOld
                                      : const Color(0xFF2C2C2C),
                                  width: widget.selectedCityType == TipoCidade.interior ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text("🌳", style: TextStyle(fontSize: 18)),
                                  const SizedBox(height: 4),
                                  const Text("Interior", style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Taxa: R\$ 4,00\n(Cliente: R\$ 2,00 / Loja: R\$ 2,00)",
                                    style: TextStyle(color: brandTextLight.withOpacity(0.4), fontSize: 8),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Capital Option
                        Expanded(
                          child: InkWell(
                            onTap: () => widget.onCityTypeChanged(TipoCidade.capital),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.selectedCityType == TipoCidade.capital
                                    ? brandGoldOld.withOpacity(0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: widget.selectedCityType == TipoCidade.capital
                                      ? brandGoldOld
                                      : const Color(0xFF2C2C2C),
                                  width: widget.selectedCityType == TipoCidade.capital ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text("🏢", style: TextStyle(fontSize: 18)),
                                  const SizedBox(height: 4),
                                  const Text("Capital", style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Taxa: R\$ 6,00\n(Cliente: R\$ 3,00 / Loja: R\$ 3,00)",
                                    style: TextStyle(color: brandTextLight.withOpacity(0.4), fontSize: 8),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // GRATUITIDADE SWITCH (Modo Plataforma Gratuita)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: brandGraphiteSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C2C2C)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Modo Plataforma Gratuita",
                            style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Se ativo, restaurantes parceiros ficam isentos de assinaturas Bronze, Prata e Ouro.",
                            style: TextStyle(color: brandTextLight.withOpacity(0.4), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _modoGratuitoSemAssinatura,
                      onChanged: (val) {
                        setState(() {
                          _modoGratuitoSemAssinatura = val;
                        });
                      },
                      activeColor: brandGoldOld,
                      activeTrackColor: brandGoldOld.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // CONFIGURADOR DE PLANOS FUTUROS (Bronze, Prata, Ouro)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: brandGraphiteSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2D2D2D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Text("⭐", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text(
                          "Configurador de Planos Futuros",
                          style: TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPlanConfigRow(
                      title: "Plan L'Elite Bronze",
                      controller: _bronzeController,
                      gold: brandGoldOld,
                      textMuted: brandTextMuted,
                    ),
                    const SizedBox(height: 8),
                    _buildPlanConfigRow(
                      title: "Plan L'Elite Prata",
                      controller: _prataController,
                      gold: brandGoldOld,
                      textMuted: brandTextMuted,
                    ),
                    const SizedBox(height: 8),
                    _buildPlanConfigRow(
                      title: "Plan L'Or Exclusive",
                      controller: _ouroController,
                      gold: brandGoldOld,
                      textMuted: brandTextMuted,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✓ Valores de planos customizados atualizados com sucesso!"),
                              backgroundColor: Color(0xFF2E7D32),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGoldOld,
                          foregroundColor: Colors.black,
                          shape: RoundedCornerShape(22),
                        ),
                        child: const Text("SALVAR CONFIGURAÇÕES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // PAINEL DE TRANSACÕES REAL-TIME (SPLIT FINANCEIRO TRANSPARENTE)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: brandGoldOld.withOpacity(0.015),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandGoldOld.withOpacity(0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics_outlined, color: brandGoldOld, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Auditoria de Split (Transparente)",
                          style: TextStyle(color: brandTextLight, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Taxas deduzidas dos restaurantes:", style: TextStyle(color: brandTextMuted, fontSize: 11)),
                        Text("R\$ ${widget.totalFees.toStringAsFixed(2)}", style: const TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total de transações processadas:", style: TextStyle(color: brandTextMuted, fontSize: 11)),
                        Text("${widget.totalOrders} pedidos", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Porte atual da cidade de split:", style: TextStyle(color: brandTextMuted, fontSize: 11)),
                        Text(widget.selectedCityType == TipoCidade.capital ? "Capital/Grande (R\$ 3 split)" : "Interior/Pequena (R\$ 2 split)", style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanConfigRow({
    required String title,
    required TextEditingController controller,
    required Color gold,
    required Color textMuted,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              decoration: InputDecoration(
                prefixText: "R\$ ",
                prefixStyle: TextStyle(color: gold, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: gold),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AcompanhamentoPedidoModule extends StatefulWidget {
  final String deliveryState;
  final int journeyStep;
  final double simulationProgress;
  final TipoCidade selectedCityType;
  final bool orderPlaced;
  final double cartSubtotal;
  final VoidCallback onNavigateToCheckout;

  const AcompanhamentoPedidoModule({
    Key? key,
    required this.deliveryState,
    required this.journeyStep,
    required this.simulationProgress,
    required this.selectedCityType,
    required this.orderPlaced,
    required this.cartSubtotal,
    required this.onNavigateToCheckout,
  }) : super(key: key);

  @override
  State<AcompanhamentoPedidoModule> createState() => _AcompanhamentoPedidoModuleState();
}

class _AcompanhamentoPedidoModuleState extends State<AcompanhamentoPedidoModule> {
  bool _feesExpanded = false;
  final List<Map<String, String>> _chatMessages = [
    {"sender": "rider", "message": "Olá! Seu pedido já está sendo preparado e vou cuidar da sua entrega rápida."},
    {"sender": "rider", "message": "Assim que coletar na cozinha premium, aviso você por aqui! 🏍️"},
  ];
  final TextEditingController _chatController = TextEditingController();

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF1C1C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.maxFinite,
                height: 450,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFD4AF37).withOpacity(0.15),
                          child: const Text("MN", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Maurício Neves", style: TextStyle(color: Color(0xFFFAF9F6), fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Online agora", style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF71717A)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF2C2C2C)),
                    // Messages
                    Expanded(
                      child: ListView.builder(
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final msg = _chatMessages[index];
                          final isRider = msg["sender"] == "rider";
                          return Align(
                            alignment: isRider ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isRider ? const Color(0xFF2C2C2C) : const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isRider ? Radius.zero : const Radius.circular(12),
                                  bottomRight: isRider ? const Radius.circular(12) : Radius.zero,
                                ),
                              ),
                              child: Text(
                                msg["message"] ?? "",
                                style: TextStyle(color: isRider ? const Color(0xFFFAF9F6) : Colors.black, fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(color: Color(0xFF2C2C2C)),
                    // Input Footer
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            style: const TextStyle(color: Color(0xFFFAF9F6), fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Escreva uma mensagem...",
                              hintStyle: const TextStyle(color: Color(0xFF71717A), fontSize: 13),
                              fillColor: const Color(0xFF141414),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: const Color(0xFFD4AF37),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.black, size: 16),
                            onPressed: () {
                              if (_chatController.text.isNotEmpty) {
                                setDialogState(() {
                                  _chatMessages.add({
                                    "sender": "me",
                                    "message": _chatController.text,
                                  });
                                });
                                setState(() {}); // Sync parent UI if needed
                                _chatController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveOrder = widget.orderPlaced && widget.deliveryState != "idle";
    const Color gold = Color(0xFFD4AF37);
    const Color cardBg = Color(0xFF1C1C1C);

    if (!hasActiveOrder) {
      // Empty state widget
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("📦", style: TextStyle(fontSize: 72)),
            const SizedBox(height: 24),
            const Text(
              "NENHUM PEDIDO EM ANDAMENTO",
              style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Selecione pratos finos em nosso cardápio de alta gastronomia para simular e acompanhar o rastreamento em tempo real com GPS.",
              style: TextStyle(color: Color(0xFF71717A), fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.onNavigateToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("VER SACOLA DE COMPRAS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      );
    }

    // Active order tracking page
    final double taxa = widget.selectedCityType == TipoCidade.capital ? 3.00 : 2.00;
    final double totalFinal = widget.cartSubtotal;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rastreamento do Pedido", style: TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.w300)),
                SizedBox(height: 4),
                Text("PEDIDO #5812 • Uni eats Premium", style: TextStyle(color: Color(0xFF71717A), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.1),
                border: Border.all(color: gold.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.deliveryState == "offered" ? "CONFIRMANDO..." :
                widget.journeyStep == 1 ? "EM PREPARO" :
                widget.journeyStep == 2 ? "PRONTO" :
                widget.journeyStep == 3 ? "EM ROTA" : "ENTREGUE",
                style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Dark Map with overlapping points and dynamic rider icon
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gold.withOpacity(0.15)),
          ),
          child: Stack(
            children: [
              // Draw street lines using custom paint
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapGridPainter(
                    journeyStep: widget.journeyStep,
                    progress: widget.simulationProgress,
                    deliveryState: widget.deliveryState,
                  ),
                ),
              ),
              // Restaurant static node
              Positioned(
                left: 35,
                top: 80,
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text("🍳", style: TextStyle(fontSize: 10)),
                    ),
                    const SizedBox(height: 4),
                    const Text("UniEats", style: TextStyle(color: Color(0xFF71717A), fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Client static node
              Positioned(
                right: 35,
                top: 30,
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text("🏠", style: TextStyle(fontSize: 10)),
                    ),
                    const SizedBox(height: 4),
                    const Text("Seu Lar", style: TextStyle(color: Color(0xFF71717A), fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Dynamic rider marker
              if (widget.deliveryState == "accepted")
                Builder(
                  builder: (context) {
                    final double startX = 35;
                    final double startY = 80;
                    final double endX = 225; // approximated screen width offset
                    final double endY = 30;

                    double riderX = startX;
                    double riderY = startY;

                    if (widget.journeyStep == 1) {
                      riderX = startX - (15 * (1.0 - widget.simulationProgress));
                      riderY = startY + (20 * (1.0 - widget.simulationProgress));
                    } else if (widget.journeyStep == 2) {
                      riderX = startX;
                      riderY = startY;
                    } else if (widget.journeyStep == 3) {
                      riderX = startX + (endX - startX) * widget.simulationProgress;
                      riderY = startY + (endY - startY) * widget.simulationProgress;
                    } else {
                      riderX = endX;
                      riderY = endY;
                    }

                    return Positioned(
                      left: riderX,
                      top: riderY,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: const Text("🏍️", style: TextStyle(fontSize: 14)),
                      ),
                    );
                  }
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Delivery Rider details card
        Card(
          color: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: gold.withOpacity(0.15),
                  child: const Text("MN", style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Maurício Neves", style: TextStyle(color: Color(0xFFFAF9F6), fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Entregador Parceiro Premium", style: TextStyle(color: Color(0xFF71717A), fontSize: 11)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text("⭐ 4.9", style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 11)),
                          SizedBox(width: 6),
                          Text("• 1.242 corridas", style: TextStyle(color: Color(0xFF71717A), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2C2C2C),
                      child: IconButton(
                        icon: const Icon(Icons.chat, color: gold, size: 18),
                        onPressed: _showChatDialog,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2C2C2C),
                      child: IconButton(
                        icon: const Icon(Icons.phone, color: Color(0xFFFAF9F6), size: 18),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Simulando ligação de suporte gourmet direta...")),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stepper Timeline Card
        Card(
          color: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Evolução do Pedido", style: TextStyle(color: Color(0xFFFAF9F6), fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 20),

                _buildStepItem(
                  stepNumber: 1,
                  title: "Pedido Confirmado",
                  desc: "Seu pedido gastronômico foi integrado e aprovado.",
                  isCompleted: widget.deliveryState != "idle",
                  isActive: widget.deliveryState == "offered",
                  showLine: true,
                ),
                _buildStepItem(
                  stepNumber: 2,
                  title: "Em Preparo",
                  desc: "O Chef gourmet está preparando sua seleção especial.",
                  isCompleted: widget.deliveryState == "accepted" && widget.journeyStep > 1,
                  isActive: widget.deliveryState == "accepted" && widget.journeyStep == 1,
                  showLine: true,
                ),
                _buildStepItem(
                  stepNumber: 3,
                  title: "Pronto para Coleta",
                  desc: "Seu pedido foi embalado sob proteção térmica.",
                  isCompleted: widget.deliveryState == "accepted" && widget.journeyStep > 2,
                  isActive: widget.deliveryState == "accepted" && widget.journeyStep == 2,
                  showLine: true,
                ),
                _buildStepItem(
                  stepNumber: 4,
                  title: "A Caminho",
                  desc: "O entregador de elite iniciou a rota de entrega expressa.",
                  isCompleted: widget.deliveryState == "accepted" && widget.journeyStep > 3,
                  isActive: widget.deliveryState == "accepted" && widget.journeyStep == 3,
                  showLine: true,
                ),
                _buildStepItem(
                  stepNumber: 5,
                  title: "Pedido Entregue",
                  desc: "Bom apetite! Experiência gastronômica concluída.",
                  isCompleted: widget.deliveryState == "idle" && widget.orderPlaced,
                  isActive: widget.deliveryState == "accepted" && widget.journeyStep >= 4,
                  showLine: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Expandable Transparency Card
        Card(
          color: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _feesExpanded = !_feesExpanded),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text("🧾", style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Text("Resumo & Transparência de Taxas", style: TextStyle(color: Color(0xFFFAF9F6), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Icon(
                        _feesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: gold,
                      ),
                    ],
                  ),
                ),
                if (_feesExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF2C2C2C)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Subtotal dos pratos", style: TextStyle(color: Color(0xFF71717A), fontSize: 11)),
                      Text("R\$ ${widget.cartSubtotal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFFAF9F6), fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Taxa de Entrega Limpa (100% Repassada)", style: TextStyle(color: gold, fontSize: 11)),
                      Text("R\$ ${taxa.toStringAsFixed(2)}", style: const TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2C2C2C)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Pago", style: TextStyle(color: Color(0xFFFAF9F6), fontSize: 13, fontWeight: FontWeight.bold)),
                      Text("R\$ ${totalFinal.toStringAsFixed(2)}", style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Uni eats apoia o frete justo: esta taxa de R\$ ${taxa.toStringAsFixed(2)} foi inteiramente destinada ao entregador parceiro Maurício Neves, sem qualquer retenção ou comissionamento por nossa plataforma.",
                      style: const TextStyle(color: Color(0xFFFAF9F6), fontSize: 10, height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String desc,
    required bool isCompleted,
    required bool isActive,
    required bool showLine,
  }) {
    final Color gold = const Color(0xFFD4AF37);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF4CAF50) : (isActive ? gold : const Color(0xFF2C2C2C)),
                shape: BoxShape.circle,
                border: isActive ? Border.all(color: Colors.white, width: 1.5) : null,
              ),
              alignment: Alignment.center,
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : Text(
                      stepNumber.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 45,
                color: isCompleted ? const Color(0xFF4CAF50) : (isActive ? gold.withOpacity(0.3) : const Color(0xFF2C2C2C)),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCompleted ? const Color(0xFF4CAF50) : (isActive ? gold : const Color(0xFFFAF9F6).withOpacity(0.4)),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  color: isActive ? const Color(0xFFFAF9F6).withOpacity(0.8) : const Color(0xFFFAF9F6).withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final int journeyStep;
  final double progress;
  final String deliveryState;

  _MapGridPainter({
    required this.journeyStep,
    required this.progress,
    required this.deliveryState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintStreet = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Horizontal Streets
    canvas.drawLine(const Offset(0, 60), Offset(size.width, 60), paintStreet);
    canvas.drawLine(const Offset(0, 160), Offset(size.width, 160), paintStreet);

    // Vertical Streets
    canvas.drawLine(const Offset(100, 0), Offset(100, size.height), paintStreet);
    canvas.drawLine(Offset(size.width - 100, 0), Offset(size.width - 100, size.height), paintStreet);

    // Active Path Line
    final paintPathBack = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.25)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const Offset start = Offset(47, 92); // Restaurant coordinates approximate
    final Offset end = Offset(size.width - 47, 42); // Client coordinates approximate

    canvas.drawLine(start, end, paintPathBack);

    if (deliveryState == "accepted" && journeyStep == 3) {
      final paintPathActive = Paint()
        ..color = const Color(0xFFD4AF37)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final current = Offset(
        start.dx + (end.dx - start.dx) * progress,
        start.dy + (end.dy - start.dy) * progress,
      );

      canvas.drawLine(start, current, paintPathActive);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.journeyStep != journeyStep || oldDelegate.progress != progress || oldDelegate.deliveryState != deliveryState;
  }
}

// ====================================================================
// EXTRATO DO LOJISTA (Visão do Restaurante)
// ====================================================================
class ExtratoLojistaModule extends StatelessWidget {
  final double balance;
  final List<SimulatedSale> sales;
  final TipoCidade selectedCityType;

  const ExtratoLojistaModule({
    Key? key,
    required this.balance,
    required this.sales,
    required this.selectedCityType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color brandDarkBg = Color(0xFF121212);
    const Color brandGoldOld = Color(0xFFD4AF37);
    const Color brandGraphiteSurface = Color(0xFF1C1C1C);
    const Color brandTextLight = Color(0xFFFAF9F6);
    const Color brandTextMuted = Color(0xFF71717A);

    return Scaffold(
      backgroundColor: brandDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                "EXTRATO DE GANHOS",
                style: TextStyle(
                  color: brandGoldOld,
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "PORTAL DO PARCEIRO RESTAURANTE",
                style: TextStyle(
                  color: brandTextMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Card de Saldo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: brandGraphiteSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandGoldOld.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "SALDO A RECEBER",
                      style: TextStyle(
                        color: brandTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "R\$ ${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: brandTextLight,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          "Cidade: ${selectedCityType == TipoCidade.capital ? 'Capital (Logística R\$ 3,00)' : 'Interior (Logística R\$ 2,00)'}",
                          style: TextStyle(
                            color: brandGoldOld.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Título de Vendas Recentes
              const Row(
                children: [
                  Icon(Icons.history_toggle_off, color: brandGoldOld, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "VENDAS RECENTES (SPLIT FINANCEIRO)",
                    style: TextStyle(
                      color: brandTextLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (sales.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Text(
                        "🍳",
                        style: TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Nenhuma venda recente ainda.",
                        style: TextStyle(color: brandTextMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Simule um checkout para ver o split acontecer em tempo real.",
                        style: TextStyle(color: brandTextMuted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sales.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    final orderTotal = sale.orderValue;
                    final isCapital = sale.cityType == TipoCidade.capital;
                    final double logisticDeduction = isCapital ? 3.00 : 2.00;
                    const double platformSaaS = 0.80;
                    final double netValue = orderTotal - logisticDeduction - platformSaaS;

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: brandGraphiteSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: brandGoldOld.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.receipt, color: brandGoldOld, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Pedido #${sale.orderId}",
                                    style: const TextStyle(
                                      color: brandTextLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${sale.date.hour.toString().padLeft(2, '0')}:${sale.date.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  color: brandTextMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildSplitRow("Valor Bruto do Pedido", "+R\$ ${orderTotal.toStringAsFixed(2)}", Colors.greenAccent, isBold: true),
                          _buildSplitRow("Taxa Uni eats (SaaS)", "-R\$ ${platformSaaS.toStringAsFixed(2)}", Colors.redAccent),
                          _buildSplitRow(
                            "Logística Dividida (${isCapital ? 'Capital' : 'Interior'})",
                            "-R\$ ${logisticDeduction.toStringAsFixed(2)}",
                            Colors.redAccent,
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          _buildSplitRow(
                            "VALOR LÍQUIDO (SALDO)",
                            "R\$ ${netValue.toStringAsFixed(2)}",
                            brandGoldOld,
                            isBold: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : const Color(0xFFA0A0A5),
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// CARTEIRA VIRTUAL DO MOTOBOY (Painel de Carteira)
// ====================================================================
class CarteiraMotoboyModule extends StatelessWidget {
  final double balance;
  final List<CompletedRoute> routes;
  final TipoCidade selectedCityType;
  final VoidCallback onRequestWithdrawal;

  const CarteiraMotoboyModule({
    Key? key,
    required this.balance,
    required this.routes,
    required this.selectedCityType,
    required this.onRequestWithdrawal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color brandDarkBg = Color(0xFF121212);
    const Color brandGoldOld = Color(0xFFD4AF37);
    const Color brandGraphiteSurface = Color(0xFF1C1C1C);
    const Color brandTextLight = Color(0xFFFAF9F6);
    const Color brandTextMuted = Color(0xFF71717A);

    return Scaffold(
      backgroundColor: brandDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                "CARTEIRA DIGITAL",
                style: TextStyle(
                  color: brandGoldOld,
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "SISTEMA DE PAGAMENTO DE ENTREGAS",
                style: TextStyle(
                  color: brandTextMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Card de Saldo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: brandGraphiteSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: brandGoldOld.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "SALDO DISPONÍVEL",
                      style: TextStyle(
                        color: brandTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "R\$ ${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: brandTextLight,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: balance > 0
                            ? () {
                                onRequestWithdrawal();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("✓ Transferência Pix de saque enviada com sucesso!"),
                                    backgroundColor: Color(0xFF2E7D32),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGoldOld,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: brandGoldOld.withOpacity(0.2),
                          disabledForegroundColor: brandTextMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          "SOLICITAR SAQUE VIA PIX",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Título de Rotas Concluídas
              const Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: brandGoldOld, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "HISTÓRICO DE ROTAS FINALIZADAS",
                    style: TextStyle(
                      color: brandTextLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (routes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Text(
                        "🛵",
                        style: TextStyle(fontSize: 36),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Nenhuma rota concluída ainda.",
                        style: TextStyle(color: brandTextMuted, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Aceite e finalize uma corrida para acumular saldo na sua carteira.",
                        style: TextStyle(color: brandTextMuted, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: routes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final route = routes[index];

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: brandGraphiteSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: brandGoldOld.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                route.name,
                                style: const TextStyle(
                                  color: brandTextLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Text(
                                  route.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Distribuída em ${route.addressesCount} endereços",
                                style: const TextStyle(
                                  color: brandTextMuted,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                "R\$ ${route.earnings.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: brandGoldOld,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Concluído em ${route.date.hour.toString().padLeft(2, '0')}:${route.date.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: brandTextMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom drop-in replacement helper for RoundedCornerShape
class RoundedCornerShape extends RoundedRectangleBorder {
  RoundedCornerShape(double radius) : super(borderRadius: BorderRadius.circular(radius));
}
