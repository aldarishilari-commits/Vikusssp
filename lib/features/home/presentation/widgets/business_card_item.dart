import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../business/domain/models/business_registration_model.dart';
import '../../domain/models/business_filter_criteria.dart';

class BusinessModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String address;
  final String distance;
  final double distanceKm;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewsCount;
  final bool isOpen;
  final String closingTime;
  final String? promoBadge;
  final String imageUrl;
  final IconData categoryIcon;
  final bool isFavorite;
  final Map<String, DaySchedule>? schedules;
  final PriceLevel priceLevel;
  final String phoneNumber;
  final String phoneCountryCode;
  final String facebook;
  final String instagram;
  final String tiktok;
  final String website;
  final List<String> photoUrls;

  const BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    required this.distance,
    this.distanceKm = 0.3,
    this.latitude = -16.5050,
    this.longitude = -68.1290,
    this.rating = 4.0,
    this.reviewsCount = 24,
    this.isOpen = true,
    this.closingTime = '19:00',
    this.promoBadge,
    required this.imageUrl,
    this.categoryIcon = Icons.storefront_rounded,
    this.isFavorite = false,
    this.schedules,
    this.priceLevel = PriceLevel.economic,
    this.phoneNumber = '70123456',
    this.phoneCountryCode = '+591',
    this.facebook = '',
    this.instagram = '',
    this.tiktok = '',
    this.website = '',
    this.photoUrls = const [],
  });

  /// Lista de fotos completa o imagen principal
  List<String> get resolvedPhotos {
    if (photoUrls.isNotEmpty) return photoUrls;
    if (imageUrl.isNotEmpty) return [imageUrl];
    return const [];
  }

  /// Retorna los horarios completos del negocio (o genera un cronograma semanal coherente si no fue provisto)
  Map<String, DaySchedule> get resolvedSchedules {
    if (schedules != null && schedules!.isNotEmpty) {
      return schedules!;
    }

    final parts = closingTime.split(':');
    final closeH = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 19) : 19;
    final closeM = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final closeTod = TimeOfDay(hour: closeH, minute: closeM);

    return {
      'Lunes': DaySchedule(dayName: 'Lunes', isOpen: isOpen, closeTime: closeTod),
      'Martes': DaySchedule(dayName: 'Martes', isOpen: isOpen, closeTime: closeTod),
      'Miercoles': DaySchedule(dayName: 'Miercoles', isOpen: isOpen, closeTime: closeTod),
      'Jueves': DaySchedule(dayName: 'Jueves', isOpen: isOpen, closeTime: closeTod),
      'Viernes': DaySchedule(dayName: 'Viernes', isOpen: isOpen, closeTime: closeTod),
      'Sabado': DaySchedule(dayName: 'Sabado', isOpen: isOpen, closeTime: closeTod),
      'Domingo': DaySchedule(dayName: 'Domingo', isOpen: isOpen, closeTime: closeTod),
    };
  }

  /// Obtiene el horario para un día de la semana (1 = Lunes ... 7 = Domingo)
  DaySchedule? getScheduleForWeekday(int weekday) {
    final map = resolvedSchedules;
    switch (weekday) {
      case 1:
        return map['Lunes'] ?? map['lunes'];
      case 2:
        return map['Martes'] ?? map['martes'];
      case 3:
        return map['Miercoles'] ?? map['Miércoles'] ?? map['miercoles'] ?? map['miércoles'];
      case 4:
        return map['Jueves'] ?? map['jueves'];
      case 5:
        return map['Viernes'] ?? map['viernes'];
      case 6:
        return map['Sabado'] ?? map['Sábado'] ?? map['sabado'] ?? map['sábado'];
      case 7:
        return map['Domingo'] ?? map['domingo'];
      default:
        return null;
    }
  }

  /// Horario correspondiente al día de hoy
  DaySchedule? get todaySchedule => getScheduleForWeekday(DateTime.now().weekday);

  /// Indica si el negocio se encuentra actualmente abierto según la hora y día actual
  bool get isCurrentlyOpenNow {
    if (!isOpen) return false;
    final now = DateTime.now();
    final today = todaySchedule;
    if (today != null) {
      return today.isCurrentlyOpen(now);
    }
    return true;
  }

  /// Texto descriptivo del estado actual (ej: "Abierto · Cierra a las 19:00" o "Cerrado · Abre hoy a las 08:00")
  String get currentScheduleStatusText {
    final now = DateTime.now();
    final today = todaySchedule;
    if (today == null) {
      return isOpen ? 'Abierto · Cierra a las $closingTime' : 'Cerrado';
    }

    if (today.isOpen) {
      final currentMin = now.hour * 60 + now.minute;
      final openMin = today.openTime.hour * 60 + today.openTime.minute;
      final closeMin = today.closeTime.hour * 60 + today.closeTime.minute;

      if (closeMin >= openMin) {
        if (currentMin < openMin) {
          return 'Cerrado · Abre hoy a las ${today.formattedOpenTime}';
        } else if (currentMin < closeMin) {
          return 'Abierto · Cierra a las ${today.formattedCloseTime}';
        } else {
          return 'Cerrado · Abre mañana';
        }
      } else {
        if (currentMin >= openMin || currentMin < closeMin) {
          return 'Abierto · Cierra a las ${today.formattedCloseTime}';
        } else {
          return 'Cerrado · Abre hoy a las ${today.formattedOpenTime}';
        }
      }
    } else {
      return 'Cerrado hoy';
    }
  }

  /// Subtítulo del estado (ej. "Cierra a las 19:00", "Abre a las 08:00", "Abre mañana")
  String get scheduleStatusSubtitle {
    final now = DateTime.now();
    final today = todaySchedule;
    if (today == null) {
      return isOpen ? 'Cierra a las $closingTime' : 'Cerrado';
    }

    if (today.isOpen) {
      final currentMin = now.hour * 60 + now.minute;
      final openMin = today.openTime.hour * 60 + today.openTime.minute;
      final closeMin = today.closeTime.hour * 60 + today.closeTime.minute;

      if (closeMin >= openMin) {
        if (currentMin < openMin) {
          return 'Abre hoy a las ${today.formattedOpenTime}';
        } else if (currentMin < closeMin) {
          return 'Cierra a las ${today.formattedCloseTime}';
        } else {
          return 'Abre mañana';
        }
      } else {
        if (currentMin >= openMin || currentMin < closeMin) {
          return 'Cierra a las ${today.formattedCloseTime}';
        } else {
          return 'Abre hoy a las ${today.formattedOpenTime}';
        }
      }
    } else {
      return 'Cerrado hoy';
    }
  }

  /// Evalúa si el negocio cumple con los criterios de filtro activos
  bool matchesFilter(BusinessFilterCriteria criteria) {
    // 1. Filtro de distancia máxima (solo restringe si el usuario definió un límite explícito)
    if (criteria.maxDistanceKm != null && distanceKm > criteria.maxDistanceKm!) {
      return false;
    }

    // 2. Filtro de abierto ahora
    if (criteria.onlyOpen && !isCurrentlyOpenNow) {
      return false;
    }

    // 3. Filtro de solo con ofertas
    if (criteria.onlyOffers && promoBadge == null) {
      return false;
    }

    // 4. Filtro de nivel de precio
    if (criteria.selectedPrices.isNotEmpty &&
        !criteria.selectedPrices.contains(priceLevel)) {
      return false;
    }

    return true;
  }

  BusinessModel copyWith({
    bool? isFavorite,
    double? latitude,
    double? longitude,
    String? address,
    String? distance,
    double? distanceKm,
    bool? isOpen,
    String? closingTime,
    Map<String, DaySchedule>? schedules,
    PriceLevel? priceLevel,
    String? phoneNumber,
    String? phoneCountryCode,
    String? facebook,
    String? instagram,
    String? tiktok,
    String? website,
    List<String>? photoUrls,
  }) {
    return BusinessModel(
      id: id,
      name: name,
      category: category,
      description: description,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating,
      reviewsCount: reviewsCount,
      isOpen: isOpen ?? this.isOpen,
      closingTime: closingTime ?? this.closingTime,
      promoBadge: promoBadge,
      imageUrl: imageUrl,
      categoryIcon: categoryIcon,
      isFavorite: isFavorite ?? this.isFavorite,
      schedules: schedules ?? this.schedules,
      priceLevel: priceLevel ?? this.priceLevel,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      website: website ?? this.website,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}

class BusinessCardItem extends StatefulWidget {
  final BusinessModel business;
  final ValueChanged<bool>? onFavoriteToggle;
  final VoidCallback? onTap;
  final bool showDivider;

  const BusinessCardItem({
    super.key,
    required this.business,
    this.onFavoriteToggle,
    this.onTap,
    this.showDivider = true,
  });

  @override
  State<BusinessCardItem> createState() => _BusinessCardItemState();
}

class _BusinessCardItemState extends State<BusinessCardItem> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoritesService.instance.isBusinessFavorite(widget.business.id) || widget.business.isFavorite;
  }

  @override
  void didUpdateWidget(covariant BusinessCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isFavorite = FavoritesService.instance.isBusinessFavorite(widget.business.id) || widget.business.isFavorite;
  }

  void _toggleFavorite() {
    final newFav = FavoritesService.instance.toggleBusinessFavorite(widget.business, context);
    setState(() {
      _isFavorite = newFav;
    });
    widget.onFavoriteToggle?.call(newFav);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.business;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Image with Favorite Heart Button
                  Stack(
                    children: [
                      Container(
                        width: 114,
                        height: 114,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          b.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            color: isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB),
                            alignment: Alignment.center,
                            child: Icon(
                              b.categoryIcon,
                              size: 32,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: _toggleFavorite,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _isFavorite
                                  ? const Color(0xFFEF4444)
                                  : Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 13),

                  // Right Details
                  Expanded(
                    child: SizedBox(
                      height: 114,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top group: Header, Rating Badge, Description
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Icon + Name + Promo Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 19,
                                          height: 19,
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF334155) : const Color(0xFF475569),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            b.categoryIcon,
                                            color: Colors.white,
                                            size: 10.5,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            b.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white : AppColors.textMain,
                                              letterSpacing: -0.1,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (b.promoBadge != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.proOrange,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        b.promoBadge!,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Rating Badge & Reviews
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5.5,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF78350F).withValues(alpha: 0.4)
                                          : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: 12,
                                          color: isDark
                                              ? const Color(0xFFFBBF24)
                                              : const Color(0xFFD97706),
                                        ),
                                        const SizedBox(width: 2.5),
                                        Text(
                                          b.rating.toStringAsFixed(1),
                                          style: GoogleFonts.inter(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDark
                                                ? const Color(0xFFFBBF24)
                                                : const Color(0xFF92400E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '(${b.reviewsCount} opiniones)',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),

                              // Description
                              Text(
                                b.description,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: isDark ? const Color(0xFF9CA3AF) : AppColors.textGrey,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // Bottom group: Location & Schedule
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location with Highlighted Distance
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 12.5,
                                    color: Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: '${b.address} · ',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: b.distance,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2.5),

                              // Schedule Status
                              Row(
                                children: [
                                  Container(
                                    width: 5.5,
                                    height: 5.5,
                                    decoration: BoxDecoration(
                                      color: b.isCurrentlyOpenNow
                                          ? AppColors.statusOpen
                                          : const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    b.isCurrentlyOpenNow ? 'Abierto' : 'Cerrado',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: b.isCurrentlyOpenNow
                                          ? AppColors.statusOpen
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                  Text(
                                    ' · ${b.scheduleStatusSubtitle}',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Minimalist Divider Line with clear presence
            if (widget.showDivider)
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 4),
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151) // Gris definido para modo oscuro
                        : const Color(0xFFCBD5E1), // Gris slate con excelente contraste para modo claro
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
