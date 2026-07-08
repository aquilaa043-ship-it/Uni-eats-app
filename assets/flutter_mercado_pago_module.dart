import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================================
// 1. MERCADO PAGO SERVICE IN DART / FLUTTER
// ============================================================================

enum PaymentStatus { approved, pending, rejected }

class MercadoPagoPaymentResponse {
  final int paymentId;
  final PaymentStatus status;
  final String statusDetail;
  final double transactionAmount;
  final String? qrCode; // Chave Pix Copia e Cola
  final String paymentMethodId;

  MercadoPagoPaymentResponse({
    required this.paymentId,
    required this.status,
    required this.statusDetail,
    required this.transactionAmount,
    this.qrCode,
    required this.paymentMethodId,
  });
}

/// Serviço de integração de pagamentos com Mercado Pago v1/payments.
/// Oferece simulação completa e comentários detalhados para produção.
class MercadoPagoService {
  // CREDENCIAIS DO MERCADO PAGO
  // No painel do desenvolvedor do Mercado Pago, obtenha suas credenciais:
  // Sandbox: Seu token de teste para homologação
  // Produção: Seu token definitivo para transacionar valores reais
  // Recomenda-se injetar estas credenciais via variáveis de ambiente de forma segura.
  static const String _accessToken = "APP_USR-1234567890123456-9abcde... (INSIRA SEU ACCESS TOKEN AQUI)";
  static const String _baseUrl = "https://api.mercadopago.com";

  /// Cria um pagamento via Pix
  /// Endpoint Real: POST https://api.mercadopago.com/v1/payments
  ///
  /// Headers Necessários:
  /// - Authorization: Bearer <ACCESS_TOKEN>
  /// - Content-Type: application/json
  /// - X-Idempotency-Key: <UUID único para evitar re-cobrança em caso de falha de conexão>
  Future<MercadoPagoPaymentResponse> createPixPayment({
    required double amount,
    required String payerEmail,
    required String payerCpf,
    required String payerFirstName,
    required String payerLastName,
  }) async {
    // Simula tempo de resposta da rede da API do Mercado Pago
    await Future.delayed(const Duration(milliseconds: 1500));

    final int generatedPaymentId = 1000000000 + Random().nextInt(900000000);
    
    // String Pix no padrão EMV do Banco Central gerada dinamicamente
    final String simulatedPixKey = 
        "00020101021226870014br.gov.bcb.pix2565mercadopago.com.br/qr/v2/simulatedpixkey${generatedPaymentId}5204000053039865405${amount.toInt()}5802BR5915UniEatsGourmet6009SaoPaulo62070503***6304";

    /*
    CÓDIGO DE INTEGRAÇÃO REAL COM HTTP (Exemplo usando http):
    
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/payments'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
        'X-Idempotency-Key': 'SUA_CHAVE_UUID_UNICA',
      },
      body: jsonEncode({
        "transaction_amount": amount,
        "description": "Menu Gourmet Uni eats",
        "payment_method_id": "pix",
        "payer": {
          "email": payerEmail,
          "first_name": payerFirstName,
          "last_name": payerLastName,
          "identification": {
            "type": "CPF",
            "number": payerCpf,
          }
        }
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final status = data['status']; // approved, pending, in_process, rejected
      final qrCode = data['point_of_interaction']['transaction_data']['qr_code'];
      ...
    }
    */

    return MercadoPagoPaymentResponse(
      paymentId: generatedPaymentId,
      status: PaymentStatus.pending,
      statusDetail: "pending_waiting_transfer",
      transactionAmount: amount,
      qrCode: simulatedPixKey,
      paymentMethodId: "pix",
    );
  }

  /// Cria um pagamento via Cartão de Crédito
  /// 
  /// IMPORTANTE: Em conformidade com as regras de segurança PCI-DSS, nunca envie
  /// os dados do cartão em texto puro para o seu backend. Use o SDK Web/Mobile do
  /// Mercado Pago para gerar um "Card Token" seguro e envie apenas o token.
  Future<MercadoPagoPaymentResponse> createCardPayment({
    required double amount,
    required String cardToken, // Gerado com segurança pelo SDK do Mercado Pago
    required String paymentMethodId, // Ex: 'visa', 'mastercard', 'elo'
    required int installments,
    required String payerEmail,
    required String cvv, // Usado para direcionar os mocks de teste do sandbox
  }) async {
    // Simula a validação antifraude em tempo de processamento
    await Future.delayed(const Duration(seconds: 2));

    final int generatedPaymentId = 2000000000 + Random().nextInt(90000000);

    // Fluxo de Sandbox Mercado Pago simulado baseado em regras de CVV do cartão
    if (cvv == "666") {
      return MercadoPagoPaymentResponse(
        paymentId: generatedPaymentId,
        status: PaymentStatus.rejected,
        statusDetail: "cc_rejected_insufficient_amount",
        transactionAmount: amount,
        paymentMethodId: paymentMethodId,
      );
    } else if (cvv == "777") {
      return MercadoPagoPaymentResponse(
        paymentId: generatedPaymentId,
        status: PaymentStatus.rejected,
        statusDetail: "cc_rejected_high_risk",
        transactionAmount: amount,
        paymentMethodId: paymentMethodId,
      );
    } else {
      return MercadoPagoPaymentResponse(
        paymentId: generatedPaymentId,
        status: PaymentStatus.approved,
        statusDetail: "accredited",
        transactionAmount: amount,
        paymentMethodId: paymentMethodId,
      );
    }
  }
}

// ============================================================================
// 2. TELA DE CHECKOUT PREMIUM EM FLUTTER
// ============================================================================

class CheckoutScreen extends StatefulWidget {
  final double subtotal;
  final VoidCallback onOrderConfirmed;

  const CheckoutScreen({
    Key? key,
    required this.subtotal,
    required this.onOrderConfirmed,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final MercadoPagoService _mpService = MercadoPagoService();
  String _paymentMethod = "pix"; // "pix" ou "card"
  String _checkoutStep = "cart"; // "cart", "payment", "processing", "pix_success", "success", "failed"

  // Controllers
  final TextEditingController _emailController = TextEditingController(text: "aquilaa043@gmail.com");
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String? _errorMessage;
  late MercadoPagoPaymentResponse _lastResponse;
  bool _isCopied = false;

  double get _discount => widget.subtotal > 0 ? 30.0 : 0.0;
  double get _total => widget.subtotal - _discount;

  @override
  void dispose() {
    _emailController.dispose();
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // Formatações do Cartão
  void _onCardNumberChanged(String value) {
    String clean = value.replaceAll(' ', '');
    if (clean.length > 16) clean = clean.substring(0, 16);
    
    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      formatted.write(clean[i]);
      if ((i + 1) % 4 == 0 && i != 15) {
        formatted.write(' ');
      }
    }
    
    _cardNumberController.value = TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _onExpiryChanged(String value) {
    String clean = value.replaceAll('/', '');
    if (clean.length > 4) clean = clean.substring(0, 4);
    
    StringBuffer formatted = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      formatted.write(clean[i]);
      if (i == 1 && clean.length > 2) {
        formatted.write('/');
      }
    }
    
    _expiryController.value = TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _processPayment() async {
    setState(() {
      _checkoutStep = "processing";
      _errorMessage = null;
    });

    if (_paymentMethod == "pix") {
      try {
        final res = await _mpService.createPixPayment(
          amount: _total,
          payerEmail: _emailController.text,
          payerCpf: "12345678900",
          payerFirstName: "Guilherme",
          payerLastName: "Prado",
        );
        setState(() {
          _lastResponse = res;
          _checkoutStep = "pix_success";
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Erro ao gerar PIX. Tente novamente.";
          _checkoutStep = "payment";
        });
      }
    } else {
      // Validações locais
      String cleanCard = _cardNumberController.text.replaceAll(' ', '');
      if (cleanCard.length < 16) {
        _showFormError("Número de cartão inválido.");
        return;
      }
      if (_holderNameController.text.trim().length < 3) {
        _showFormError("Nome do titular inválido.");
        return;
      }
      if (_expiryController.text.length < 5) {
        _showFormError("Validade incorreta. Use MM/YY.");
        return;
      }
      if (_cvvController.text.length < 3) {
        _showFormError("CVV incorreto.");
        return;
      }

      try {
        final res = await _mpService.createCardPayment(
          amount: _total,
          cardToken: "simulated_secure_token",
          paymentMethodId: cleanCard.startsWith('4') ? 'visa' : 'mastercard',
          installments: 1,
          payerEmail: "guilherme@select.com",
          cvv: _cvvController.text,
        );

        setState(() {
          _lastResponse = res;
          if (res.status == PaymentStatus.approved) {
            _checkoutStep = "success";
            widget.onOrderConfirmed();
          } else {
            _checkoutStep = "failed";
          }
        });
      } catch (e) {
        _showFormError("Erro ao processar transação financeira.");
      }
    }
  }

  void _showFormError(String error) {
    setState(() {
      _errorMessage = error;
      _checkoutStep = "payment";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Paleta de Cores Premium (Slate e Gold)
    const primaryGold = Color(0xFFC5A880);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textOnSurface = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _checkoutStep == "cart" ? "Sua Sacola" : "Finalizar Reserva",
          style: const TextStyle(fontWeight: FontWeight.w300, letterSpacing: 1),
        ),
        centerTitle: true,
        leading: _checkoutStep != "cart" && _checkoutStep != "success" && _checkoutStep != "processing"
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  setState(() {
                    if (_checkoutStep == "pix_success" || _checkoutStep == "failed") {
                      _checkoutStep = "payment";
                    } else if (_checkoutStep == "payment") {
                      _checkoutStep = "cart";
                    }
                  });
                },
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(cardBg, textOnSurface, primaryGold),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(Color cardBg, Color textOnSurface, Color gold) {
    switch (_checkoutStep) {
      case "cart":
        return _buildCartReview(cardBg, textOnSurface, gold);
      case "payment":
        return _buildPaymentSelection(cardBg, textOnSurface, gold);
      case "processing":
        return _buildProcessingState();
      case "pix_success":
        return _buildPixSuccessScreen(cardBg, textOnSurface, gold);
      case "success":
        return _buildApprovedScreen(cardBg, textOnSurface, gold);
      case "failed":
        return _buildRejectedScreen(cardBg, textOnSurface);
      default:
        return Container();
    }
  }

  // 1. REVISÃO DO CARRINHO (Cart Step)
  Widget _buildCartReview(Color cardBg, Color textOnSurface, Color gold) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: gold.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Itens Selecionados",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "1 prato",
                        style: TextStyle(color: gold, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Signature Menu Selection", style: TextStyle(fontSize: 15)),
                      Text("R\$ 380,00", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Entrega (Membro Select)", style: TextStyle(color: textOnSurface.withOpacity(0.6))),
                      Text("Isento", style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Estimado", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("R\$ ${widget.subtotal.toStringAsFixed(2)}", style: TextStyle(color: gold, fontWeight: FontWeight.black, fontSize: 20)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            onPressed: () => setState(() => _checkoutStep = "payment"),
            child: const Text("PROSSEGUIR PARA O PAGAMENTO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  // 2. SELEÇÃO DO PAGAMENTO E FORMULÁRIO (Payment Step)
  Widget _buildPaymentSelection(Color cardBg, Color textOnSurface, Color gold) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Resumo Curto
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: BorderSide(color: gold.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Líquido do Pedido:", style: TextStyle(fontWeight: FontWeight.w500)),
                Text("R\$ ${_total.toStringAsFixed(2)}", style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Seletor Pix vs Cartão
          const Text("Forma de Pagamento", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSelectorCard(
                  title: "Pix",
                  subtitle: "Aprovação imediata",
                  icon: Icons.qr_code_scanner,
                  isSelected: _paymentMethod == "pix",
                  onTap: () => setState(() => _paymentMethod = "pix"),
                  gold: gold,
                  cardBg: cardBg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSelectorCard(
                  title: "Cartão",
                  subtitle: "Crédito ou Débito",
                  icon: Icons.credit_card,
                  isSelected: _paymentMethod == "card",
                  onTap: () => setState(() => _paymentMethod = "card"),
                  gold: gold,
                  cardBg: cardBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_paymentMethod == "pix") ...[
            // Pix Email Input
            Card(
              color: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Dados Pix", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("Você receberá o comprovante neste e-mail:", style: TextStyle(color: textOnSurface.withOpacity(0.5), fontSize: 12)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "E-mail de Cadastro",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      ),
                      onPressed: _processPayment,
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: Text("GERAR PIX DE R\$ ${_total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          ] else ...[
            // Credit Card Form
            Card(
              color: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Cartão de Crédito", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cardNumberController,
                      onChanged: _onCardNumberChanged,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Número do Cartão",
                        placeholder: "0000 0000 0000 0000",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _holderNameController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: "Nome do Titular",
                        placeholder: "NOME IMPRESSO NO CARTÃO",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryController,
                            onChanged: _onExpiryChanged,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Validade",
                              placeholder: "MM/YY",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "CVV",
                              placeholder: "123",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red, size: 16),
                          const SizedBox(width: 6),
                          Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      )
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "💡 Sandbox MP:\n- Use CVV 666 para simular Saldo Insuficiente.\n- Use CVV 777 para simular Recusa por Risco.",
                        style: TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      ),
                      onPressed: _processPayment,
                      icon: const Icon(Icons.shield_outlined, size: 18),
                      label: Text("PAGAR COM CARTÃO SEGURO", style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color gold,
    required Color cardBg,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? gold.withOpacity(0.05) : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: BorderSide(
            color: isSelected ? gold : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? gold : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // 3. ENTRADA DE PROCESSAMENTO (API Loading)
  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880))),
          const SizedBox(height: 24),
          const Text(
            "Processando transação segura...",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "Enviando dados criptografados ao Mercado Pago",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          )
        ],
      ),
    );
  }

  // 4. SUCESSO PIX (Pix Qr Code Copy Page)
  Widget _buildPixSuccessScreen(Color cardBg, Color textOnSurface, Color gold) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text("Aguardando Transferência Pix", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  
                  // QR Code mock visual block
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Icon(Icons.qr_code, size: 120, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    "Clique abaixo para copiar a chave Pix Copia e Cola:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _lastResponse.qrCode ?? ""));
                      setState(() => _isCopied = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: BorderSide(color: Colors.grey.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _lastResponse.qrCode ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Icon(Icons.copy, color: gold, size: 16),
                        ],
                      ),
                    ),
                  ),
                  if (_isCopied) ...[
                    const SizedBox(height: 6),
                    const Text("✓ Chave copiada para área de transferência!", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () {
                      setState(() => _checkoutStep = "success");
                      widget.onOrderConfirmed();
                    },
                    child: const Text("SIMULAR APROVAÇÃO (WEBHOOK)", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // 5. APROVADO SUCESSO (Approved Screen)
  Widget _buildApprovedScreen(Color cardBg, Color textOnSurface, Color gold) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 72),
            const SizedBox(height: 20),
            Text("Aprovação Confirmada! 🥂", style: TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "Seu pagamento foi confirmado com sucesso. O Chef já iniciou a preparação de sua experiência.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("RETORNAR", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // 6. REJEITADO (Rejected Screen)
  Widget _buildRejectedScreen(Color cardBg, Color textOnSurface) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 72),
            const SizedBox(height: 20),
            const Text("Pagamento Recusado", style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              _lastResponse.statusDetail == "cc_rejected_insufficient_amount"
                  ? "Transação recusada pelo Mercado Pago por saldo insuficiente."
                  : "Recusado pelo sistema de antifraude por alto risco de transação.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => setState(() => _checkoutStep = "payment"),
              child: const Text("TENTAR NOVAMENTE"),
            )
          ],
        ),
      ),
    );
  }
}
