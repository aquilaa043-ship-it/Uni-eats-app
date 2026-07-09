/// ====================================================================
/// UNI EATS - ARQUITETURA DE BANCO DE DADOS NOSQL (FIRESTORE) & MODELOS DART
/// ====================================================================
import 'dart:convert';

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

  String toJson() => json.encode(toMap());

  factory UsuarioModel.fromJson(String source) => UsuarioModel.fromMap(json.decode(source));

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

class RestauranteModel {
  final String id;
  final String nomeLugar;
  final String tipoCozinha;
  final int tempoPreparo;
  final String cidade;
  final String statusConexaoMercadoPago;
  final String statusPlano;
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

class PedidoModel {
  final String id;
  final String idCliente;
  final String idRestaurante;
  final String? idMotoboy;
  final List<ItemPedidoModel> itens;
  final double valorProdutos;
  final double taxaEntregaAplicada;
  final double repasseMotoboy;
  final String statusPedido;
  final String formaPagamento;
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

  Map<String, dynamic> toMap() {
    return {
      'id_motoboy': idMotoboy,
      'latitude': latitude,
      'longitude': longitude,
      'ultima_atualizacao': ultimaAtualizacao?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

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
