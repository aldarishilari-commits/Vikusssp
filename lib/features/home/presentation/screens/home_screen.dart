import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/google_maps_config.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../business/presentation/screens/business_profile_screen.dart';
import '../../../categories/presentation/screens/category_screen.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../../../offers/presentation/screens/offers_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_carousel_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../domain/models/business_filter_criteria.dart';
import '../widgets/business_card_item.dart';
import '../widgets/category_carousel.dart';
import '../widgets/city_selector_bottom_sheet.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/flash_offers_carousel.dart';
import '../widgets/home_header.dart';
import '../widgets/pro_featured_section.dart';
import '../widgets/quick_filter_chips.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({
    super.key,
    this.title = 'Vikus',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCity = 'Pando';
  int _currentNavTab = 0;
  final TextEditingController _searchController = TextEditingController();
  BusinessFilterCriteria _filterCriteria = BusinessFilterCriteria();
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _loadUserCity();
    _initUserLocation();
    _searchController.addListener(() {
      setState(() {});
    });
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

  Future<void> _loadUserCity() async {
    final profile = await ProfileService().getCurrentProfile();
    if (mounted && profile != null && profile.city.isNotEmpty) {
      setState(() {
        _selectedCity = profile.city;
      });
    }
  }

  final List<BusinessModel> _businesses = [
    const BusinessModel(
      id: 'biz_1',
      name: 'BODY XTREME',
      category: 'Deporte',
      description: 'Pesas y máquinas de musculación, entrenadores certificados.',
      address: 'Av. Pando',
      distance: '300 m de ti',
      distanceKm: 0.3,
      latitude: -16.5020,
      longitude: -68.1235,
      rating: 4.0,
      reviewsCount: 24,
      isOpen: true,
      closingTime: '19:00',
      promoBadge: 'OFERTA',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCyINktqnqAPIa5mHhsKj5Vu990wQ9AhWcODtqCxlx3qRIDttuEhzHckRH1saykU-rRE1GJmi7XPktmZ0ZS3PIdyHl9cz43KiupG7lifDx0ZjujYVPP0igyvsk6Fp4_rmqvLWwJho2gsJH-SdFZgh33v-e6aHeOPtpdHi1eXUctYjnto_OIIYSrnvL3AXiLHYkoPQYE2WRvP0HhihrhaEsv4pWBMvv_r848FMvHuD5wcKZyR7Oconnl_Q',
      categoryIcon: Icons.fitness_center_rounded,
      priceLevel: PriceLevel.economic,
      facebook: 'https://facebook.com/bodyxtremelapaz',
      instagram: 'bodyxtreme.bo',
      tiktok: 'bodyxtremelapaz',
      website: 'https://bodyxtreme.com',
    ),
    const BusinessModel(
      id: 'biz_2',
      name: 'BODY XTREME SAN PEDRO',
      category: 'Deporte',
      description: 'Gym con atención cercana, spinning y precios accesibles.',
      address: 'Av. Pando',
      distance: '600 m de ti',
      distanceKm: 0.6,
      latitude: -16.5045,
      longitude: -68.1270,
      rating: 4.0,
      reviewsCount: 24,
      isOpen: true,
      closingTime: '19:00',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA7mNzO7orlhCzyqvQfW3humsoIYpy4YsUHdpx61rAqLiTXTrobKq4TA3fq3I6cVei8kAVrGXuHsvR2hykQqT5VXDbjJ1gI3bcnuia3aW7Iug4-q4n8wvEbYFOPxP1BsIObR6iDxv_EXnIIHA1oP3WYdt_VrLngOfBcEsLnYrXHa5TAiAIyAzQs_UHGamp_jzyZYWg_qbYzjyDjfCThK1nk1BuZRT3V3FhyIvJJ2QmOJ9ew9XL7wBpM_g',
      categoryIcon: Icons.fitness_center_rounded,
      priceLevel: PriceLevel.medium,
      facebook: 'https://facebook.com/bodyxtremesanpedro',
      instagram: 'bodyxtreme.sanpedro',
      tiktok: 'bodyxtreme_bo',
      website: 'https://bodyxtreme.com',
    ),
    const BusinessModel(
      id: 'biz_3',
      name: 'PIZZA CENTER',
      category: 'Comida',
      description: 'Pizzas al horno de piedra, pastas y promociones familiares.',
      address: 'Av. Principal',
      distance: '1.2 km de ti',
      distanceKm: 1.2,
      latitude: -16.5090,
      longitude: -68.1310,
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
      id: 'biz_4',
      name: 'BODY XTREME FITNESS',
      category: 'Deporte',
      description: 'Clases grupales de crossfit, zumba y entrenamiento funcional.',
      address: 'Av. Pando',
      distance: '2.8 km de ti',
      distanceKm: 2.8,
      latitude: -16.5220,
      longitude: -68.1380,
      rating: 4.0,
      reviewsCount: 24,
      isOpen: true,
      closingTime: '19:00',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDmTcgLLNYv43d95Ah0SK9RyrpIBbzLgLR0RgfwMW9_O6sBTgmuq6bkiKuakecmuBTvaokLgbHH2hWKuXBw34XEp0Oz80Twq6gCdAHlMw7IpHJyUEzow0VNzNw3qe_IaQerPh1a1fbX0u4ULUOBsKvP2gcI_7ozszJMnOXsGjxEQD28c9VxtWNaSH2V8zxrBSSLw61kLzlX3f60P_w363P-XtTuVL3-sPMjenhUYlRi9UzIc5FEZ1xMtw',
      categoryIcon: Icons.fitness_center_rounded,
      priceLevel: PriceLevel.premium,
      facebook: 'https://facebook.com/bodyxtremefitness',
      instagram: 'bodyxtreme.fitness',
      tiktok: 'bodyxtremefitness',
      website: 'https://bodyxtreme.com',
    ),
    const BusinessModel(
      id: 'biz_5',
      name: 'CAFÉ DEL VALLE',
      category: 'Comida',
      description: 'Café de especialidad de altura, pastelería artesanal y brunch.',
      address: 'Calle 21 de Calacoto',
      distance: '3.5 km de ti',
      distanceKm: 3.5,
      latitude: -16.5280,
      longitude: -68.1420,
      rating: 4.7,
      reviewsCount: 45,
      isOpen: true,
      closingTime: '21:00',
      promoBadge: 'DESAYUNO',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDa_GjJLeIkJpaN8Aq5F5gwAFE80r0L6l-4e3R0v2b4uMTgNAQYafhjr4kCyoH9ITj3n377qDs7FMrhg9TVYivy691f9XwS15nObZYssq5R8JomhyCK-Mo4wLPqFthSOdrBWQMc4_7djZn-pABc8MsYzk93dReSeLambeqJl7Y31VlJegBLi7AXEbzdhpmBJT3Dif5aSSXLw9QxSOFNYuNkIGNOqasEWTVW_f4EqrZSJMskF8s_aC3m3g',
      categoryIcon: Icons.local_cafe_rounded,
      priceLevel: PriceLevel.medium,
      facebook: 'https://facebook.com/cafedelvallebolivia',
      instagram: 'cafedelvalle.bo',
      tiktok: 'cafedelvallebo',
      website: 'https://cafedelvalle.bo',
    ),
    const BusinessModel(
      id: 'biz_6',
      name: 'SPA & WELLNESS ILLIMANI',
      category: 'Salud',
      description: 'Masajes relajantes, sauna seco y tratamientos faciales holísticos.',
      address: 'Av. Ballivián',
      distance: '4.8 km de ti',
      distanceKm: 4.8,
      latitude: -16.5380,
      longitude: -68.1500,
      rating: 4.9,
      reviewsCount: 62,
      isOpen: false,
      closingTime: '20:00',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBa_lzu6msUQhDmn4b8jiPIAl_Mbt2ppNQX3wm6R9F2hvLZsAbnx2hnyZMlH9H2tNNuhoHFPzoITFHXauAW15eiHKus6zIxcv59pZ0mXNXjUL4MQjsKvHNnoAXivbyqOY8edg7eV3v7FWvuOZ01xIU8N3AMyCpN64xUAr2zF0RWfVh3iTc24T_L0vmPbw880l1s1CYmJyV-nrp9gFs5RhEmSLKrU4FUDAPpQ6O56yXlsubGgg0Rm6Jnwg',
      categoryIcon: Icons.spa_rounded,
      priceLevel: PriceLevel.premium,
      facebook: 'https://facebook.com/spaillimanilp',
      instagram: 'spaillimani.bo',
      tiktok: 'spaillimani',
      website: 'https://spaillimani.bo',
    ),
  ];

  List<BusinessModel> get _filteredBusinesses {
    final query = _searchController.text.trim().toLowerCase();
    final double userLat =
        _userPosition?.latitude ?? GoogleMapsConfig.defaultLatitude;
    final double userLng =
        _userPosition?.longitude ?? GoogleMapsConfig.defaultLongitude;

    // 1. Recalcular distancia real exacta para cada negocio según GPS del usuario y coordenadas registradas
    final businessesWithDistance = _businesses.map((b) {
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
      // Búsqueda por texto
      if (query.isNotEmpty) {
        final matchName = b.name.toLowerCase().contains(query);
        final matchCat = b.category.toLowerCase().contains(query);
        final matchDesc = b.description.toLowerCase().contains(query);
        if (!matchName && !matchCat && !matchDesc) return false;
      }

      // Criterios de filtro combinados (distancia <= maxDistanceKm, abierto, ofertas, precio)
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

  void _openCitySelector() {
    CitySelectorBottomSheet.show(
      context,
      currentCity: _selectedCity,
      onSelected: (newCity) {
        setState(() {
          _selectedCity = newCity;
        });
        ProfileService().updateCity(newCity);
      },
    );
  }

  void _onCategorySelected(CategoryItemModel category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          categoryId: category.id,
          categoryTitle: category.title == 'Ver más' ? 'Todas las Categorías' : category.title,
          emoji: category.emoji,
        ),
      ),
    );
  }

  void _onFavoriteToggled(String businessId, bool isFav) {
    // Favoritos se actualiza visualmente sin mostrar mensaje intrusivo
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const OnboardingCarouselScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Location Selector & Notifications (visible in Home tab)
            if (_currentNavTab == 0)
              HomeHeader(
                currentCity: _selectedCity,
                onLocationTap: _openCitySelector,
              ),

            // Main Tab Content (Zero Placeholders - 4 Production Grade Screens)
            Expanded(
              child: _buildCurrentTab(),
            ),

            // Fixed Bottom Navigation Bar
            CustomBottomNavBar(
              currentIndex: _currentNavTab,
              onTabSelected: (index) {
                setState(() {
                  _currentNavTab = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentNavTab) {
      case 0:
        return _buildMainHomeFeed();
      case 1:
        return const OffersScreen();
      case 2:
        return FavoritesScreen(
          onExploreTap: () => setState(() => _currentNavTab = 0),
        );
      case 3:
        return ProfileScreen(
          selectedCity: _selectedCity,
          onCityChange: _openCitySelector,
          onLogout: _logout,
        );
      default:
        return _buildMainHomeFeed();
    }
  }

  Widget _buildMainHomeFeed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          SearchBarWidget(
            controller: _searchController,
            hintText: '¿Qué buscas hoy en $_selectedCity?',
          ),
          const SizedBox(height: 6),

          // Categories Horizontal Row
          CategoryCarousel(
            onCategoryTap: _onCategorySelected,
          ),
          const SizedBox(height: 6),

          // Flash Offers Carousel
          const FlashOffersCarousel(),
          const SizedBox(height: 8),

          // Quick Filters (Filtros(1).png)
          QuickFilterChips(
            criteria: _filterCriteria,
            onCriteriaChanged: (newCriteria) {
              setState(() {
                _filterCriteria = newCriteria;
              });
            },
          ),
          const SizedBox(height: 12),

          // Section Title: Negocios cerca de ti
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
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
                      color: AppColors.primary.withValues(alpha: 0.1),
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

          // Business Cards List or Empty State
          if (_filteredBusinesses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.filter_alt_off_rounded,
                      size: 32,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No encontramos negocios con estos filtros',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Prueba ampliando la distancia o desactivando filtros.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _filterCriteria.clear();
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Limpiar todos los filtros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
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
                  onFavoriteToggle: (isFav) => _onFavoriteToggled(b.id, isFav),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BusinessProfileScreen(
                          business: b,
                          onFavoriteToggle: (isFav) => _onFavoriteToggled(b.id, isFav),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

          // PRO Featured Businesses Section
          ProFeaturedSection(
            onBusinessTap: (pro) {
              final matched = _businesses.firstWhere(
                (b) => b.name.toLowerCase().contains(pro.name.toLowerCase().split(' ').first),
                orElse: () => BusinessModel(
                  id: pro.id,
                  name: pro.name,
                  category: 'Destacado PRO',
                  description: 'Comercio certificado con atención premium y promociones exclusivas en Vikus.',
                  address: 'Av. Principal',
                  distance: pro.distance,
                  rating: 4.9,
                  reviewsCount: 58,
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
    );
  }
}
