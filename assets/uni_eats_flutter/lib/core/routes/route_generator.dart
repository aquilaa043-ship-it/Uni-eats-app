import 'package:flutter/material.dart';
import '../../features/shared/domain/models/firebase_models.dart';
import '../../features/auth/data/firebase_auth_service.dart';
import '../../features/auth/presentation/screens/firebase_auth_screen.dart';
import '../../features/shared/presentation/screens/uni_eats_control_hub.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Redireciona automaticamente após um breve delay (2.5 segundos)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 2500));
      final authService = FirebaseAuthService();
      final user = await authService.obterUsuarioAtual();
      if (user != null) {
        if (user.tipoUsuario == 'cliente') {
          Navigator.pushReplacementNamed(context, RouteGenerator.homeCliente);
        } else if (user.tipoUsuario == 'lojista') {
          Navigator.pushReplacementNamed(context, RouteGenerator.homeLojista);
        } else if (user.tipoUsuario == 'motoboy') {
          Navigator.pushReplacementNamed(context, RouteGenerator.homeMotoboy);
        } else if (user.tipoUsuario == 'super_admin') {
          Navigator.pushReplacementNamed(context, RouteGenerator.superAdmin);
        } else {
          Navigator.pushReplacementNamed(context, RouteGenerator.login);
        }
      } else {
        Navigator.pushReplacementNamed(context, RouteGenerator.login);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Grafite Ultra Escuro
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF1E1E1E), // Brilho de centro
              Color(0xFF121212), // Escuridão de borda
            ],
            radius: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logotipo da marca com renderização defensiva (fallback para Icon)
              Image.asset(
                'assets/images/logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 70,
                      color: Color(0xFFD4AF37), // Ouro Velho
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                "UNI EATS",
                style: TextStyle(
                  color: Color(0xFFFAF9F6), // Off-White
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6.0,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "SaaS Delivery Regionalizado",
                style: TextStyle(
                  color: Color(0xFF9E9E9E), // Muted Gray
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.5,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 64),
              // Carregamento discreto premium
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaCardapioCliente extends StatefulWidget {
  final String restauranteId;

  const TelaCardapioCliente({
    Key? key,
    required this.restauranteId,
  }) : super(key: key);

  @override
  State<TelaCardapioCliente> createState() => _TelaCardapioClienteState();
}

class _TelaCardapioClienteState extends State<TelaCardapioCliente> with SingleTickerProviderStateMixin {
  bool _showVideoReels = false;
  int _activeProductIndex = 0;
  bool _isReelsPlaying = true;
  bool _isLiked = false;
  int _likesCount = 142;

  // Lista local simulando pratos com vídeos promocionais integrados
  final List<Map<String, dynamic>> _menuItems = [
    {
      "id": "item_1",
      "nome": "Costela ao Molho de Ouro",
      "descricao": "Costela bovina premium defumada por 12 horas, glaceada com redução de bourbon, mel de engenho e salpicada com folhas de ouro comestíveis.",
      "preco": 79.90,
      "tempo": "35-45 min",
      "likes": 184,
      "categoria": "Carnes Nobres",
      "videoSimulado": "costela_gourmet_slowmo.mp4",
      "hasVideo": true,
    },
    {
      "id": "item_2",
      "nome": "Fettuccine Trufado di Parma",
      "descricao": "Massa artesanal fresca salteada na manteiga de trufas brancas, presunto di Parma crocante e queijo Grana Padano ralado na hora.",
      "preco": 58.50,
      "tempo": "20-25 min",
      "likes": 95,
      "categoria": "Massas",
      "videoSimulado": "fettuccine_chef_plating.mp4",
      "hasVideo": true,
    },
    {
      "id": "item_3",
      "nome": "Taça Cacau D'Or Supreme",
      "descricao": "Sorvete artesanal de fava de baunilha, brownie morno de cacau 70%, calda de chocolate belga derretido e avelãs tostadas.",
      "preco": 32.00,
      "tempo": "15 min",
      "likes": 312,
      "categoria": "Sobremesas",
      "videoSimulado": "melting_chocolate_belga.mp4",
      "hasVideo": true,
    }
  ];

  @override
  Widget build(BuildContext context) {
    const Color brandDark = Color(0xFF121212);
    const Color brandSurface = Color(0xFF1C1C1C);
    const Color brandGoldOld = Color(0xFFD4AF37);
    const Color brandTextLight = Color(0xFFFAF9F6);
    const Color brandTextMuted = Color(0xFF9E9E9E);

    return Scaffold(
      backgroundColor: brandDark,
      appBar: AppBar(
        title: Text(
          "CARDÁPIO DE: ${widget.restauranteId.toUpperCase()}",
          style: const TextStyle(
            color: brandTextLight,
            letterSpacing: 1.5,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor: brandSurface,
        iconTheme: const IconThemeData(color: brandGoldOld),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.movie_filter_outlined, color: brandGoldOld),
            tooltip: "Ver Reels Gastronômicos",
            onPressed: () {
              setState(() {
                _activeProductIndex = 0;
                _showVideoReels = true;
                _isReelsPlaying = true;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. LISTA PRINCIPAL DE CARDÁPIO PREMIUM
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner do restaurante
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E2415), brandSurface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: brandGoldOld.withOpacity(0.15)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: brandGoldOld.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars, color: brandGoldOld, size: 12),
                            SizedBox(width: 4),
                            Text(
                              "ESTABELECIMENTO PREMIUM",
                              style: TextStyle(color: brandGoldOld, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.restauranteId.replaceAll("_", " ").toUpperCase(),
                        style: const TextStyle(color: brandTextLight, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Gastronomia Exclusiva com Cardápio de Vídeos Interativos",
                        style: TextStyle(color: brandTextMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "PRATOS EXCLUSIVOS",
                      style: TextStyle(color: brandGoldOld, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _activeProductIndex = 0;
                          _showVideoReels = true;
                          _isReelsPlaying = true;
                        });
                      },
                      icon: const Icon(Icons.play_circle_fill_outlined, color: brandGoldOld, size: 16),
                      label: const Text(
                        "ASSISTIR REELS DE PROMOÇÃO",
                        style: TextStyle(color: brandGoldOld, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Lista de Itens do Menu
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    return Container(
                      margin: const EdgeInsets.bottom: 16,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: brandSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2C2C2C)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Detalhes do texto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item["categoria"].toUpperCase(),
                                        style: const TextStyle(color: brandTextMuted, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item["nome"],
                                      style: const TextStyle(color: brandTextLight, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item["descricao"],
                                      style: const TextStyle(color: brandTextMuted, fontSize: 11, height: 1.4),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Thumbnail Simulando Pré-visualização de Vídeo / Foto do prato
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _activeProductIndex = index;
                                    _showVideoReels = true;
                                    _isReelsPlaying = true;
                                    _likesCount = item["likes"];
                                  });
                                },
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: brandGoldOld.withOpacity(0.3)),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2E2415), Color(0xFF1E1C1A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Ícone simulando vídeo de fundo
                                      const Icon(Icons.restaurant_menu, color: Color(0xFF4A453A), size: 36),
                                      
                                      // Overlay de Vídeo Ativo Badge
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF5350).withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.videocam, color: Colors.white, size: 8),
                                              SizedBox(width: 2),
                                              Text("VIDEO", style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Botão de Play
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow_rounded, color: brandGoldOld, size: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF2C2C2C), height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "R\$ ${item["preco"].toStringAsFixed(2)}",
                                style: const TextStyle(color: brandGoldOld, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.access_time, color: brandTextMuted.withOpacity(0.7), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    item["tempo"],
                                    style: const TextStyle(color: brandTextMuted, fontSize: 11),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: brandGoldOld.withOpacity(0.1),
                                      foregroundColor: brandGoldOld,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: brandGoldOld, width: 0.8),
                                      ),
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("✓ Adicionado à sacola: ${item["nome"]}"),
                                          backgroundColor: brandSurface,
                                        ),
                                      );
                                    },
                                    child: const Text("ADICIONAR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    foregroundColor: brandTextLight,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, RouteGenerator.homeCliente);
                  },
                  child: const Text("VOLTAR PARA HOME DO CLIENTE"),
                ),
              ],
            ),
          ),

          // 2. OVERLAY DO REELS DE COMIDA (SIMULADOR DE VÍDEO VERTICAL COMPLETO)
          if (_showVideoReels)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Fundo de Vídeo Simulado (Representando Food Reels de Altíssima Qualidade)
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 15),
                          builder: (context, value, child) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    Color.lerp(const Color(0xFF1E160D), const Color(0xFF132A15), value)!,
                                    const Color(0xFF070707),
                                  ],
                                  radius: 1.5,
                                  center: Alignment.center,
                                ),
                              ),
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ícone de comida pulsante para simular o movimento dinâmico da câmera
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 1.0, end: 1.1),
                                duration: const Duration(milliseconds: 2500),
                                curve: Curves.easeInOut,
                                builder: (context, scale, _) {
                                  return Transform.scale(
                                    scale: _isReelsPlaying ? scale : 1.0,
                                    child: const Opacity(
                                      opacity: 0.2,
                                      child: Icon(
                                        Icons.restaurant_rounded,
                                        size: 180,
                                        color: brandGoldOld,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Detalhes cosméticos simulando o streaming de vídeo
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam_rounded, color: Colors.white24, size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                    "Reproduzindo FoodReel™",
                                    style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Qualidade UltraHD HDR 60fps",
                                    style: TextStyle(color: Colors.white12, fontSize: 9),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Barra de Progresso do Vídeo Superior (Tipo Instagram Stories)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          children: List.generate(_menuItems.length, (index) {
                            return Expanded(
                              child: Container(
                                height: 3,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: index == _activeProductIndex
                                      ? brandGoldOld
                                      : index < _activeProductIndex
                                          ? brandGoldOld.withOpacity(0.5)
                                          : Colors.white24,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Botão de fechar
                      Positioned(
                        top: 24,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 28),
                          onPressed: () {
                            setState(() {
                              _showVideoReels = false;
                            });
                          },
                        ),
                      ),

                      // Seção Inferior: Dados do Prato que está sendo exibido no vídeo
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black, Colors.black54, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Textos Informativos
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: brandGoldOld,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            "FOOD REELS LIVE",
                                            style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _menuItems[_activeProductIndex]["categoria"].toUpperCase(),
                                          style: const TextStyle(color: brandGoldOld, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _menuItems[_activeProductIndex]["nome"],
                                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _menuItems[_activeProductIndex]["descricao"],
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Botão de Adicionar à Sacola diretamente do Vídeo
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: brandGoldOld,
                                        foregroundColor: Colors.black,
                                        minimumSize: const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      ),
                                      onPressed: () {
                                        final item = _menuItems[_activeProductIndex];
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("✓ Adicionado à sacola direto do Reels: ${item["nome"]}"),
                                            backgroundColor: brandSurface,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.shopping_bag, size: 20),
                                      label: Text(
                                        "ADICIONAR À SACOLA • R\$ ${_menuItems[_activeProductIndex]["preco"].toStringAsFixed(2)}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Painel Lateral de Interações Sociais (Estilo TikTok / Instagram Reels)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botão Play/Pause
                                  _buildSocialActionButton(
                                    icon: _isReelsPlaying ? Icons.pause : Icons.play_arrow,
                                    label: _isReelsPlaying ? "Pausar" : "Play",
                                    onTap: () {
                                      setState(() {
                                        _isReelsPlaying = !_isReelsPlaying;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Botão Curtir
                                  _buildSocialActionButton(
                                    icon: Icons.favorite,
                                    color: _isLiked ? Colors.redAccent : Colors.white,
                                    label: "$_likesCount",
                                    onTap: () {
                                      setState(() {
                                        _isLiked = !_isLiked;
                                        if (_isLiked) {
                                          _likesCount++;
                                        } else {
                                          _likesCount--;
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Próximo Vídeo
                                  _buildSocialActionButton(
                                    icon: Icons.skip_next,
                                    label: "Próximo",
                                    onTap: () {
                                      setState(() {
                                        _activeProductIndex = (_activeProductIndex + 1) % _menuItems.length;
                                        _likesCount = _menuItems[_activeProductIndex]["likes"];
                                        _isLiked = false;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class RouteGenerator {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String homeCliente = '/home_cliente';
  static const String homeLojista = '/home_lojista';
  static const String homeMotoboy = '/home_motoboy';
  static const String superAdmin = '/super_admin';
  static const String cardapio = '/cardapio';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name ?? '');
    final String routePath = uri.path;

    if (routePath == cardapio) {
      String? restauranteId = uri.queryParameters['id'];
      if (restauranteId == null && settings.arguments is String) {
        restauranteId = settings.arguments as String;
      }

      if (restauranteId != null && restauranteId.isNotEmpty) {
        return _buildPageRoute(
          settings: settings,
          builder: (_) => TelaCardapioCliente(restauranteId: restauranteId!),
        );
      } else {
        debugPrint("Deep Link mal formatado recebido. Redirecionando para Home do Cliente.");
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const UniEatsControlHub(initialModule: 0),
        );
      }
    }

    switch (routePath) {
      case splash:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case login:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const UniEatsAuthScreen(),
        );

      case homeCliente:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const UniEatsControlHub(initialModule: 0),
        );

      case homeLojista:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const UniEatsControlHub(initialModule: 2),
        );

      case homeMotoboy:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const UniEatsControlHub(initialModule: 3),
        );

      case superAdmin:
        return _buildPageRoute(
          settings: settings,
          builder: (_) => const UniEatsControlHub(initialModule: 5),
        );

      default:
        return _errorRoute(settings);
    }
  }

  static Future<bool> validarPermissaoDeAcesso(String rotaDestino) async {
    try {
      final FirebaseAuthService authService = FirebaseAuthService();
      final UsuarioModel? usuarioLogado = await authService.obterUsuarioAtual();

      if (usuarioLogado == null) {
        return false;
      }

      switch (rotaDestino) {
        case homeLojista:
          return usuarioLogado.tipoUsuario == 'lojista' || usuarioLogado.tipoUsuario == 'super_admin';
        case homeMotoboy:
          return usuarioLogado.tipoUsuario == 'motoboy' || usuarioLogado.tipoUsuario == 'super_admin';
        case superAdmin:
          return usuarioLogado.tipoUsuario == 'super_admin';
        case homeCliente:
        case cardapio:
          return true;
        default:
          return false;
      }
    } catch (e) {
      debugPrint("Erro ao interceptar e validar permissão de rota: $e");
      return false;
    }
  }

  static PageRouteBuilder _buildPageRoute({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

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
