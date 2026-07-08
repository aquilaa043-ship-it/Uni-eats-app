import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase_auth_service.dart';
import 'firebase_auth_screen.dart';
import 'route_generator.dart';
import 'firebase_models.dart';

/// ====================================================================
/// UNI EATS - PONTO DE ENTRADA DO APLICATIVO (MAIN ENGINE)
/// ====================================================================
/// Este arquivo realiza a inicialização assíncrona do Flutter Engine e
/// dos SDKs do Firebase Core, além de gerenciar a verificação automática de
/// sessão ativa (Auth Gate) e a injeção do gerenciador global de rotas.

void main() async {
  // 1. Garante que os bindings do Flutter estejam totalmente inicializados
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Inicializa o Firebase com as credenciais específicas da plataforma
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase Core inicializado com sucesso.");
  } catch (e) {
    debugPrint("Erro fatal ao inicializar o Firebase: $e");
  }

  // 3. Executa a aplicação Flutter
  runApp(const UniEatsApp());
}

class UniEatsApp extends StatelessWidget {
  const UniEatsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni Eats',
      debugShowCheckedModeBanner: false,

      // ====================================================================
      // TEMA LUXUOSO E ELITIZADO "DARK PREMIUM" (MATERIAL DESIGN 3)
      // ====================================================================
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Grafite Ultra Escuro
        
        // Esquema de Cores Customizado
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),       // Ouro Velho
          onPrimary: Color(0xFF121212),     // Preto Grafite
          secondary: Color(0xFFFAF9F6),     // Off-White
          surface: Color(0xFF1E1E1E),       // Grafite Nobre (Cartões)
          error: Color(0xFFD32F2F),         // Vermelho Alerta
        ),

        // Customização Global de Fontes e Cabeçalhos
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold, color: Color(0xFFFAF9F6)),
          bodyLarge: TextStyle(fontFamily: 'Inter', color: Color(0xFFFAF9F6)),
          bodyMedium: TextStyle(fontFamily: 'Inter', color: Color(0xFF9E9E9E)),
        ),

        // Configuração Padrão do AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
          titleTextStyle: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // ====================================================================
      // GERENCIAMENTO DE ROTAS NOMEADAS & DEEP LINKING
      // ====================================================================
      initialRoute: RouteGenerator.splash,
      onGenerateRoute: RouteGenerator.onGenerateRoute,

      // ====================================================================
      // CORE HOME: AUTH GATE (GUARDA DE ENTRADA DO ECOSSISTEMA)
      // ====================================================================
      home: const AuthGate(),
    );
  }
}

/// ====================================================================
/// GATEWAY DE AUTENTICAÇÃO REATIVA (AUTH GATE)
/// ====================================================================
/// Esta classe monitora o estado de autenticação em tempo real. Se o token
/// de sessão do usuário expirar ou se ele deslogar, redireciona o aplicativo
/// de imediato para a tela de autenticação premium. Se estiver ativo, consulta
/// seu perfil no Firestore para carregar seu respectivo Dashboard.
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService authService = FirebaseAuthService();

    return StreamBuilder(
      stream: authService.onAuthStateChanged,
      builder: (context, snapshot) {
        // 1. Estado de Carregamento da Conexão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          );
        }

        // 2. Se o Usuário Estiver Autenticado no Firebase Auth Core
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UsuarioModel?>(
            future: authService.obterUsuarioAtual(),
            builder: (context, userProfileSnapshot) {
              // Carregamento do perfil do banco de dados NoSQL
              if (userProfileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF121212),
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                );
              }

              final UsuarioModel? perfil = userProfileSnapshot.data;

              // Verificação de Segurança e Bloqueios Administrativos
              if (perfil == null || perfil.statusAssinatura == 'suspenso' || perfil.statusAssinatura == 'inativo') {
                // Encerra a sessão imediatamente em caso de banimento por segurança
                authService.deslogar();
                return const UniEatsAuthScreen();
              }

              // Switch de Redirecionamento Baseado no Perfil Ativo
              switch (perfil.tipoUsuario) {
                case 'cliente':
                  return const HomeClienteScreen();
                case 'lojista':
                  return const HomeLojistaScreen();
                case 'motoboy':
                  return const HomeMotoboyScreen();
                case 'super_admin':
                  return const SuperAdminScreen();
                default:
                  // Caso o papel esteja corrompido, redireciona ao login
                  return const UniEatsAuthScreen();
              }
            },
          );
        }

        // 3. Usuário Deslogado ou sem sessão ativa
        return const UniEatsAuthScreen();
      },
    );
  }
}
