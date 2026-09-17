/// Modelo que representa el perfil de usuario en la tabla `public.profiles`
class UserProfileModel {
  final String id;
  final String fullName;
  final String? phone;
  final String email;
  final String? avatarUrl;
  final String city;
  final bool notifyAll;
  final bool notifyNewOffers;
  final bool notifyExpiringOffers;
  final bool notifyImportantMessages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.phone,
    required this.email,
    this.avatarUrl,
    this.city = 'Pando',
    this.notifyAll = true,
    this.notifyNewOffers = true,
    this.notifyExpiringOffers = true,
    this.notifyImportantMessages = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea una instancia a partir del mapa devuelto por Supabase
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      city: map['city'] as String? ?? 'Pando',
      notifyAll: map['notify_all'] as bool? ?? true,
      notifyNewOffers: map['notify_new_offers'] as bool? ?? true,
      notifyExpiringOffers: map['notify_expiring_offers'] as bool? ?? true,
      notifyImportantMessages: map['notify_important_messages'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  /// Convierte la instancia a un mapa para insertar o actualizar en Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      if (phone != null) 'phone': phone,
      'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'city': city,
      'notify_all': notifyAll,
      'notify_new_offers': notifyNewOffers,
      'notify_expiring_offers': notifyExpiringOffers,
      'notify_important_messages': notifyImportantMessages,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copia el modelo con nuevos valores opcionales
  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? city,
    bool? notifyAll,
    bool? notifyNewOffers,
    bool? notifyExpiringOffers,
    bool? notifyImportantMessages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      notifyAll: notifyAll ?? this.notifyAll,
      notifyNewOffers: notifyNewOffers ?? this.notifyNewOffers,
      notifyExpiringOffers: notifyExpiringOffers ?? this.notifyExpiringOffers,
      notifyImportantMessages: notifyImportantMessages ?? this.notifyImportantMessages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Retorna la primera letra del nombre en mayúscula para el avatar por defecto
  String get avatarInitial {
    if (fullName.trim().isEmpty) return 'U';
    return fullName.trim()[0].toUpperCase();
  }
}
