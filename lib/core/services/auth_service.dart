import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Servicio centralizado de autenticación con Supabase Auth
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get _client => SupabaseConfig.client;
  GoTrueClient get _auth => _client.auth;

  /// Retorna el usuario actual de Supabase
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Retorna el ID único del usuario autenticado actual o null
  String? get currentUserId {
    try {
      return _auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  /// Indica si hay una sesión activa
  bool get isAuthenticated {
    try {
      return _auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Stream para escuchar cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges {
    try {
      return _auth.onAuthStateChange;
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Inicia sesión con correo y contraseña
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('Error en signIn: ${e.message}');
      throw _parseAuthException(e);
    } catch (e) {
      debugPrint('Error inesperado en signIn: $e');
      throw Exception('Ocurrió un error inesperado al iniciar sesión. Intenta nuevamente.');
    }
  }

  /// Registra una nueva cuenta de usuario
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
      );

      // Si el usuario se creó correctamente, registrar o actualizar su perfil en `profiles`
      if (response.user != null) {
        try {
          await _client.from('profiles').upsert({
            'id': response.user!.id,
            'full_name': fullName.trim(),
            'phone': phone?.trim() ?? '',
            'email': email.trim(),
            'city': 'Pando',
            'notify_all': true,
            'notify_new_offers': true,
            'notify_expiring_offers': true,
            'notify_important_messages': true,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (profileError) {
          debugPrint('Aviso: el perfil se creará/sincronizará al iniciar sesión: $profileError');
        }
      }

      return response;
    } on AuthException catch (e) {
      debugPrint('Error en signUp: ${e.message}');
      throw _parseAuthException(e);
    } catch (e) {
      debugPrint('Error inesperado en signUp: $e');
      throw Exception('Ocurrió un error inesperado al registrarte. Intenta nuevamente.');
    }
  }

  /// Inicia sesión o crea cuenta mediante Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // En Web, redirigir dinámicamente al puerto/origen actual (ej. localhost:3002)
        await _auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? Uri.base.origin : null,
        );
        return null;
      }

      // En Android e iOS, usamos GoogleSignIn nativo para la mejor experiencia móvil
      final webClientId = SupabaseConfig.googleWebClientId;
      final iosClientId = SupabaseConfig.googleIosClientId;

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId.isNotEmpty ? iosClientId : null,
        serverClientId: webClientId.isNotEmpty ? webClientId : null,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló la selección de cuenta
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception(
          'No se pudo obtener el token de Google.\n'
          'Asegúrate de configurar GOOGLE_WEB_CLIENT_ID en SupabaseConfig.',
        );
      }

      final response = await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } on AuthException catch (e) {
      debugPrint('Error de autenticación Supabase con Google: ${e.message}');
      throw _parseAuthException(e);
    } catch (e) {
      debugPrint('Error en signInWithGoogle: $e');
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('sign_in_canceled') ||
          errorStr.contains('canceled') ||
          errorStr.contains('cancelled') ||
          errorStr.contains('12501') ||
          errorStr.contains('popup_closed_by_user')) {
        return null;
      }
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  /// Cierra la sesión activa
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    } catch (e) {
      debugPrint('Error en signOut: $e');
    }
  }

  /// Envía correo de recuperación de contraseña
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw _parseAuthException(e);
    } catch (e) {
      throw Exception('No se pudo enviar el correo de recuperación. Intenta nuevamente.');
    }
  }

  /// Actualiza la contraseña del usuario conectado
  Future<UserResponse?> updatePassword({required String newPassword}) async {
    try {
      final response = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } on AuthException catch (e) {
      throw _parseAuthException(e);
    } catch (e) {
      if (e is AssertionError || e.toString().contains('AssertionError')) {
        return null;
      }
      throw Exception('No se pudo actualizar la contraseña. Intenta nuevamente.');
    }
  }

  /// Actualiza el correo electrónico del usuario conectado
  Future<UserResponse?> updateEmail({required String newEmail}) async {
    try {
      final response = await _auth.updateUser(
        UserAttributes(email: newEmail.trim()),
      );
      return response;
    } on AuthException catch (e) {
      throw _parseAuthException(e);
    } catch (e) {
      if (e is AssertionError || e.toString().contains('AssertionError')) {
        return null;
      }
      throw Exception('No se pudo actualizar el correo electrónico. Intenta nuevamente.');
    }
  }

  /// Traduce los mensajes de error técnicos de Supabase a mensajes amigables en español
  Exception _parseAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
      return Exception('Correo electrónico o contraseña incorrectos.');
    }
    if (msg.contains('user already registered') || msg.contains('already exists')) {
      return Exception('Ya existe una cuenta registrada con este correo electrónico.');
    }
    if (msg.contains('password should be at least')) {
      return Exception('La contraseña debe tener al menos 6 caracteres.');
    }
    if (msg.contains('invalid email') || msg.contains('email_address_invalid')) {
      return Exception('El formato del correo electrónico no es válido.');
    }
    if (msg.contains('rate limit') || msg.contains('over_email_send_rate_limit')) {
      return Exception('Has alcanzado el límite de intentos de registro. Espera unos minutos e intenta de nuevo.');
    }
    if (msg.contains('network') || msg.contains('timeout')) {
      return Exception('Problema de conexión con el servidor. Revisa tu internet.');
    }
    return Exception(e.message);
  }
}
