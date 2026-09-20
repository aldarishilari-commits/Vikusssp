import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import '../../features/business/domain/models/business_registration_model.dart';
import '../../features/home/domain/models/business_filter_criteria.dart';
import '../../features/home/presentation/widgets/business_card_item.dart';

/// Servicio centralizado para gestionar negocios, búsquedas y registros en Supabase.
class BusinessService {
  static final BusinessService _instance = BusinessService._internal();
  factory BusinessService() => _instance;
  BusinessService._internal();

  static BusinessService get instance => _instance;

  SupabaseClient get _client => SupabaseConfig.client;

  /// Notificador para alertar cuando se registre o actualice un negocio
  final ValueNotifier<int> businessUpdatesNotifier = ValueNotifier<int>(0);

  /// Notifica a los listeners que la lista de negocios debe actualizarse
  void notifyBusinessUpdated() {
    businessUpdatesNotifier.value++;
  }

  /// Obtiene la lista de negocios activos desde Supabase con búsqueda y filtros
  Future<List<BusinessModel>> getBusinesses({
    String? city,
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      var query = _client
          .from('businesses')
          .select('*, business_schedules(*), business_photos(*)')
          .eq('is_active', true);

      // Filtro por categoría
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'ver_mas' && categoryId != 'todas') {
        query = query.eq('category_id', categoryId.toLowerCase());
      }

      // Filtro por búsqueda textual (nombre, descripción, dirección)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final cleanQuery = searchQuery.trim();
        query = query.or(
          'name.ilike.%$cleanQuery%,description.ilike.%$cleanQuery%,address.ilike.%$cleanQuery%',
        );
      }

      // Ordenar por calificación y destacados PRO primero
      final response = await query.order('is_pro', ascending: false).order('rating', ascending: false);

      final list = (response as List<dynamic>)
          .map((item) => mapSupabaseToBusinessModel(item as Map<String, dynamic>))
          .toList();

      return list;
    } catch (e) {
      debugPrint('Error al obtener negocios desde Supabase: $e');
      return [];
    }
  }

  /// Registra un nuevo negocio completo en Supabase (`businesses`, `business_schedules`, `business_photos`, `business_items`)
  Future<BusinessModel> createBusiness(BusinessRegistrationData data) async {
    final userId = AuthService().currentUserId;
    if (userId == null) {
      throw Exception('Debes iniciar sesión para registrar un negocio.');
    }

    try {
      final String categoryId = _mapCategoryToId(data.category);

      // 1. Insertar negocio principal
      final businessInsert = <String, dynamic>{
        'id': data.id,
        'owner_id': userId,
        'name': data.name.trim().isNotEmpty ? data.name.trim() : 'Mi Negocio',
        'description': data.description.trim(),
        'category_id': categoryId,
        'address': data.address.trim().isNotEmpty ? data.address.trim() : 'Av. Principal',
        'city': 'Pando',
        'latitude': data.latitude,
        'longitude': data.longitude,
        'phone_country_code': data.phoneCountryCode.isNotEmpty ? data.phoneCountryCode : '+591',
        'phone_number': data.phoneNumber.trim(),
        'whatsapp_number': data.phoneNumber.trim(),
        'tiktok_url': data.tiktok.trim(),
        'facebook_url': data.facebook.trim(),
        'instagram_url': data.instagram.trim(),
        'website_url': data.website.trim(),
        'cover_image_url': data.photoUrls.isNotEmpty
            ? data.photoUrls.first
            : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
        'is_verified': true,
        'is_pro': false,
        'is_active': true,
        'rating': 5.0,
        'reviews_count': 0,
      };

      final businessResponse = await _client
          .from('businesses')
          .insert(businessInsert)
          .select('*, business_schedules(*), business_photos(*)')
          .single();

      final String newBusinessId = businessResponse['id'] as String;

      // 2. Insertar horarios semanales
      final schedulesPayload = <Map<String, dynamic>>[];
      data.schedules.forEach((dayName, schedule) {
        schedulesPayload.add({
          'business_id': newBusinessId,
          'day_name': dayName,
          'is_open': schedule.isOpen,
          'open_time': '${schedule.openTime.hour.toString().padLeft(2, '0')}:${schedule.openTime.minute.toString().padLeft(2, '0')}:00',
          'close_time': '${schedule.closeTime.hour.toString().padLeft(2, '0')}:${schedule.closeTime.minute.toString().padLeft(2, '0')}:00',
        });
      });

      if (schedulesPayload.isNotEmpty) {
        await _client.from('business_schedules').insert(schedulesPayload);
      }

      // 3. Insertar fotos
      if (data.photoUrls.isNotEmpty) {
        final photosPayload = data.photoUrls.asMap().entries.map((entry) {
          return {
            'business_id': newBusinessId,
            'image_url': entry.value,
            'sort_order': entry.key + 1,
          };
        }).toList();

        await _client.from('business_photos').insert(photosPayload);
      }

      // 4. Insertar productos
      if (data.products.isNotEmpty) {
        final productsPayload = data.products.map((p) {
          return {
            'business_id': newBusinessId,
            'item_type': 'product',
            'name': p.name,
            'description': p.description ?? '',
            'price': p.normalPrice ?? 0.0,
            'image_url': p.imagePath,
            'available_quantity': p.availableQuantity,
            'is_flash_offer': p.isFlashOffer,
            'flash_price': p.flashPrice,
            'repeat_days': p.repeatDays,
            'is_available': true,
          };
        }).toList();

        await _client.from('business_items').insert(productsPayload);
      }

      // 5. Insertar servicios
      if (data.services.isNotEmpty) {
        final servicesPayload = data.services.map((s) {
          return {
            'business_id': newBusinessId,
            'item_type': 'service',
            'name': s.name,
            'description': s.description ?? '',
            'price': s.normalPrice ?? 0.0,
            'image_url': s.imagePath,
            'available_quantity': s.availableQuantity,
            'is_flash_offer': s.isFlashOffer,
            'flash_price': s.flashPrice,
            'repeat_days': s.repeatDays,
            'is_available': true,
          };
        }).toList();

        await _client.from('business_items').insert(servicesPayload);
      }

      notifyBusinessUpdated();

      return mapSupabaseToBusinessModel(businessResponse);
    } catch (e) {
      debugPrint('Error al registrar negocio en Supabase: $e');
      throw Exception('No se pudo completar el registro del negocio: $e');
    }
  }

  /// Obtiene el negocio principal administrado por el usuario actual (o el más reciente registrado)
  Future<BusinessFullDetails?> getMyBusiness() async {
    try {
      final userId = AuthService().currentUserId;
      var query = _client
          .from('businesses')
          .select('*, business_schedules(*), business_photos(*), business_items(*)');

      if (userId != null) {
        query = query.eq('owner_id', userId);
      }

      final response = await query.order('created_at', ascending: false).limit(1);
      final list = response as List<dynamic>;
      if (list.isEmpty) {
        // Si no tiene negocio registrado propio, obtener el primero para modo demo/admin
        final fallback = await _client
            .from('businesses')
            .select('*, business_schedules(*), business_photos(*), business_items(*)')
            .order('created_at', ascending: false)
            .limit(1);
        final fallbackList = fallback as List<dynamic>;
        if (fallbackList.isEmpty) return null;
        return _mapToFullDetails(fallbackList.first as Map<String, dynamic>);
      }

      return _mapToFullDetails(list.first as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error al obtener negocio administrado: $e');
      return null;
    }
  }

  /// Obtiene la lista completa de ítems (productos, servicios y ofertas) de un negocio
  Future<List<BusinessItemModel>> getBusinessItems(String businessId) async {
    try {
      final response = await _client
          .from('business_items')
          .select('*')
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => BusinessItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener ítems de negocio: $e');
      return [];
    }
  }

  /// Agrega un nuevo ítem (producto o servicio) al negocio
  Future<BusinessItemModel> addBusinessItem(BusinessItemModel item) async {
    try {
      final payload = item.toJson()..remove('id');
      final response = await _client
          .from('business_items')
          .insert(payload)
          .select()
          .single();

      notifyBusinessUpdated();
      return BusinessItemModel.fromJson(response);
    } catch (e) {
      debugPrint('Error al agregar ítem a negocio: $e');
      throw Exception('No se pudo agregar el ítem: $e');
    }
  }

  /// Actualiza un ítem existente
  Future<void> updateBusinessItem(BusinessItemModel item) async {
    try {
      final payload = item.toJson();
      await _client
          .from('business_items')
          .update(payload)
          .eq('id', item.id);

      notifyBusinessUpdated();
    } catch (e) {
      debugPrint('Error al actualizar ítem: $e');
      throw Exception('No se pudo actualizar el ítem: $e');
    }
  }

  /// Elimina un ítem del negocio
  Future<void> deleteBusinessItem(String itemId) async {
    try {
      await _client.from('business_items').delete().eq('id', itemId);
      notifyBusinessUpdated();
    } catch (e) {
      debugPrint('Error al eliminar ítem: $e');
      throw Exception('No se pudo eliminar el ítem: $e');
    }
  }

  /// Agrega una nueva foto a la galería del negocio
  Future<BusinessPhotoModel> addBusinessPhoto(String businessId, String imageUrl) async {
    try {
      final response = await _client
          .from('business_photos')
          .insert({
            'business_id': businessId,
            'image_url': imageUrl,
            'sort_order': DateTime.now().millisecondsSinceEpoch % 1000,
          })
          .select()
          .single();

      notifyBusinessUpdated();
      return BusinessPhotoModel.fromJson(response);
    } catch (e) {
      debugPrint('Error al agregar foto de negocio: $e');
      throw Exception('No se pudo agregar la foto: $e');
    }
  }

  /// Elimina una foto de la galería del negocio y de Supabase Storage
  Future<void> deleteBusinessPhoto(String photoId, [String? photoUrl]) async {
    try {
      await _client.from('business_photos').delete().eq('id', photoId);
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await StorageService.instance.deleteBusinessPhotoByUrl(photoUrl);
      }
      notifyBusinessUpdated();
    } catch (e) {
      debugPrint('Error al eliminar foto: $e');
      throw Exception('No se pudo eliminar la foto: $e');
    }
  }

  /// Actualiza los horarios semanales del negocio en Supabase
  Future<void> updateBusinessSchedules(String businessId, Map<String, DaySchedule> schedules) async {
    try {
      // Eliminar horarios anteriores
      await _client.from('business_schedules').delete().eq('business_id', businessId);

      // Insertar nuevos horarios
      final schedulesPayload = <Map<String, dynamic>>[];
      schedules.forEach((dayName, schedule) {
        schedulesPayload.add({
          'business_id': businessId,
          'day_name': dayName,
          'is_open': schedule.isOpen,
          'open_time': '${schedule.openTime.hour.toString().padLeft(2, '0')}:${schedule.openTime.minute.toString().padLeft(2, '0')}:00',
          'close_time': '${schedule.closeTime.hour.toString().padLeft(2, '0')}:${schedule.closeTime.minute.toString().padLeft(2, '0')}:00',
        });
      });

      if (schedulesPayload.isNotEmpty) {
        await _client.from('business_schedules').insert(schedulesPayload);
      }

      notifyBusinessUpdated();
    } catch (e) {
      debugPrint('Error al actualizar horarios: $e');
      throw Exception('No se pudieron actualizar los horarios: $e');
    }
  }

  /// Actualiza las redes sociales y página web del negocio
  Future<void> updateBusinessSocialLinks(
    String businessId, {
    String? phone,
    String? whatsapp,
    String? facebook,
    String? instagram,
    String? tiktok,
    String? website,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (phone != null) updates['phone_number'] = phone.trim();
      if (whatsapp != null) updates['whatsapp_number'] = whatsapp.trim();
      if (facebook != null) updates['facebook_url'] = facebook.trim();
      if (instagram != null) updates['instagram_url'] = instagram.trim();
      if (tiktok != null) updates['tiktok_url'] = tiktok.trim();
      if (website != null) updates['website_url'] = website.trim();

      if (updates.isNotEmpty) {
        await _client.from('businesses').update(updates).eq('id', businessId);
        notifyBusinessUpdated();
      }
    } catch (e) {
      debugPrint('Error al actualizar redes sociales: $e');
      throw Exception('No se pudieron guardar las redes sociales: $e');
    }
  }

  /// Actualiza la información básica del negocio (Nombre, descripción, dirección, categoría, portada)
  Future<void> updateBusinessInfo(
    String businessId, {
    String? name,
    String? description,
    String? address,
    String? categoryId,
    String? coverImageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) updates['name'] = name.trim();
      if (description != null) updates['description'] = description.trim();
      if (address != null && address.trim().isNotEmpty) updates['address'] = address.trim();
      if (categoryId != null) updates['category_id'] = _mapCategoryToId(categoryId);
      if (coverImageUrl != null && coverImageUrl.isNotEmpty) updates['cover_image_url'] = coverImageUrl;

      if (updates.isNotEmpty) {
        await _client.from('businesses').update(updates).eq('id', businessId);
        notifyBusinessUpdated();
      }
    } catch (e) {
      debugPrint('Error al actualizar información de negocio: $e');
      throw Exception('No se pudo actualizar la información del negocio: $e');
    }
  }

  static BusinessFullDetails _mapToFullDetails(Map<String, dynamic> row) {
    final business = mapSupabaseToBusinessModel(row);
    final rawItems = row['business_items'] as List<dynamic>? ?? [];
    final rawPhotos = row['business_photos'] as List<dynamic>? ?? [];

    final items = rawItems
        .map((it) => BusinessItemModel.fromJson(it as Map<String, dynamic>))
        .toList();

    final photos = rawPhotos
        .map((ph) => BusinessPhotoModel.fromJson(ph as Map<String, dynamic>))
        .toList();

    return BusinessFullDetails(
      business: business,
      items: items,
      photos: photos,
    );
  }

  /// Mapea un registro JSON de Supabase a [BusinessModel]
  static BusinessModel mapSupabaseToBusinessModel(Map<String, dynamic> row) {
    final String categoryId = (row['category_id'] as String?)?.toLowerCase() ?? 'otros';
    final schedulesList = row['business_schedules'] as List<dynamic>? ?? [];
    final photosList = row['business_photos'] as List<dynamic>? ?? [];

    // Mapear horarios
    Map<String, DaySchedule>? schedulesMap;
    if (schedulesList.isNotEmpty) {
      schedulesMap = {};
      for (final item in schedulesList) {
        final dayName = item['day_name'] as String? ?? '';
        final isOpen = item['is_open'] as bool? ?? true;
        final openParts = (item['open_time'] as String? ?? '08:00').split(':');
        final closeParts = (item['close_time'] as String? ?? '19:00').split(':');

        final openH = int.tryParse(openParts[0]) ?? 8;
        final openM = openParts.length > 1 ? (int.tryParse(openParts[1]) ?? 0) : 0;
        final closeH = int.tryParse(closeParts[0]) ?? 19;
        final closeM = closeParts.length > 1 ? (int.tryParse(closeParts[1]) ?? 0) : 0;

        schedulesMap[dayName] = DaySchedule(
          dayName: dayName,
          isOpen: isOpen,
          openTime: TimeOfDay(hour: openH, minute: openM),
          closeTime: TimeOfDay(hour: closeH, minute: closeM),
        );
      }
    }

    // Mapear fotos
    final photoUrls = photosList
        .map((p) => p['image_url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final coverImage = row['cover_image_url'] as String? ??
        (photoUrls.isNotEmpty ? photoUrls.first : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80');

    // Determinar ícono según categoría
    final icon = _getCategoryIcon(categoryId);
    final categoryName = _getCategoryDisplayName(categoryId);

    final ratingNum = row['rating'];
    final double rating = ratingNum is num ? ratingNum.toDouble() : 4.5;
    final int reviewsCount = row['reviews_count'] is int ? row['reviews_count'] as int : 0;

    return BusinessModel(
      id: row['id'] as String? ?? '',
      name: row['name'] as String? ?? 'Comercio',
      category: categoryName,
      description: row['description'] as String? ?? '',
      address: row['address'] as String? ?? 'Av. Principal',
      distance: '300 m de ti',
      distanceKm: 0.3,
      latitude: (row['latitude'] as num?)?.toDouble() ?? -16.5050,
      longitude: (row['longitude'] as num?)?.toDouble() ?? -68.1290,
      rating: rating,
      reviewsCount: reviewsCount,
      isOpen: true,
      closingTime: '20:00',
      promoBadge: (row['is_pro'] == true) ? 'PRO' : null,
      imageUrl: coverImage,
      categoryIcon: icon,
      schedules: schedulesMap,
      priceLevel: PriceLevel.economic,
      phoneNumber: row['phone_number'] as String? ?? '',
      phoneCountryCode: row['phone_country_code'] as String? ?? '+591',
      facebook: row['facebook_url'] as String? ?? '',
      instagram: row['instagram_url'] as String? ?? '',
      tiktok: row['tiktok_url'] as String? ?? '',
      website: row['website_url'] as String? ?? '',
      photoUrls: photoUrls.isNotEmpty ? photoUrls : [coverImage],
    );
  }

  static String _mapCategoryToId(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('comida') || lower.contains('restaurante') || lower.contains('cafe')) {
      return 'comida';
    } else if (lower.contains('deporte') || lower.contains('gym') || lower.contains('fitness')) {
      return 'deporte';
    } else if (lower.contains('belleza') || lower.contains('spa') || lower.contains('estetica')) {
      return 'belleza';
    } else if (lower.contains('salud') || lower.contains('medico') || lower.contains('farmacia')) {
      return 'salud';
    } else if (lower.contains('ropa') || lower.contains('moda')) {
      return 'ropa';
    } else if (lower.contains('educacion') || lower.contains('escuela')) {
      return 'servicios';
    } else if (lower.contains('tecnologia')) {
      return 'tecnologia';
    } else if (lower.contains('hogar')) {
      return 'hogar';
    } else if (lower.contains('servicio')) {
      return 'servicios';
    }
    return 'otros';
  }

  static IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'comida':
        return Icons.restaurant_rounded;
      case 'deporte':
        return Icons.fitness_center_rounded;
      case 'servicios':
        return Icons.build_rounded;
      case 'belleza':
        return Icons.spa_rounded;
      case 'salud':
        return Icons.medical_services_rounded;
      case 'tecnologia':
        return Icons.devices_rounded;
      case 'ropa':
        return Icons.checkroom_rounded;
      case 'hogar':
        return Icons.home_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  static String _getCategoryDisplayName(String categoryId) {
    switch (categoryId) {
      case 'comida':
        return 'Comida';
      case 'deporte':
        return 'Deporte';
      case 'servicios':
        return 'Servicios';
      case 'belleza':
        return 'Belleza';
      case 'salud':
        return 'Salud';
      case 'tecnologia':
        return 'Tecnología';
      case 'ropa':
        return 'Moda y Ropa';
      case 'hogar':
        return 'Hogar';
      default:
        return 'Comercio';
    }
  }
}

/// Modelo de ítem de negocio (Producto, Servicio u Oferta)
class BusinessItemModel {
  final String id;
  final String businessId;
  final String itemType; // 'product' | 'service'
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int availableQuantity;
  final bool isFlashOffer;
  final double? flashPrice;
  final bool isAvailable;
  final List<String> repeatDays;

  const BusinessItemModel({
    required this.id,
    required this.businessId,
    required this.itemType,
    required this.name,
    this.description = '',
    required this.price,
    this.imageUrl = '',
    this.availableQuantity = 10,
    this.isFlashOffer = false,
    this.flashPrice,
    this.isAvailable = true,
    this.repeatDays = const [],
  });

  factory BusinessItemModel.fromJson(Map<String, dynamic> json) {
    final priceNum = json['price'];
    final flashNum = json['flash_price'];
    final daysList = json['repeat_days'] as List<dynamic>? ?? [];

    return BusinessItemModel(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      itemType: json['item_type'] as String? ?? 'product',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: priceNum is num ? priceNum.toDouble() : 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      availableQuantity: json['available_quantity'] as int? ?? 10,
      isFlashOffer: json['is_flash_offer'] as bool? ?? false,
      flashPrice: flashNum is num ? flashNum.toDouble() : null,
      isAvailable: json['is_available'] as bool? ?? true,
      repeatDays: daysList.map((d) => d.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'business_id': businessId,
      'item_type': itemType,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'available_quantity': availableQuantity,
      'is_flash_offer': isFlashOffer,
      'flash_price': flashPrice,
      'is_available': isAvailable,
      'repeat_days': repeatDays,
    };
  }

  BusinessItemModel copyWith({
    String? id,
    String? businessId,
    String? itemType,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? availableQuantity,
    bool? isFlashOffer,
    double? flashPrice,
    bool? isAvailable,
    List<String>? repeatDays,
  }) {
    return BusinessItemModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      itemType: itemType ?? this.itemType,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      isFlashOffer: isFlashOffer ?? this.isFlashOffer,
      flashPrice: flashPrice ?? this.flashPrice,
      isAvailable: isAvailable ?? this.isAvailable,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}

/// Modelo de foto de la galería del negocio
class BusinessPhotoModel {
  final String id;
  final String businessId;
  final String imageUrl;
  final int sortOrder;

  const BusinessPhotoModel({
    required this.id,
    required this.businessId,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  factory BusinessPhotoModel.fromJson(Map<String, dynamic> json) {
    return BusinessPhotoModel(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

/// Contenedor completo del negocio y sus colecciones
class BusinessFullDetails {
  final BusinessModel business;
  final List<BusinessItemModel> items;
  final List<BusinessPhotoModel> photos;

  const BusinessFullDetails({
    required this.business,
    required this.items,
    required this.photos,
  });

  List<BusinessItemModel> get products =>
      items.where((it) => it.itemType == 'product' && !it.isFlashOffer).toList();

  List<BusinessItemModel> get services =>
      items.where((it) => it.itemType == 'service' && !it.isFlashOffer).toList();

  List<BusinessItemModel> get flashOffers =>
      items.where((it) => it.isFlashOffer && it.isAvailable).toList();
}
