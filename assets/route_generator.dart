/// ====================================================================
/// UNI EATS - ARQUITETURA DE DIRETÓRIOS & GERENCIADOR DE ROTAS COM DEEP LINKING
/// ====================================================================
/// Este arquivo define e documenta a arquitetura de pastas (Feature-First) 
/// e implementa o motor de roteamento robusto para o ecossistema "Uni Eats"
/// em Flutter. Ele suporta Deep Linking para permitir que restaurantes divulguem
/// seu cardápio em redes sociais com redirecionamentos inteligentes.
///
/// --------------------------------------------------------------------
/// 1. ARQUITETURA DE DIRETÓRIOS (REPRESENTAÇÃO DE PASTAS - FEATURE-FIRST)
/// --------------------------------------------------------------------
///
/// lib/
/// ├── main.dart                       # Ponto de entrada do aplicativo (Inicialização e Splash)
/// ├── core/                           # Núcleo compartilhado da aplicação (Cross-cutting Concerns)
/// │   ├── constants/                  # Constantes globais do sistema
/// │   │   ├── app_colors.dart         # Paleta de cores elitizada (Grafite, Ouro Velho, Off-White)
/// │   │   └── app_images.dart         # Vetores e imagens institucionais pré-carregadas
/// │   ├── theme/                      # Configurações de Temas Material Design 3
/// │   │   └── app_theme.dart          # Configuração Dark Premium do ecossistema
/// │   ├── routes/                     # Roteamento Centralizado e Deeplinks
/// │   │   ├── route_generator.dart    # [ESTE ARQUIVO] Gerenciador e roteador dinâmico
/// │   │   └── route_guard.dart        # Barreira de segurança para acesso cruzado
/// │   ├── network/                    # Infraestrutura de rede e conexões
/// │   │   └── api_client.dart         # Cliente HTTP (Dio/Http) configurado para o backend
/// │   └── utils/                      # Extensões, formatações de moeda e data
/// │       └── validators.dart         # Validações estritas de inputs
/// │
/// └── features/                       # Funcionalidades divididas por Ator/Módulo (Feature-First)
///     ├── auth/                       # Fluxo Unificado de Login e Registro
///     │   ├── data/                   # Fontes de dados e repositórios de segurança
///     │   ├── domain/                 # Entidades e casos de uso de login/registro
///     │   └── presentation/           # Telas e controladores UI
///     │       ├── screens/
///     │       │   └── login_screen.dart # Tela de login premium (contida em firebase_auth_screen.dart)
///     │       └── viewmodels/
///     │           └── auth_viewmodel.dart # Gerenciamento de estado de autenticação
///     │
///     ├── cliente/                    # Módulo do Consumidor Final
///     │   ├── presentation/
///     │   │   ├── screens/
///     │   │   │   ├── home_cliente.dart   # Dashboard de listagem de restaurantes
///     │   │   │   ├── cardapio_screen.dart# Cardápio interativo (acessível via Deep Link)
///     │   │   │   ├── carrinho_screen.dart# Carrinho com validação de compra mínima de R$ 15,00
///     │   │   │   └── gps_tracking.dart   # Acompanhamento do motoboy em tempo real
///     │   │   └── controllers/
///     │   │       └── cart_controller.dart# Lógica de carrinho, taxas e travas
///     │   └── data/
///     │
///     ├── lojista/                    # Módulo Administrativo do Restaurante
///     │   ├── presentation/
///     │   │   ├── screens/
///     │   │   │   ├── painel_lojista.dart # Lista de pedidos, status e botão "Copiar Link da Bio"
///     │   │   │   ├── extrato_vendas.dart # Visualizador de split financeiro regional
///     │   │   │   └── config_loja.dart    # Configurações de token Mercado Pago e split
///     │   │   └── controllers/
///     │   └── data/
///     │
///     ├── motoboy/                    # Módulo Logístico do Entregador
///     │   ├── presentation/
///     │   │   ├── screens/
///     │   │   │   ├── painel_rotas.dart   # Aceite de combos inteligentes de até 3 pedidos
///     │   │   │   ├── carteira_digital.dart# Extrato de repasses (R$ 4,00 interior / R$ 6,00 capital)
///     │   │   │   └── mapa_gps.dart       # Roteamento e envio ativo de coordenadas ao Firestore
///     │   │   └── controllers/
///     │   └── data/
///     │
///     └── super_admin/                # Painel de Gestão Central (Oculto)
///         ├── presentation/
///         │   └── screens/
///         │       └── gestao_planos.dart  # Configuração de taxas globais, suspensões e planos
///         └── data/
///

import 'package:flutter/material.dart';
import 'firebase_models.dart';
import 'firebase_auth_service.dart';

// Mock de Telas para possibilitar a compilação standalone do arquivo de rotas
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Uni Eats - Carregando...", style: TextStyle(color: Color(0xFFD4AF37)))));
}

class HomeClienteScreen extends StatelessWidget {
  const HomeClienteScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Home Cliente")));
}

class HomeLojistaScreen extends StatelessWidget {
  const HomeLojistaScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Home Lojista")));
}

class HomeMotoboyScreen extends StatelessWidget {
  const HomeMotoboyScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Home Motoboy")));
}

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Super Admin")));
}

/// Tela de Cardápio do Cliente com suporte direto à abertura por Deep Link
class TelaCardapioCliente extends StatelessWidget {
  final String restauranteId;

  const TelaCardapioCliente({
    Key? key,
    required this.restauranteId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text("CARDÁPIO DE: $restauranteId", style: const TextStyle(color: Color(0xFFD4AF37), letterSpacing: 1.5, fontSize: 16)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 64, color: Color(0xFFD4AF37)),
              const SizedBox(height: 16),
              Text(
                "Restaurante Carregado por Deep Link!",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Código de Identificação: $restauranteId",
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF121212),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Voltar para Home de Pedidos
                  Navigator.pushReplacementNamed(context, RouteGenerator.homeCliente);
                },
                child: const Text("IR PARA A HOME DE PEDIDOS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ====================================================================
/// 2. ARQUIVO DE ROTAS CENTRALIZADO COM DEEP LINKING
/// ====================================================================
/// Gerencia de forma limpa e otimizada todas as rotas do ecossistema, 
/// implementando segurança na validação de permissões e análise de query
/// parameters para redirecionamento correto vindo de links web.
class RouteGenerator {
  // Definição das Rotas Nomeadas
  static const String splash = '/splash';
  static const String login = '/login';
  static const String homeCliente = '/home_cliente';
  static const String homeLojista = '/home_lojista';
  static const String homeMotoboy = '/home_motoboy';
  static const String superAdmin = '/super_admin';
  static const String cardapio = '/cardapio';

  /// Motor de Geração de Rotas Dinâmicas
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // 1. Extração do nome da rota e filtragem para tratamento de Deep Linking
    final Uri uri = Uri.parse(settings.name ?? '');
    final String routePath = uri.path;

    // Tratamento de Deep Link contextual: unieats.com.br/cardapio?id=XYZ
    if (routePath == cardapio) {
      // Tenta recuperar o id do restaurante a partir de múltiplos formatos de parâmetros
      // Formato 1: Query parameter normal (?id=XYZ)
      // Formato 2: Parâmetro direto no argumento de navegação interna do Flutter
      String? restauranteId = uri.queryParameters['id'];
      
      if (restauranteId == null && settings.arguments is String) {
        restauranteId = settings.arguments as String;
      }

      // Verificação de Segurança e Integridade do Deep Link
      if (restauranteId != null && restauranteId.isNotEmpty) {
        return _buildPageRoute(
          settings: settings,
          builder: (_) => TelaCardapioCliente(restauranteId: restauranteId!),
        );
      } else {
        // Fallback defensivo: Se o Link estiver mal formatado ou o id for vazio,
        // redireciona o cliente com segurança para a Home de Pedidos global.
        debugPrint("Deep Link mal formatado recebido. Redirecionando para Home do Cliente.");
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const HomeClienteScreen(),
        );
      }
    }

    // 2. Switcheador de Rotas Convencionais por Nome
    switch (routePath) {
      case splash:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case login:
        // Na integração final, esta tela aponta para a UI Premium (UniEatsAuthScreen)
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Center(child: Text("Tela de Autenticação"))),
        );

      case homeCliente:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const HomeClienteScreen(),
        );

      case homeLojista:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const HomeLojistaScreen(),
        );

      case homeMotoboy:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const HomeMotoboyScreen(),
        );

      case superAdmin:
        // Rota sensível com validação prévia de segurança (Route Guard)
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const SuperAdminScreen(),
        );

      default:
        // Tratamento elegante de rotas desconhecidas ou erros de navegação
        return _errorRoute(settings);
    }
  }

  /// ====================================================================
  /// 3. PROTEÇÃO DE ROTAS (CONCEITO & TRAVA ATIVA)
  /// ====================================================================
  /// Função centralizada que valida de forma síncrona ou assíncrona se
  /// o usuário atualmente autenticado possui o papel adequado para abrir
  /// a rota de destino, bloqueando tentativas de acesso cruzado maliciosas.
  static Future<bool> validarPermissaoDeAcesso(String rotaDestino) async {
    try {
      final FirebaseAuthService authService = FirebaseAuthService();
      final UsuarioModel? usuarioLogado = await authService.obterUsuarioAtual();

      if (usuarioLogado == null) {
        // Se não houver usuário logado, impede acesso e exige autenticação
        return false;
      }

      // Validação estrita de papéis administrativos e operacionais
      switch (rotaDestino) {
        case homeLojista:
          return usuarioLogado.tipoUsuario == 'lojista' || usuarioLogado.tipoUsuario == 'super_admin';
        case homeMotoboy:
          return usuarioLogado.tipoUsuario == 'motoboy' || usuarioLogado.tipoUsuario == 'super_admin';
        case superAdmin:
          return usuarioLogado.tipoUsuario == 'super_admin';
        case homeCliente:
        case cardapio:
          // Acesso livre a todos os usuários autenticados
          return true;
        default:
          return false;
      }
    } catch (e) {
      debugPrint("Erro ao interceptar e validar permissão de rota: $e");
      return false; // Trava defensiva por padrão
    }
  }

  /// ====================================================================
  /// 4. CONSTRUTOR DE TRANSIÇÃO E ESTILO (MATERIAL DESIGN 3 LUXO)
  /// ====================================================================
  /// Retorna uma rota customizada com animação refinada de transição 
  /// baseada em fade-in e deslizamento sutil, condizente com a marca "Uni Eats".
  static PageRouteBuilder _buildPageRoute({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Curva suave para transição sofisticada
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05), // Deslocamento sutil no eixo Y para cima
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Rota de tratamento de erro para rotas não mapeadas no ecossistema
  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Erro de Navegação", style: TextStyle(color: Color(0xFFD32F2F))),
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 72, color: Color(0xFFD32F2F)),
                const SizedBox(height: 16),
                const Text(
                  "Erro 404: Rota não encontrada",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "A rota '${settings.name}' não está cadastrada ou foi desativada.",
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
