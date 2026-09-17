import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración centralizada de Supabase para Vikus / Aeronpulse.
/// 
/// Buenas prácticas de seguridad:
/// - Se utiliza la Project URL y la Publishable Key pública (`anon`).
/// - NUNCA utilices la clave `service_role` (secret key) en la aplicación cliente Flutter.
class SupabaseConfig {
  /// URL del proyecto Supabase
  /// Project ID: tjqkvbwzkxyrwxccolas
  static const String url = 'https://tjqkvbwzkxyrwxccolas.supabase.co';

  /// Publishable Key pública de Supabase
  /// Puede ser provista en compilación con --dart-define=SUPABASE_PUBLISHABLE_KEY=...
  /// o configurada en este archivo.
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqcWt2Ynd6a3h5cnd4Y2NvbGFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4ODM3NzYsImV4cCI6MjEwNDQ1OTc3Nn0.rQqET2lOREGtBuQC3uxSb1u2AReffBQshYFEfvqjuo0',
  );

  /// Web Client ID de Google para autenticación nativa (Google Sign In)
  /// Puedes configurarlo con --dart-define=GOOGLE_WEB_CLIENT_ID=... o pegarlo aquí
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '709351847485-vajl95o18u5nh53sgf3tqq0hhvu3iq0j.apps.googleusercontent.com',
  );

  /// iOS Client ID de Google si se ejecuta en plataforma Apple iOS
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  /// Inicializa Supabase de manera segura antes de iniciar runApp() o acceder a Supabase.instance.client
  static Future<void> initialize({String? customPublishableKey}) async {
    final key = customPublishableKey ?? publishableKey;

    if (key == 'PEGA_AQUI_TU_PUBLISHABLE_KEY' || key.trim().isEmpty) {
      debugPrint(
        '⚠️ [SupabaseConfig] Publishable Key pendiente de configuración.\n'
        'Por favor, asigna tu Publishable Key obtenida de Supabase Dashboard > Settings > API.',
      );
      return;
    }

    await Supabase.initialize(
      url: url,
      anonKey: key, // ignore: deprecated_member_use
    );
  }

  /// Getter para acceder al cliente de Supabase una vez inicializado
  static SupabaseClient get client => Supabase.instance.client;
}

/// Getter global para acceder de forma concisa al cliente de Supabase
SupabaseClient get supabase => Supabase.instance.client;
