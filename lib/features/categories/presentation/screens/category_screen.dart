import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/google_maps_config.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../business/presentation/screens/business_profile_screen.dart';
import 'package:aeronpulse/features/home/domain/models/business_filter_criteria.dart';
import '../../../home/presentation/widgets/business_card_item.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/flash_offers_carousel.dart';
import '../../../home/presentation/widgets/pro_featured_section.dart';
import '../../../home/presentation/widgets/quick_filter_chips.dart';
import '../../../home/presentation/widgets/search_bar_widget.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final String emoji;

  const CategoryScreen({
    super.key,
    this.categoryId = 'comida',
    this.categoryTitle = 'Comida',
    this.emoji = '🍔',
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentNavTab = 0;
  BusinessFilterCriteria _filterCriteria = BusinessFilterCriteria();
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _initUserLocation();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _initUserLocation() async {
    final pos = await LocationService.getUserPositionWithFallback(
      fallbackLat: GoogleMapsConfig.defaultLatitude,
      fallbackLng: GoogleMapsConfig.defaultLongitude,
    );
    if (mounted) {
      setState(() {
        _userPosition = pos;
      });
    }
  }

  final List<BusinessModel> _foodBusinesses = [
    const BusinessModel(
      id: 'food_1',
      name: 'PIZZA CENTER',
      category: 'Comida',
      description: 'Pizzas artesanales al horno de leña, pastas y calzones.',
      address: 'Av. Pando',
      distance: '300 m de ti',
      distanceKm: 0.3,
      latitude: -16.5020,
      longitude: -68.1235,
      rating: 4.8,
      reviewsCount: 86,
      isOpen: true,
      closingTime: '23:00',
      promoBadge: '2X1 HOY',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDWx20X9KGhQhhzDwvHmMeqyrqxRuDNPNO-3MhtvG8QErbTZJx_FLjulmAiD6orhyw34AfrjRP44VRBjr_Rjw5b4KiW5VklGmYsI7_jQ-YGceqhTdyCxBuT_nXHDale8_oQaNVpkPa7DslIo_rnrDDoATJj7NmHTpkscuB9Y4YJNFLcnL5JCX4irHz8PCH77Uiiz4v4zNyB-kXzF3jyqC53wHvN4a57GzZdr24nv4IreQMhCEbYgHkPWg',
      categoryIcon: Icons.local_pizza_rounded,
      priceLevel: PriceLevel.economic,
      facebook: 'https://facebook.com/pizzacenterlapaz',
      instagram: 'pizzacenter.bo',
      tiktok: 'pizzacenterbo',
      website: 'https://pizzacenter.bo',
    ),
    const BusinessModel(
      id: 'food_2',
      name: 'BURGER ROCK',
      category: 'Comida',
      description:
          'Hamburguesas gourmet con carne 100% Angus y papas rústicas.',
      address: 'Calle Murillo',
      distance: '450 m de ti',
      distanceKm: 0.45,
      latitude: -16.5035,
      longitude: -68.1230,
      rating: 4.6,
      reviewsCount: 52,
      isOpen: true,
      closingTime: '22:30',
      promoBadge: '30% DSCTO',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDa_GjJLeIkJpaN8Aq5F5gwAFE80r0L6l-4e3R0v2b4uMTgNAQYafhjr4kCyoH9ITj3n377qDs7FMrhg9TVYivy691f9XwS15nObZYssq5R8JomhyCK-Mo4wLPqFthSOdrBWQMc4_7djZn-pABc8MsYzk93dReSeLambeqJl7Y31VlJegBLi7AXEbzdhpmBJT3Dif5aSSXLw9QxSOFNYuNkIGNOqasEWTVW_f4EqrZSJMskF8s_aC3m3g',
      categoryIcon: Icons.lunch_dining_rounded,
      priceLevel: PriceLevel.medium,
      facebook: 'https://facebook.com/burgerrocklp',
      instagram: 'burgerrock.bo',
      tiktok: 'burgerrockbo',
      website: 'https://burgerrock.bo',
    ),
    const BusinessModel(
      id: 'food_3',
      name: 'TACOS & BURRITOS EL CHARRO',
      category: 'Comida',
      description:
          'Auténtica gastronomía mexicana, salsas artesanales y quesadillas.',
      address: 'Plaza Principal',
      distance: '600 m de ti',
      distanceKm: 0.6,
      latitude: -16.5045,
      longitude: -68.1270,
      rating: 4.5,
      reviewsCount: 39,
      isOpen: true,
      closingTime: '00:00',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBWoGdKRNB1JG2mY7fohgvjDZrpYCn4IPucG4xKkSeWy6t7PHeUOrdv1I4m15oeBwKD8zj7B5-5-BVWI4Vlv2fNGvpaXChiWDHPClABJ2vXbk9tJmORrufb2X-O1aQe55bs77SJjenACanxbXJBeEaodJpv3xqX1SsH6vlS_alo0oa7stj8i03vTii6nZnw8021-3P8U5Fiv6cvOZHzEwd9xF91b3HahskVBJsXGdEQBZzjwukmX3Mi-Q',
      categoryIcon: Icons.restaurant_rounded,
      priceLevel: PriceLevel.premium,
      facebook: 'https://facebook.com/elcharrobolivia',
      instagram: 'elcharro.bo',
      tiktok: 'elcharrobo',
      website: 'https://elcharro.bo',
    ),
    const BusinessModel(
      id: 'food_4',
      name: 'RESTAURANTE EL FOGÓN ANDINO',
      category: 'Comida',
      description: 'Platos tradicionales, sopa de maní y parrilladas familiares.',
      address: 'Av. Las Américas',
      distance: '2.8 km de ti',
      distanceKm: 2.8,
      latitude: -16.5220,
      longitude: -68.1380,
      rating: 4.7,
      reviewsCount: 68,
      isOpen: true,
      closingTime: '22:00',
      promoBadge: 'ESPECIAL',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
      categoryIcon: Icons.soup_kitchen_rounded,
      priceLevel: PriceLevel.economic,
      facebook: 'https://facebook.com/elfogonandino',
      instagram: 'fogonandino.bo',
      tiktok: 'fogonandino',
      website: 'https://elfogonandino.bo',
    ),
    const BusinessModel(
      id: 'food_5',
      name: 'BISTRO GOURMET LA CASONA',
      category: 'Comida',
      description: 'Cocina de autor internacional, maridaje de vinos y postres finos.',
      address: 'Calle Sagárnaga',
      distance: '3.5 km de ti',
      distanceKm: 3.5,
      latitude: -16.5280,
      longitude: -68.1420,
      rating: 4.9,
      reviewsCount: 94,
      isOpen: true,
      closingTime: '23:30',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDmTcgLLNYv43d95Ah0SK9RyrpIBbzLgLR0RgfwMW9_O6sBTgmuq6bkiKuakecmuBTvaokLgbHH2hWKuXBw34XEp0Oz80Twq6gCdAHlMw7IpHJyUEzow0VNzNw3qe_IaQerPh1a1fbX0u4ULUOBsKvP2gcI_7ozszJMnOXsGjxEQD28c9VxtWNaSH2V8zxrBSSLw61kLzlX3f60P_w363P-XtTuVL3-sPMjenhUYlRi9UzIc5FEZ1xMtw',
      categoryIcon: Icons.dinner_dining_rounded,
      priceLevel: PriceLevel.premium,
      facebook: 'https://facebook.com/lacasonabistro',
      instagram: 'lacasona.bistro',
      tiktok: 'lacasonabistro',
      website: 'https://lacasonabistro.bo',
    ),
  ];

  final List<ProBusinessModel> _proFood = [
    const ProBusinessModel(
      id: 'pro_food_1',
      name: 'PIZZA CENTER PRO',
      distance: 'A 300 m de ti',
      isOpen: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDWx20X9KGhQhhzDwvHmMeqyrqxRuDNPNO-3MhtvG8QErbTZJx_FLjulmAiD6orhyw34AfrjRP44VRBjr_Rjw5b4KiW5VklGmYsI7_jQ-YGceqhTdyCxBuT_nXHDale8_oQaNVpkPa7DslIo_rnrDDoATJj7NmHTpkscuB9Y4YJNFLcnL5JCX4irHz8PCH77Uiiz4v4zNyB-kXzF3jyqC53wHvN4a57GzZdr24nv4IreQMhCEbYgHkPWg',
    ),
    const ProBusinessModel(
      id: 'pro_food_2',
      name: 'BURGER GOURMET VIP',
      distance: 'A 450 m de ti',
      isOpen: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBa_lzu6msUQhDmn4b8jiPIAl_Mbt2ppNQX3wm6R9F2hvLZsAbnx2hnyZMlH9H2tNNuhoHFPzoITFHXauAW15eiHKus6zIxcv59pZ0mXNXjUL4MQjsKvHNnoAXivbyqOY8edg7eV3v7FWvuOZ01xIU8N3AMyCpN64xUAr2zF0RWfVh3iTc24T_L0vmPbw880l1s1CYmJyV-nrp9gFs5RhEmSLKrU4FUDAPpQ6O56yXlsubGgg0Rm6Jnwg',
    ),
  ];

  List<BusinessModel> get _filteredBusinesses {
    final query = _searchController.text.trim().toLowerCase();
    final double userLat =
        _userPosition?.latitude ?? GoogleMapsConfig.defaultLatitude;
    final double userLng =
        _userPosition?.longitude ?? GoogleMapsConfig.defaultLongitude;

    // 1. Recalcular distancia real exacta para cada negocio según GPS del usuario y coordenadas registradas
    final businessesWithDistance = _foodBusinesses.map((b) {
      final double distanceMeters = LocationService.calculateDistanceInMeters(
        startLatitude: userLat,
        startLongitude: userLng,
        endLatitude: b.latitude,
        endLongitude: b.longitude,
      );
      final double distanceKm = distanceMeters / 1000.0;
      final String formattedDistance =
          LocationService.formatDistance(distanceMeters);

      return b.copyWith(
        distanceKm: distanceKm,
        distance: formattedDistance,
      );
    }).toList();

    // 2. Filtrar por búsqueda y criterios de filtro (incluyendo distancia máxima)
    final filtered = businessesWithDistance.where((b) {
      if (query.isNotEmpty) {
        final matchName = b.name.toLowerCase().contains(query);
        final matchCat = b.category.toLowerCase().contains(query);
        final matchDesc = b.description.toLowerCase().contains(query);
        if (!matchName && !matchCat && !matchDesc) return false;
      }
      return b.matchesFilter(_filterCriteria);
    }).toList();

    // 3. Ordenar automáticamente de menor a mayor distancia (más cercano -> más lejano)
    filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoriteToggled(String businessId, bool isFav) {
    // Favoritos se actualiza visualmente sin mostrar mensaje intrusivo
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Back Button & Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : AppColors.textMain,
                      size: 22,
                    ),
                    tooltip: 'Volver',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.categoryTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textMain,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (widget.emoji.isNotEmpty)
                    Text(widget.emoji, style: const TextStyle(fontSize: 22)),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    SearchBarWidget(
                      controller: _searchController,
                      hintText:
                          'Buscar en ${widget.categoryTitle.toLowerCase()}...',
                    ),
                    const SizedBox(height: 10),

                    // Flash Offers Carousel
                    const FlashOffersCarousel(),
                    const SizedBox(height: 8),

                    // Quick Filter Chips (Filtros(1).png)
                    QuickFilterChips(
                      criteria: _filterCriteria,
                      onCriteriaChanged: (newCriteria) {
                        setState(() {
                          _filterCriteria = newCriteria;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Section: Negocios cerca de ti
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFEF4444),
                            size: 19,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Negocios cerca de ti',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textMain,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (_filterCriteria.hasActiveFilters) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_filteredBusinesses.length} resultados',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Food Business Cards or Empty State
                    if (_filteredBusinesses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : Colors.transparent,
                                  ),
                                ),
                                child: Icon(
                                  Icons.filter_alt_off_rounded,
                                  size: 30,
                                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No encontramos negocios con estos filtros',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Prueba ajustando la distancia o limpiando filtros.',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _filterCriteria.clear();
                                    _searchController.clear();
                                  });
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Limpiar filtros'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredBusinesses.length,
                        itemBuilder: (context, index) {
                          final b = _filteredBusinesses[index];
                          return BusinessCardItem(
                            business: b,
                            onFavoriteToggle: (isFav) =>
                                _onFavoriteToggled(b.id, isFav),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BusinessProfileScreen(
                                    business: b,
                                    onFavoriteToggle: (isFav) =>
                                        _onFavoriteToggled(b.id, isFav),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                    // PRO Featured Section
                    ProFeaturedSection(
                      businesses: _proFood,
                      onBusinessTap: (pro) {
                        final matched = _foodBusinesses.firstWhere(
                          (b) => b.name.toLowerCase().contains(pro.name.toLowerCase().split(' ').first),
                          orElse: () => BusinessModel(
                            id: pro.id,
                            name: pro.name,
                            category: widget.categoryTitle,
                            description: 'Comercio destacado de gastronomía con atención de alta calidad.',
                            address: 'Av. Pando',
                            distance: pro.distance,
                            rating: 4.8,
                            reviewsCount: 42,
                            isOpen: pro.isOpen,
                            imageUrl: pro.imageUrl,
                          ),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BusinessProfileScreen(business: matched),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            CustomBottomNavBar(
              currentIndex: _currentNavTab,
              onTabSelected: (index) {
                if (index == 0) {
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    _currentNavTab = index;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
