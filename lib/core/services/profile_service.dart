import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../../features/auth/domain/models/user_profile_model.dart';
import 'auth_service.dart';

/// Servicio para consultar y actualizar el perfil de usuario en la tabla `public.profiles`
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  SupabaseClient get _client => SupabaseConfig.client;

  /// Obtiene el perfil del usuario actualmente autenticado
  Future<UserProfileModel?> getCurrentProfile() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return UserProfileModel.fromMap(response);
      }

      // Si por alguna razón el registro no existe en `profiles`, lo creamos como fallback
      final fallbackProfile = UserProfileModel(
        id: user.id,
        fullName: (user.userMetadata?['full_name'] as String?) ??
            (user.userMetadata?['name'] as String?) ??
            'Usuario Vikus',
        phone: (user.userMetadata?['phone'] as String?) ?? user.phone,
        email: user.email ?? '',
        city: 'Pando',
      );

      await _client.from('profiles').upsert(fallbackProfile.toMap());
      return fallbackProfile;
    } catch (e) {
      debugPrint('Error al obtener perfil en ProfileService: $e');
      return null;
    }
  }

  /// Actualiza los datos personales principales del perfil
  Future<UserProfileModel> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
    String? city,
  }) async {
    final userId = AuthService().currentUserId;
    if (userId == null) {
      throw Exception('No hay una sesión activa de usuario.');
    }

    try {
      final updates = <String, dynamic>{
        'full_name': fullName.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (phone != null) updates['phone'] = phone.trim();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (city != null) updates['city'] = city.trim();

      final response = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromMap(response);
    } catch (e) {
      debugPrint('Error al actualizar perfil: $e');
      throw Exception('No se pudo actualizar el perfil. Intenta nuevamente.');
    }
  }

  /// Actualiza la ciudad activa del usuario
  Future<void> updateCity(String city) async {
    final userId = AuthService().currentUserId;
    if (userId == null) return;

    try {
      await _client.from('profiles').update({
        'city': city,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Error al actualizar ciudad: $e');
    }
  }

  /// Actualiza las preferencias de notificación en la base de datos
  Future<void> updateNotificationPreferences({
    required bool notifyAll,
    required bool notifyNewOffers,
    required bool notifyExpiringOffers,
    required bool notifyImportantMessages,
  }) async {
    final userId = AuthService().currentUserId;
    if (userId == null) {
      throw Exception('No hay una sesión activa de usuario.');
    }

    try {
      await _client.from('profiles').update({
        'notify_all': notifyAll,
        'notify_new_offers': notifyNewOffers,
        'notify_expiring_offers': notifyExpiringOffers,
        'notify_important_messages': notifyImportantMessages,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      debugPrint('Error al actualizar notificaciones: $e');
      throw Exception('No se pudieron guardar las preferencias de notificación.');
    }
  }
}
