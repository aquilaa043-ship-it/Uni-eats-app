# UNIEATS & UNILINK - ARQUITETURA DE UNIFICAÇÃO DE ECOSSISTEMA
## Especificação Técnica: Delivery SaaS com Infraestrutura de Rede Mesh e Carteira Digital Offline
**Versão:** 1.0.0  
**Autor:** Arquiteto de Software Principal / CTO  
**Status:** Aprovado para Implementação

---

## SUMÁRIO

1. [Visão Geral do Ecossistema Integrado](#1-visão-geral-do-ecossistema-integrado)
2. [Arquitetura de Microsserviços e Gateway de Pagamentos](#2-arquitetura-de-microsserviços-e-gateway-de-pagamentos)
3. [Segurança, Criptografia e Validação Offline (Rede Mesh)](#3-segurança-criptografia-e-validação-offline-rede-mesh)
4. [Consistência Eventual e Resolução de Conflitos de Saldo](#4-consistência-eventual-e-resolução-de-conflitos-de-saldo)
5. [Modelo de Dados Unificado (Database Schema)](#5-modelo-de-dados-unificado-database-schema)
6. [Roadmap de Desenvolvimento e Execução Técnica](#6-roadmap-de-desenvolvimento-e-execução-técnica)

---

## 1. VISÃO GERAL DO ECOSSISTEMA INTEGRADO

O ecossistema unificado é composto por duas camadas distintas e complementares:
* **UniEats:** A aplicação de mercado (Delivery SaaS), responsável pela experiência do usuário, catálogos de produtos, carrinho de compras, logística justa regionalizada, controle de rotas de motoboys e o Painel Super Admin.
* **UniLink:** A infraestrutura de base física e financeira. Opera como uma **Rede Mesh Ad-Hoc** descentralizada (usando conexões BLE e Wi-Fi Direct locais), provendo canais de comunicação descentralizados, custódia e liquidação de valores, e uma **Carteira Digital Offline-First** com suporte a cashback reativo.

Neste modelo de design, o **UniLink atua como o motor financeiro e de transporte de dados do UniEats**. Em cenários sem conectividade com a internet, as transações financeiras e de rastreio de entrega são transportadas de nó em nó físico na malha Mesh do UniLink até atingirem um nó gateway (com conexão à internet estável) para sincronização global reativa com o Firebase.

---

## 2. ARQUITETURA DE MICROSSERVIÇOS E GATEWAY DE PAGAMENTOS

Para garantir escalabilidade, o UniEats e o UniLink são completamente desacoplados. O UniEats consome um **Payment Gateway API** abstraído que mascara o comportamento de transporte da rede física subjacente.

```
+----------------------------------------+
|               UniEats App              |
+----------------------------------------+
                    |
                    | (API REST / Local SDK Call)
                    ▼
+----------------------------------------+
|          Payment Gateway API           |
+----------------------------------------+
                    |
          +---------+---------+
          |                   |
          ▼                   ▼
  [Online Adapter]     [Mesh Adapter]
          |                   |
          ▼                   ▼
  (Mercado Pago PIX)   (UniLink Wallet)
```

### 2.1. Contrato da API de Pagamentos (Atomização e Idempotência)

A fim de prevenir duplicidade de gastos (*double-spending*) ou perda de dados em transações financeiras, o contrato impõe o uso de uma **Chave de Idempotência UUIDv4** gerada na origem do pedido.

#### Endpoint: `POST /api/v1/payments/charge`

##### Request Payload (JSON)
```json
{
  "idempotency_key": "7b8e5c1a-82bc-4fa8-b21a-e8379201cf2c",
  "order_id": "ped_928374829",
  "customer_id": "usr_cliente_abc123",
  "merchant_id": "rest_lojista_xyz789",
  "amount": 25.80,
  "currency": "BRL",
  "payment_method": "unilink_wallet",
  "metadata": {
    "delivery_city_type": "interior",
    "frete_amount": 4.00,
    "split_rules": {
      "merchant_shares_percent": 100.0,
      "saas_fee_fixed": 0.80,
      "delivery_fee_fixed": 4.00
    }
  }
}
```

##### Response Payload - Sucesso (JSON)
```json
{
  "transaction_id": "tx_unilink_998317263",
  "idempotency_key": "7b8e5c1a-82bc-4fa8-b21a-e8379201cf2c",
  "status": "APPROVED",
  "auth_code": "SIG_M3SH_dB817A92F26C42...",
  "current_balance": 142.50,
  "cashback_accrued": 1.29,
  "timestamp": "2026-07-07T23:38:12Z"
}
```

##### Response Payload - Erro / Saldo Insuficiente (JSON)
```json
{
  "error_code": "INSUFFICIENT_FUNDS",
  "message": "Saldo insuficiente na carteira UniLink.",
  "idempotency_key": "7b8e5c1a-82bc-4fa8-b21a-e8379201cf2c",
  "timestamp": "2026-07-07T23:38:13Z"
}
```

---

## 3. SEGURANÇA, CRIPTOGRAFIA E VALIDAÇÃO OFFLINE (REDE MESH)

Em uma rede Mesh offline, a comunicação com uma autoridade centralizadora de autenticação (como o Firebase Auth) não está imediatamente disponível. Para mitigar fraudes e manipulação de saldos locais, a validação baseia-se em **Criptografia de Chave Assimétrica Local (Ed25519)**.

```
       [Dispositivo Cliente]                       [Dispositivo Lojista]
                 |                                           |
    1. Assina transação offline                              |
       com Chave Privada Cliente                             |
                 |                                           |
                 |----- (Transação + Assinatura Ed25519) ---->|
                 |                                           |
                 |                               2. Valida assinatura localmente
                 |                                  usando a Chave Pública do Cliente
                 |                                  armazenada em cache Mesh.
                 |                                           |
                 |                               3. Se OK, processa o pedido.
```

### 3.1. Processo de Transação Criptografada Offline
1. **Geração do Par de Chaves:** No momento em que o usuário se cadastra no UniEats/UniLink online, um par de chaves assimétricas (Pública/Privada) Ed25519 é gerado no hardware de segurança do dispositivo (Android Keystore / iOS Keychain). A chave pública é persistida no Firestore.
2. **Sincronização de Chaves Públicas na Mesh:** Os nós da rede Mesh propagam localmente tabelas indexadas contendo as Chaves Públicas e o último estado consolidado conhecido dos saldos dos usuários geograficamente próximos.
3. **Assinatura Digital Local:** Ao realizar uma compra offline, o app do cliente assina uma estrutura binária rígida contendo o `idempotency_key`, `amount`, `customer_id`, e `order_id` utilizando sua **Chave Privada**.
4. **Verificação Descentralizada:** O dispositivo do restaurante recebe essa transação assinada via BLE. Utilizando a **Chave Pública** do cliente, o restaurante valida criptograficamente a transação localmente e aceita o pedido de forma imediata e blindada contra fraudes.

---

## 4. CONSISTÊNCIA EVENTUAL E RESOLUÇÃO DE CONFLITOS DE SALDO

Dado que os saldos podem sofrer alterações enquanto os nós estão operando de forma isolada na malha offline, adotamos uma estratégia baseada em **CRDTs (Conflict-free Replicated Data Types)**, especificamente um tipo PN-Counter (Positive-Negative Counter) suportando operações aditivas e subtrativas estruturadas em formato de **Log de Eventos Imutável**.

### 4.1. Algoritmo de Resolução de Conflitos (Eventual Consistency)

Em vez de atualizar diretamente um valor de saldo flutuante bruto (ex: `saldo = 100.00`), o sistema armazena uma cadeia sequencial imutável de transações (Append-Only Log), onde cada bloco contém:
* `sequence_number` (Contador sequencial único por usuário)
* `cryptographic_signature` (Verificação do nó originador)
* `timestamp` (Tempo lógico de Lamport para sequenciamento correto de eventos concorrentes)

```kotlin
class MeshLedgerEngine {
  // Resolução de Conflitos de Saldo Baseado em Merge de Logs Imutáveis
  fun mergeLedgers(localLog: List<Transaction>, incomingLog: List<Transaction>): List<Transaction> {
    val mergedMap = mutableMapOf<String, Transaction>()
    
    // Insere registros locais no mapa de deduplicação usando o hash hashID como chave
    localLog.forEach { tx -> mergedMap[tx.idempotencyKey] = tx }
    
    // Insere registros entrantes resolvendo duplicidades
    incomingLog.forEach { tx ->
      if (!mergedMap.containsKey(tx.idempotencyKey)) {
        mergedMap[tx.idempotencyKey] = tx
      } else {
        // Conflito de Idempotência: Manter a transação com assinatura criptográfica válida mais antiga
        val existingTx = mergedMap[tx.idempotencyKey]!!
        if (tx.logicalTimestamp < existingTx.logicalTimestamp) {
          mergedMap[tx.idempotencyKey] = tx
        }
      }
    }
    
    // Ordena o livro contábil resultante por tempo lógico de Lamport
    return mergedMap.values.sortedBy { it.logicalTimestamp }
  }

  fun calcularSaldoConsolidado(ledger: List<Transaction>): Double {
    var saldoCalculado = 0.0
    ledger.forEach { tx ->
      if (tx.type == TransactionType.DEPOSIT || tx.type == TransactionType.CASHBACK_EARNED) {
        saldoCalculado += tx.amount
      } else if (tx.type == TransactionType.WITHDRAWAL || tx.type == TransactionType.PURCHASE) {
        saldoCalculado -= tx.amount
      }
    }
    return saldoCalculado;
  }
}
```

---

## 5. MODELO DE DADOS UNIFICADO (DATABASE SCHEMA)

A modelagem de dados estende a estrutura original do UniEats para acomodar a tabela contábil local do UniLink e mapear os fluxos físicos e os diversos métodos de checkout da plataforma.

```
                      [ Coleção Principal: usuarios ]
                      ├── id (UID)
                      ├── tipo_usuario ("cliente" | "lojista" | "motoboy")
                      └── carteira (Objeto Aninhado)
                          ├── public_key (Ed25519 em Base64)
                          ├── saldo_corrente_online (Double)
                          └── cashback_acumulado (Double)
                                     │
                                     ├── (Associação 1:N)
                                     ▼
                    [ Coleção Contábil: unilink_ledger ]
                    ├── id (ID Único da Operação)
                    ├── idempotency_key (UUIDv4)
                    ├── user_id (UID)
                    ├── amount (Double)
                    ├── type ("deposit" | "purchase" | "cashback_earned")
                    ├── lamport_timestamp (Int)
                    ├── cryptographic_signature (String)
                    ├── status_sincronizacao ("pendente" | "sincronizado")
                    └── gateway_node_id (String - ID do nó que sincronizou)
                                     │
                                     ├── (Vínculo com Pedido 1:1)
                                     ▼
                     [ Coleção Reativa: pedidos ]
                     ├── id (ID do Pedido)
                     ├── id_cliente (UID)
                     ├── id_restaurante (UID)
                     ├── valor_produtos (Mínimo de R$ 15,00)
                     ├── forma_pagamento ("unilink_wallet" | "mercado_pago_pix")
                     ├── transacao_financeira_id (ID da unilink_ledger ou MP)
                     └── status_pedido ("criado" | "preparando" | "entregue")
```

---

## 6. ROADMAP DE DESENVOLVIMENTO E EXECUÇÃO TÉCNICA

Para mitigar riscos e assegurar a blindagem do fluxo financeiro do ecossistema, o desenvolvimento será executado em **4 fases estruturadas**:

```
[ Fase 1: Core & SDK ] ──► [ Fase 2: Local Mesh ] ──► [ Fase 3: Gateway Sync ] ──► [ Fase 4: Piloto ]
```

### Fase 1: Core Financeiro & Abstração de Pagamentos (Semanas 1 e 2)
* **Objetivo:** Estabelecer a infraestrutura de dados local e os contratos de microsserviços.
* **Entregáveis:**
  - Implementação do banco de dados local Room/SQLite do UniLink para armazenamento do ledger imutável.
  - Implementação do gerador e validador de chaves assimétricas Ed25519 no app Android/iOS.
  - Testes unitários do motor de cálculo de saldo com injeção de transações concorrentes.

### Fase 2: Protocolos de Comunicação Mesh Local (Semanas 3 e 4)
* **Objetivo:** Estabelecer canais estáveis e seguros de comunicação descentralizada entre os dispositivos.
* **Entregáveis:**
  - Desenvolvimento do driver de Bluetooth Low Energy (BLE) e Wi-Fi Direct no SDK do UniLink.
  - Protocolo de handshake local para validação cruzada de assinaturas de pagamento em menos de 1.5 segundos.
  - Testes físicos de transmissão de dados entre 3 aparelhos simulando "Cliente - Restaurante - Motoboy" offline.

### Fase 3: Motor de Sincronização e Resolução de Conflitos (Semanas 5 e 6)
* **Objetivo:** Garantir a consistência de saldo ao reconectar os dispositivos à internet.
* **Entregáveis:**
  - Implementação do algoritmo CRDT Lamport-Timestamp no Firebase Cloud Functions.
  - Mecanismo automático de varredura (*Background Sync Task*) no aplicativo para envio de transações pendentes.
  - Lógica de fallback contra double-spending (trava temporária de saldo de alta frequência).

### Fase 4: Integração de UI, Testes de Carga e Piloto Comercial (Semanas 7 e 8)
* **Objetivo:** Unificar visualmente as ferramentas, rodar simulação de alta escala e lançar em campo.
* **Entregáveis:**
  - Conexão do módulo de checkout do UniEats à carteira UniLink.
  - Teste de carga simulando 5.000 transações concorrentes offline sendo resolvidas simultaneamente.
  - Lançamento piloto controlado em campus universitário (ambiente fechado propício para teste de baixa cobertura de internet).
