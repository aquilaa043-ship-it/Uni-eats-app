/// ====================================================================
/// UNI EATS - ARQUITETURA DE BANCO DE DADOS NOSQL (FIRESTORE) & MODELOS DART
/// ====================================================================
/// Este arquivo descreve a modelagem NoSQL / Firebase Firestore para o ecossistema "Uni Eats".
/// Inclui a documentação em formato JSON/NoSQL para cada uma das coleções principais e as
/// respectivas classes de modelo em Dart (Flutter) com suporte bidirecional de conversão
/// (`toMap` e `fromMap`).
///
/// Todas as entidades estão fortemente tipadas para garantir a integridade de dados e a
/// consistência entre o painel de Checkout, o Extrato do Lojista, o Painel do Motoboy,
/// a Carteira do Motoboy, e o Painel do Super Admin.

import 'dart:convert';

// ====================================================================
// DOCUMENTAÇÃO NOSQL / FIRESTORE (JSON EXEMPLO)
// ====================================================================
/*
1. Coleção 'usuarios'
---------------------
Caminho: /usuarios/{id_usuario}
{
  "id": "usr_98317283",
  "nome": "Erick de Souza",
  "email": "erick@example.com",
  "tipo_usuario": "cliente",        // Valores: "cliente", "lojista", "motoboy", "super_admin"
  "telefone": "+5511999999999",
  "cidade": "capital",              // Valores: "capital", "interior" (usado para calcular taxas de frete localizadas)
  "status_assinatura": "ativo",     // Valores: "ativo", "suspenso", "inativo" (painel de controle do Super Admin)
  "criado_em": "2026-07-06T19:32:00Z"
}

2. Coleção 'restaurantes'
-------------------------
Caminho: /restaurantes/{id_restaurante}
{
  "id": "rest_001",
  "nome_lugar": "UniEats Cozinha Premium",
  "tipo_cozinha": "Italiana / Massas Finas",
  "tempo_preparo": 25,               // Tempo estimado de preparo em minutos
  "cidade": "capital",               // Valores: "capital", "interior" (define a cobrança de taxa justa para o entregador)
  "status_conexao_mercado_pago": "conectado", // Valores: "conectado", "pendente", "desconectado"
  "status_plano": "ativo",           // Valores: "ativo", "inativo" (para controle administrativo de inadimplência ou exclusão)
  "criado_em": "2026-07-06T10:00:00Z"
}

3. Coleção 'pedidos'
--------------------
Caminho: /pedidos/{id_pedido}
{
  "id": "ped_5812",
  "id_cliente": "usr_98317283",
  "id_restaurante": "rest_001",
  "id_motoboy": "usr_77218321",      // Inicia como null e é atualizado quando um motoboy aceita a corrida no Painel
  "itens": [
    {
      "nome": "Risoto de Cogumelos Premium",
      "quantidade": 1,
      "preco": 68.90
    },
    {
      "nome": "Vinho Tinto Fino",
      "quantidade": 1,
      "preco": 120.00
    }
  ],
  "valor_produtos": 188.90,
  "taxa_entrega_aplicada": 3.00,     // Taxa cobrada do cliente (Capital: R$ 3,00 | Interior: R$ 2,00)
  "repasse_motoboy": 6.00,           // Repasse integral ao motoboy (Capital: R$ 6,00 | Interior: R$ 4,00)
  "status_pedido": "criado",         // Valores: "criado", "em_preparo", "pronto", "a_caminho", "entregue"
  "forma_pagamento": "mercado_pago_credito", // Valores: "pix", "mercado_pago_credito", "dinheiro"
  "criado_em": "2026-07-06T19:30:00Z"
}

4. Coleção 'localizacao_motoboy'
--------------------------------
Caminho: /localizacao_motoboy/{id_motoboy}
{
  "id_motoboy": "usr_77218321",
  "latitude": -23.550520,
  "longitude": -46.633308,
  "ultima_atualizacao": "2026-07-06T19:32:05Z" // Timestamp para animações e atualização em tempo real de rotas GPS
}
*/

// ====================================================================
// CLASSES DE MODELO DART (FLUTTER)
// ====================================================================

// --------------------------------------------------------------------
// 1. MODELO: USUÁRIO (Cliente, Lojista, Motoboy, Admin)
// --------------------------------------------------------------------
class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String tipoUsuario; // "cliente" | "lojista" | "motoboy" | "super_admin"
  final String telefone;
  final String cidade;      // "capital" | "interior"
  final String statusAssinatura; // "ativo" | "suspenso" | "inativo"
  final DateTime? criadoEm;

  const UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    required this.telefone,
    required this.cidade,
    required this.statusAssinatura,
    this.criadoEm,
  });

  /// Converte o objeto Dart para um Map compatível com NoSQL (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo_usuario': tipoUsuario,
      'telefone': telefone,
      'cidade': cidade,
      'status_assinatura': statusAssinatura,
      'criado_em': criadoEm?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  /// Fábrica que cria um objeto Dart a partir de um documento NoSQL (Map do Firestore)
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      tipoUsuario: map['tipo_usuario'] ?? 'cliente',
      telefone: map['telefone'] ?? '',
      cidade: map['cidade'] ?? 'capital',
      statusAssinatura: map['status_assinatura'] ?? 'inativo',
      criadoEm: map['criado_em'] != null ? DateTime.tryParse(map['criado_em']) : null,
    );
  }

  /// Utilitário para converter o modelo para string JSON
  String toJson() => json.encode(toMap());

  /// Utilitário para parsear o modelo a partir de uma string JSON
  factory UsuarioModel.fromJson(String source) => UsuarioModel.fromMap(json.decode(source));

  /// Método CopyWith para mutabilidade fluida (comum no gerenciamento de estado do Flutter)
  UsuarioModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? tipoUsuario,
    String? telefone,
    String? cidade,
    String? statusAssinatura,
    DateTime? criadoEm,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      telefone: telefone ?? this.telefone,
      cidade: cidade ?? this.cidade,
      statusAssinatura: statusAssinatura ?? this.statusAssinatura,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  String toString() {
    return 'UsuarioModel(id: $id, nome: $nome, tipoUsuario: $tipoUsuario, cidade: $cidade, statusAssinatura: $statusAssinatura)';
  }
}

// --------------------------------------------------------------------
// 2. MODELO: RESTAURANTE
// --------------------------------------------------------------------
class RestauranteModel {
  final String id;
  final String nomeLugar;
  final String tipoCozinha;
  final int tempoPreparo; // em minutos
  final String cidade; // "capital" | "interior" (afeta a lógica de taxas descrita nas telas)
  final String statusConexaoMercadoPago; // "conectado" | "pendente" | "desconectado"
  final String statusPlano; // "ativo" | "inativo"
  final DateTime? criadoEm;

  const RestauranteModel({
    required this.id,
    required this.nomeLugar,
    required this.tipoCozinha,
    required this.tempoPreparo,
    required this.cidade,
    required this.statusConexaoMercadoPago,
    required this.statusPlano,
    this.criadoEm,
  });

  /// Converte para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_lugar': nomeLugar,
      'tipo_cozinha': tipoCozinha,
      'tempo_preparo': tempoPreparo,
      'cidade': cidade,
      'status_conexao_mercado_pago': statusConexaoMercadoPago,
      'status_plano': statusPlano,
      'criado_em': criadoEm?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  /// Instancia a partir do Firestore
  factory RestauranteModel.fromMap(Map<String, dynamic> map) {
    return RestauranteModel(
      id: map['id'] ?? '',
      nomeLugar: map['nome_lugar'] ?? '',
      tipoCozinha: map['tipo_cozinha'] ?? '',
      tempoPreparo: map['tempo_preparo']?.toInt() ?? 0,
      cidade: map['cidade'] ?? 'capital',
      statusConexaoMercadoPago: map['status_conexao_mercado_pago'] ?? 'desconectado',
      statusPlano: map['status_plano'] ?? 'inativo',
      criadoEm: map['criado_em'] != null ? DateTime.tryParse(map['criado_em']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RestauranteModel.fromJson(String source) => RestauranteModel.fromMap(json.decode(source));

  RestauranteModel copyWith({
    String? id,
    String? nomeLugar,
    String? tipoCozinha,
    int? tempoPreparo,
    String? cidade,
    String? statusConexaoMercadoPago,
    String? statusPlano,
    DateTime? criadoEm,
  }) {
    return RestauranteModel(
      id: id ?? this.id,
      nomeLugar: nomeLugar ?? this.nomeLugar,
      tipoCozinha: tipoCozinha ?? this.tipoCozinha,
      tempoPreparo: tempoPreparo ?? this.tempoPreparo,
      cidade: cidade ?? this.cidade,
      statusConexaoMercadoPago: statusConexaoMercadoPago ?? this.statusConexaoMercadoPago,
      statusPlano: statusPlano ?? this.statusPlano,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  String toString() {
    return 'RestauranteModel(id: $id, nomeLugar: $nomeLugar, cidade: $cidade, statusConexaoMercadoPago: $statusConexaoMercadoPago, statusPlano: $statusPlano)';
  }
}

// --------------------------------------------------------------------
// MODELO AUXILIAR: ITEM DE PEDIDO (Sub-objeto do Pedido)
// --------------------------------------------------------------------
class ItemPedidoModel {
  final String nome;
  final int quantidade;
  final double preco;

  const ItemPedidoModel({
    required this.nome,
    required this.quantidade,
    required this.preco,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'preco': preco,
    };
  }

  factory ItemPedidoModel.fromMap(Map<String, dynamic> map) {
    return ItemPedidoModel(
      nome: map['nome'] ?? '',
      quantidade: map['quantidade']?.toInt() ?? 0,
      preco: map['preco']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemPedidoModel.fromJson(String source) => ItemPedidoModel.fromMap(json.decode(source));

  @override
  String toString() => 'ItemPedidoModel(nome: $nome, quantidade: $quantidade, preco: $preco)';
}

// --------------------------------------------------------------------
// 3. MODELO: PEDIDO
// --------------------------------------------------------------------
class PedidoModel {
  final String id;
  final String idCliente;
  final String idRestaurante;
  final String? idMotoboy; // Nullable: Permite que o pedido seja criado e ofertado antes do aceite do motoboy
  final List<ItemPedidoModel> itens;
  final double valorProdutos;
  final double taxaEntregaAplicada; // Taxa de entrega do cliente (R$ 2.00 ou R$ 3.00)
  final double repasseMotoboy;      // Ganho garantido do entregador (R$ 4.00 ou R$ 6.00)
  final String statusPedido;        // "criado" | "em_preparo" | "pronto" | "a_caminho" | "entregue"
  final String formaPagamento;      // "pix" | "mercado_pago_credito" | "dinheiro"
  final DateTime? criadoEm;

  const PedidoModel({
    required this.id,
    required this.idCliente,
    required this.idRestaurante,
    this.idMotoboy,
    required this.itens,
    required this.valorProdutos,
    required this.taxaEntregaAplicada,
    required this.repasseMotoboy,
    required this.statusPedido,
    required this.formaPagamento,
    this.criadoEm,
  });

  /// Converte para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_cliente': idCliente,
      'id_restaurante': idRestaurante,
      'id_motoboy': idMotoboy,
      'itens': itens.map((x) => x.toMap()).toList(),
      'valor_produtos': valorProdutos,
      'taxa_entrega_aplicada': taxaEntregaAplicada,
      'repasse_motoboy': repasseMotoboy,
      'status_pedido': statusPedido,
      'forma_pagamento': formaPagamento,
      'criado_em': criadoEm?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  /// Instancia a partir do Firestore
  factory PedidoModel.fromMap(Map<String, dynamic> map) {
    return PedidoModel(
      id: map['id'] ?? '',
      idCliente: map['id_cliente'] ?? '',
      idRestaurante: map['id_restaurante'] ?? '',
      idMotoboy: map['id_motoboy'],
      itens: map['itens'] != null
          ? List<ItemPedidoModel>.from(map['itens'].map((x) => ItemPedidoModel.fromMap(x)))
          : [],
      valorProdutos: map['valor_produtos']?.toDouble() ?? 0.0,
      taxaEntregaAplicada: map['taxa_entrega_aplicada']?.toDouble() ?? 0.0,
      repasseMotoboy: map['repasse_motoboy']?.toDouble() ?? 0.0,
      statusPedido: map['status_pedido'] ?? 'criado',
      formaPagamento: map['forma_pagamento'] ?? 'mercado_pago_credito',
      criadoEm: map['criado_em'] != null ? DateTime.tryParse(map['criado_em']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PedidoModel.fromJson(String source) => PedidoModel.fromMap(json.decode(source));

  PedidoModel copyWith({
    String? id,
    String? idCliente,
    String? idRestaurante,
    String? idMotoboy,
    List<ItemPedidoModel>? itens,
    double? valorProdutos,
    double? taxaEntregaAplicada,
    double? repasseMotoboy,
    String? statusPedido,
    String? formaPagamento,
    DateTime? criadoEm,
  }) {
    return PedidoModel(
      id: id ?? this.id,
      idCliente: idCliente ?? this.idCliente,
      idRestaurante: idRestaurante ?? this.idRestaurante,
      idMotoboy: idMotoboy ?? this.idMotoboy,
      itens: itens ?? this.itens,
      valorProdutos: valorProdutos ?? this.valorProdutos,
      taxaEntregaAplicada: taxaEntregaAplicada ?? this.taxaEntregaAplicada,
      repasseMotoboy: repasseMotoboy ?? this.repasseMotoboy,
      statusPedido: statusPedido ?? this.statusPedido,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  String toString() {
    return 'PedidoModel(id: $id, status: $statusPedido, total: R\$ $valorProdutos, taxa: R\$ $taxaEntregaAplicada, repasse: R\$ $repasseMotoboy)';
  }
}

// --------------------------------------------------------------------
// 4. MODELO: LOCALIZAÇÃO DO MOTOBOY (GPS em Tempo Real)
// --------------------------------------------------------------------
class LocalizacaoMotoboyModel {
  final String idMotoboy;
  final double latitude;
  final double longitude;
  final DateTime? ultimaAtualizacao;

  const LocalizacaoMotoboyModel({
    required this.idMotoboy,
    required this.latitude,
    required this.longitude,
    this.ultimaAtualizacao,
  });

  /// Converte para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'id_motoboy': idMotoboy,
      'latitude': latitude,
      'longitude': longitude,
      'ultima_atualizacao': ultimaAtualizacao?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  /// Instancia a partir do Firestore
  factory LocalizacaoMotoboyModel.fromMap(Map<String, dynamic> map) {
    return LocalizacaoMotoboyModel(
      idMotoboy: map['id_motoboy'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      ultimaAtualizacao: map['ultima_atualizacao'] != null
          ? DateTime.tryParse(map['ultima_atualizacao'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalizacaoMotoboyModel.fromJson(String source) => LocalizacaoMotoboyModel.fromMap(json.decode(source));

  LocalizacaoMotoboyModel copyWith({
    String? idMotoboy,
    double? latitude,
    double? longitude,
    DateTime? ultimaAtualizacao,
  }) {
    return LocalizacaoMotoboyModel(
      idMotoboy: idMotoboy ?? this.idMotoboy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  String toString() {
    return 'LocalizacaoMotoboyModel(idMotoboy: $idMotoboy, lat: $latitude, lng: $longitude)';
  }
}

// ====================================================================
// COMPREENSÃO ARQUITETURAL: CONEXÃO COM AS TELAS ANTERIORES
// ====================================================================
///
/// 1. Checkout & Criação de Pedidos (AcompanhamentoPedidoModule & CheckoutSimuladoModule)
///    - Ao concluir a compra no `CheckoutSimuladoModule`, o app gera uma instância de `PedidoModel`
///      com 'id_motoboy' inicialmente como NULL. O 'status_pedido' é inserido como "criado".
///    - A 'taxa_entrega_aplicada' e o 'repasse_motoboy' são calculados com base no tipo de cidade
///      do restaurante (`RestauranteModel.cidade`), lido de forma cruzada a partir da coleção `/restaurantes`.
///
/// 2. Extrato Lojista & Repasses (ExtratoLojistaModule)
///    - O `ExtratoLojistaModule` monitora em tempo real a coleção `/pedidos` onde `id_restaurante`
///      corresponde ao ID do lojista ativo.
///    - Quando o pedido atinge o status "entregue", a transação é computada no faturamento
///      da loja. O repasse que o lojista recebe é de 100% do valor do produto (`valor_produtos`),
///      enquanto a taxa de entrega (`taxa_entrega_aplicada`) é preservada para repasse integral
///      ao entregador parceiro através da rede segura de liquidação.
///
/// 3. Painel do Motoboy, GPS & Aceite (MotoboyDeliveryModule & CarteiraMotoboyModule)
///    - O `MotoboyDeliveryModule` faz uma query reativa (Snapshot Stream) no Firestore buscando
///      pedidos na cidade correspondente com status "criado" e `id_motoboy` nulo (ou seja, ofertas ativas).
///    - No momento em que o entregador clica em "ACEITAR", o status do pedido muda para "em_preparo"
///      e o campo `id_motoboy` do `PedidoModel` é atualizado para o ID do entregador logado (`UsuarioModel.id`).
///    - Durante a rota, o timer simula atualizações de coordenadas gravando na coleção
///      `/localizacao_motoboy` com o respectivo ID do motoboy. A tela do cliente (`AcompanhamentoPedidoModule`)
///      escuta esse documento de localização reativamente para redesenhar a posição do ícone da moto 🏍️ no mapa.
///
/// 4. Super Admin (SuperAdminModule)
///    - O painel administrativo consome dados agregados de todas as coleções:
///      - `/usuarios`: para alterar o `status_assinatura` dos lojistas ou banir contas irregulares.
///      - `/restaurantes`: para monitorar quais estabelecimentos possuem conexões ativas com o gateway.
///      - `/pedidos`: para somar o volume financeiro transacionado e gerar as métricas de faturamento global.
///
