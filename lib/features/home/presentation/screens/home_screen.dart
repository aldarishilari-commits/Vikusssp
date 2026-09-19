import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/google_maps_config.dart';
import '../../../../core/services/business_service.dart';
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

  List<BusinessModel> _businesses = [];
  bool _isLoadingBusinesses = true;

  @override
  void initState() {
    super.initState();
    _loadUserCity();
    _initUserLocation();
    _loadBusinesses();
    _searchController.addListener(_onSearchChanged);
    BusinessService.instance.businessUpdatesNotifier.addListener(_loadBusinesses);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _loadBusinesses() async {
    try {
      final list = await BusinessService.instance.getBusinesses(
        city: _selectedCity,
      );
      if (mounted) {
        setState(() {
          _businesses = list;
          _isLoadingBusinesses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBusinesses = false;
        });
      }
    }
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

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .trim();
  }

  List<BusinessModel> get _filteredBusinesses {
    final query = _normalize(_searchController.text);
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
      // Búsqueda por texto (nombre, categoría, descripción, dirección)
      if (query.isNotEmpty) {
        final matchName = _normalize(b.name).contains(query);
        final matchCat = _normalize(b.category).contains(query);
        final matchDesc = _normalize(b.description).contains(query);
        final matchAddress = _normalize(b.address).contains(query);
        if (!matchName && !matchCat && !matchDesc && !matchAddress) return false;
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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    BusinessService.instance.businessUpdatesNotifier.removeListener(_loadBusinesses);
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
    final isSearching = _searchController.text.trim().isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadBusinesses,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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

            // Section Title: Negocios cerca de ti / Resultados de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isSearching ? Icons.search_rounded : Icons.location_on_rounded,
                    color: isSearching
                        ? (isDark ? const Color(0xFFC084FC) : AppColors.primary)
                        : const Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSearching ? 'Resultados de búsqueda' : 'Negocios cerca de ti',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textMain,
                      letterSpacing: -0.2,
                    ),
                  ),
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
                      '${_filteredBusinesses.length} ${_filteredBusinesses.length == 1 ? "local" : "locales"}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Business Cards List, Loading State, or Empty State
            if (_isLoadingBusinesses && _businesses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Cargando comercios desde Supabase...',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredBusinesses.isEmpty)
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
                      isSearching
                          ? 'No encontramos locales que coincidan con "${_searchController.text}"'
                          : 'No encontramos negocios con estos filtros',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Prueba buscando por otro término o ampliando los filtros.',
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
                      label: const Text('Limpiar búsqueda y filtros'),
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
            else ...[
              // Primeros 3 negocios
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredBusinesses.length > 3 ? 3 : _filteredBusinesses.length,
                itemBuilder: (context, index) {
                  final b = _filteredBusinesses[index];
                  final isLastOfGroup = index == (_filteredBusinesses.length > 3 ? 2 : _filteredBusinesses.length - 1);
                  return BusinessCardItem(
                    business: b,
                    showDivider: !isLastOfGroup,
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

              // Negocios destacados (intercalado después de 3 negocios)
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

              // Resto de negocios (del 4to en adelante)
              if (_filteredBusinesses.length > 3)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredBusinesses.length - 3,
                  itemBuilder: (context, index) {
                    final b = _filteredBusinesses[index + 3];
                    final isLast = index == (_filteredBusinesses.length - 4);
                    return BusinessCardItem(
                      business: b,
                      showDivider: !isLast,
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
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
