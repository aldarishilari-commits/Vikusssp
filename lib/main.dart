import 'package:flutter/material.dart';
import 'core/config/supabase_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/screens/onboarding_carousel_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el servicio de preferencias de tema
  await ThemeService.instance.initialize();

  // Inicializa Supabase antes de montar los widgets o acceder a Supabase.instance.client
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Error al inicializar Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Vikus - Aeronpulse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService.instance.themeMode,
          home: StreamBuilder<AuthState>(
            stream: AuthService().authStateChanges,
            builder: (context, snapshot) {
              final isAuthenticated = snapshot.data?.session != null || AuthService().isAuthenticated;
              if (isAuthenticated) {
                return const HomeScreen(title: 'Vikus');
              }
              return const OnboardingCarouselScreen();
            },
          ),
        );
      },
    );
  }
}

// Retaining MyHomePage alias to maintain backward compatibility
typedef MyHomePage = HomeScreen;
