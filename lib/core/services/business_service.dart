import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'auth_service.dart';
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
