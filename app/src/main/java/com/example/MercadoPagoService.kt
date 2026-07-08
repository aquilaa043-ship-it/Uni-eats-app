package com.example

import kotlinx.coroutines.delay
import java.util.UUID

/**
 * MÓDULO DE PAGAMENTO GOURMET - INTEGRAÇÃO MERCADO PAGO
 * 
 * Esta classe simula com alta fidelidade a comunicação com os endpoints oficiais
 * da API do Mercado Pago (v1/payments).
 * 
 * Para produção, utilize o SDK oficial ou requisições HTTP reais usando Retrofit/Ktor
 * apontando para: https://api.mercadopago.com/v1/payments
 */
class MercadoPagoService {

    // CHAVE DE AUTORIZAÇÃO (PRODUÇÃO / SANDBOX)
    // Insira seu Access Token de Produção ou Sandbox gerado no Painel do Desenvolvedor do Mercado Pago
    // Ex: APP_USR-1234567890123456-9abcde...
    private val accessToken = "TEST-ACCESS-TOKEN-EXEMPLO-UNI-EATS"

    enum class PaymentStatus {
        APPROVED, // Aprovado instantaneamente
        PENDING,  // Aguardando pagamento (comum para Pix)
        REJECTED  // Negado (Ex: saldo insuficiente, cartão inválido)
    }

    data class PaymentResponse(
        val paymentId: Long,
        val status: PaymentStatus,
        val statusDetail: String,
        val transactionAmount: Double,
        val qrCode: String? = null,
        val qrCodeBase64: String? = null,
        val paymentMethodId: String
    )

    /**
     * SIMULAÇÃO DE PAGAMENTO VIA PIX (Mercado Pago v1/payments)
     * 
     * Endpoint Real: POST https://api.mercadopago.com/v1/payments
     * Headers:
     *   - Authorization: Bearer <ACCESS_TOKEN>
     *   - Content-Type: application/json
     * 
     * Request Body (JSON esperado pela API):
     * {
     *   "transaction_amount": 380.00,
     *   "description": "Menu Degustação Premium - Uni eats",
     *   "payment_method_id": "pix",
     *   "payer": {
     *     "email": "aquilaa043@gmail.com",
     *     "first_name": "Aquila",
     *     "last_name": "Member",
     *     "identification": {
     *       "type": "CPF",
     *       "number": "12345678909"
     *     }
     *   }
     * }
     */
    suspend fun createPixPayment(amount: Double, payerEmail: String): PaymentResponse {
        // Simula latência de rede para chamada de API
        delay(1500)

        val randomId = (1000000000L..9999999999L).random()
        
        // Chave Pix Copia e Cola gerada dinamicamente simula o padrão EMV BR Code do Banco Central
        val simulatedPixKey = "00020101021226870014br.gov.bcb.pix2565mercadopago.com.br/qr/v2/${UUID.randomUUID().toString().replace("-", "")}5204000053039865405${amount.toInt()}5802BR5915UniEatsGourmet6009SaoPaulo62070503***6304"

        return PaymentResponse(
            paymentId = randomId,
            status = PaymentStatus.PENDING,
            statusDetail = "pending_waiting_transfer",
            transactionAmount = amount,
            qrCode = simulatedPixKey,
            qrCodeBase64 = "BASE64_SIMULATED_QR_CODE",
            paymentMethodId = "pix"
        )
    }

    /**
     * SIMULAÇÃO DE PAGAMENTO VIA CARTÃO DE CRÉDITO (Mercado Pago v1/payments)
     * 
     * Em uma integração real com o Mercado Pago, os dados do cartão NUNCA são enviados
     * diretamente para o backend do lojista. É gerado um "Token de Cartão" (Card Token)
     * via SDK Javascript/Android do Mercado Pago e este token é enviado para a API de pagamentos.
     * 
     * Endpoint Real: POST https://api.mercadopago.com/v1/payments
     * Request Body (JSON esperado pela API):
     * {
     *   "token": "ff8080817c80521e017c8... (Card Token gerado com segurança)",
     *   "transaction_amount": 380.00,
     *   "description": "Reserva Gourmet Uni eats",
     *   "payment_method_id": "mastercard",
     *   "installments": 1,
     *   "payer": {
     *     "email": "aquilaa043@gmail.com"
     *   }
     * }
     */
    suspend fun createCardPayment(
        amount: Double,
        cardNumber: String,
        cardholderName: String,
        expiryDate: String,
        cvv: String,
        installments: Int = 1
    ): PaymentResponse {
        // Simula latência de rede/análise de antifraude do Mercado Pago
        delay(2000)

        val cleanCard = cardNumber.replace(" ", "")
        val paymentId = (1000000000L..9999999999L).random()

        // Regra de simulação inteligente baseada em CVV ou final do cartão
        // Permite testar diferentes fluxos (Sucesso, Recusa, Análise)
        return when {
            cvv == "666" || cleanCard.endsWith("4") -> {
                PaymentResponse(
                    paymentId = paymentId,
                    status = PaymentStatus.REJECTED,
                    statusDetail = "cc_rejected_insufficient_amount",
                    transactionAmount = amount,
                    paymentMethodId = detectCardBrand(cleanCard)
                )
            }
            cvv == "777" || cleanCard.endsWith("7") -> {
                PaymentResponse(
                    paymentId = paymentId,
                    status = PaymentStatus.REJECTED,
                    statusDetail = "cc_rejected_high_risk",
                    transactionAmount = amount,
                    paymentMethodId = detectCardBrand(cleanCard)
                )
            }
            else -> {
                PaymentResponse(
                    paymentId = paymentId,
                    status = PaymentStatus.APPROVED,
                    statusDetail = "accredited",
                    transactionAmount = amount,
                    paymentMethodId = detectCardBrand(cleanCard)
                )
            }
        }
    }

    private fun detectCardBrand(cardNumber: String): String {
        return when {
            cardNumber.startsWith("4") -> "visa"
            cardNumber.startsWith("5") -> "mastercard"
            cardNumber.startsWith("3") -> "amex"
            else -> "credit_card"
        }
    }
}
