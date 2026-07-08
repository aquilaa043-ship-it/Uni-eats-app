import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/data/firebase_auth_service.dart';
import 'features/auth/presentation/screens/firebase_auth_screen.dart';
import 'core/routes/route_generator.dart';
import 'features/shared/domain/models/firebase_models.dart';
import 'features/shared/presentation/screens/uni_eats_control_hub.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase Core inicializado com sucesso.");
  } catch (e) {
    debugPrint("Erro fatal ao inicializar o Firebase: $e");
  }

  runApp(const UniEatsApp());
}

class UniEatsApp extends StatelessWidget {
  const UniEatsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni Eats',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      initialRoute: RouteGenerator.splash,
      onGenerateRoute: RouteGenerator.onGenerateRoute,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService authService = FirebaseAuthService();

    return StreamBuilder(
      stream: authService.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UsuarioModel?>(
            future: authService.obterUsuarioAtual(),
            builder: (context, userProfileSnapshot) {
              if (userProfileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF121212),
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                );
              }

              final UsuarioModel? perfil = userProfileSnapshot.data;

              if (perfil == null || perfil.statusAssinatura == 'suspenso' || perfil.statusAssinatura == 'inativo') {
                authService.deslogar();
                return const UniEatsAuthScreen();
              }

              switch (perfil.tipoUsuario) {
                case 'cliente':
                  return const UniEatsControlHub(initialModule: 0);
                case 'lojista':
                  return const UniEatsControlHub(initialModule: 2);
                case 'motoboy':
                  return const UniEatsControlHub(initialModule: 3);
                case 'super_admin':
                  return const UniEatsControlHub(initialModule: 5);
                default:
                  return const UniEatsAuthScreen();
              }
            },
          );
        }

        return const UniEatsAuthScreen();
      },
    );
  }
}
