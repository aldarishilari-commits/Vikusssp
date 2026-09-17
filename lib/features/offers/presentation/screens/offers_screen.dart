import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/offer_model.dart';
import '../widgets/offer_card.dart';
import '../widgets/offer_filter_dialog.dart';
import '../widgets/offer_filters_bottom_sheet.dart';

class OffersScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const OffersScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  late List<OfferModel> _offers;
  OfferFilterOptions _filterOptions = const OfferFilterOptions();
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  OfferSectionType? _activeSectionFilter;

  @override
  void initState() {
    super.initState();
    _offers = OfferModel.getInitialOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String offerId, bool isFav) {
    final offer = _offers.firstWhere((o) => o.id == offerId);
    FavoritesService.instance.toggleOfferFavorite(offer, context);
    setState(() {
      _offers = _offers.map((o) {
        if (o.id == offerId) {
          return o.copyWith(isFavorite: isFav);
        }
        return o;
      }).toList();
    });
  }

  double _parseTimeRemainingHours(String timeRemaining) {
    final lower = timeRemaining.toLowerCase();
    double totalHours = 0;

    final dayMatch = RegExp(r'(\d+)\s*d').firstMatch(lower);
    if (dayMatch != null) {
      final days = double.tryParse(dayMatch.group(1) ?? '0') ?? 0;
      totalHours += days * 24;
    }

    final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(lower);
    if (hourMatch != null) {
      final hours = double.tryParse(hourMatch.group(1) ?? '0') ?? 0;
      totalHours += hours;
    }

    final minMatch = RegExp(r'(\d+)\s*(?:min|m)').firstMatch(lower);
    if (minMatch != null) {
      final mins = double.tryParse(minMatch.group(1) ?? '0') ?? 0;
      totalHours += mins / 60.0;
    }

    if (totalHours == 0 && RegExp(r'\d+').hasMatch(lower)) {
      final num = double.tryParse(RegExp(r'\d+').firstMatch(lower)?.group(0) ?? '0') ?? 0;
      totalHours = num;
    }

    return totalHours;
  }

  List<OfferModel> _getFilteredOffers() {
    return _offers.where((offer) {
      // Section filter
      if (_activeSectionFilter != null && offer.sectionType != _activeSectionFilter) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = offer.title.toLowerCase().contains(query);
        final matchesBusiness = offer.businessName.toLowerCase().contains(query);
        final matchesCategory = offer.businessCategory.toLowerCase().contains(query);
        if (!matchesTitle && !matchesBusiness && !matchesCategory) {
          return false;
        }
      }

      // Expiration filter
      if (_filterOptions.selectedExpiration != 'Todos') {
        final hours = _parseTimeRemainingHours(offer.timeRemaining);
        if (_filterOptions.selectedExpiration == 'Menos de 6 horas' && hours > 6) {
          return false;
        }
        if (_filterOptions.selectedExpiration == 'Menos de 24 horas' && hours > 24) {
          return false;
        }
        if (_filterOptions.selectedExpiration == 'Esta semana' && hours > 168) {
          return false;
        }
      }

      // Discount filter
      if (_filterOptions.selectedDiscount != 'Todos') {
        final discountNum = double.tryParse(
              offer.discountBadge.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0;
        if (_filterOptions.selectedDiscount == '15% o más' && discountNum < 15) return false;
        if (_filterOptions.selectedDiscount == '20% o más' && discountNum < 20) return false;
        if (_filterOptions.selectedDiscount == '25% o más' && discountNum < 25) return false;
        if (_filterOptions.selectedDiscount == '30% o más' && discountNum < 30) return false;
        if (_filterOptions.selectedDiscount == '40% o más' && discountNum < 40) return false;
      }

      // Business category filter
      if (_filterOptions.selectedBusinessCategory == 'De los que sigues' &&
          offer.sectionType != OfferSectionType.followingBusinesses) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFilteringActive = _filterOptions.hasActiveFilters ||
        _searchQuery.isNotEmpty ||
        _activeSectionFilter != null;

    final filteredOffers = _getFilteredOffers();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // -------------------------------------------------------------
            // TOP HEADER (Icon tag + Title + Subtitle + Search button)
            // -------------------------------------------------------------
            _buildTopHeader(isDark),

            // -------------------------------------------------------------
            // FILTER BAR (Pills for Tipo, Vencimiento, Descuento, Negocios)
            // -------------------------------------------------------------
            _buildFilterBar(isDark),

            const SizedBox(height: 8),

            // -------------------------------------------------------------
            // BODY (Filtered Grid OR 3 Sections Carousel)
            // -------------------------------------------------------------
            Expanded(
              child: isFilteringActive
                  ? _buildFilteredResultsView(filteredOffers, isDark)
                  : _buildMainOffersContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18151F) : const Color(0xFFF6F3FF),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF262130) : const Color(0xFFEDE9FE),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Purple Tag Icon with Sparkles
              _buildTagIcon(),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ofertas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Promociones que puedes aprovechar\nantes de que terminen.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Button
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                      _searchController.clear();
                    }
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF272233) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? const Color(0xFF383145) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Icon(
                    _isSearching ? Icons.close_rounded : Icons.search_rounded,
                    color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF1E1B24),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          // Collapsible Search Input
          if (_isSearching) ...[
            const SizedBox(height: 12),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF272233) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF4C1D95) : const Color(0xFFDDD6FE),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar hamburguesas, calzado, spa...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded, color: Color(0xFF7014F2), size: 20),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(
          angle: -0.35,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E05FF), Color(0xFF6200EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x408E05FF),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(bottom: 14, right: 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        // Mini sparkle lines
        Positioned(
          top: -2,
          right: -4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFF8E05FF), shape: BoxShape.circle)),
              const SizedBox(width: 2),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF8E05FF), shape: BoxShape.circle)),
            ],
          ),
        ),
      ],
    );
  }

  void _openFullFilters() {
    OfferFiltersBottomSheet.show(
      context,
      initialOptions: _filterOptions,
      onApply: (newOptions) {
        setState(() {
          _filterOptions = newOptions;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER BAR
  // ---------------------------------------------------------------------------
  Widget _buildFilterBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Filter 1: Filtros (Abre modal general completo)
            _buildMainFilterChip(isDark),
            const SizedBox(width: 8),

            // Vertical divider line |
            Container(
              width: 1,
              height: 22,
              color: isDark ? const Color(0xFF383145) : const Color(0xFFE5E7EB),
            ),
            const SizedBox(width: 8),

            // Pill: Vencimiento
            _buildFilterPill(
              label: 'Vencimiento',
              currentValue: _filterOptions.selectedExpiration,
              isDark: isDark,
              onTap: () {
                OfferFilterDialog.showOptions(
                  context: context,
                  title: 'Filtrar por Tiempo Restante',
                  options: const ['Todos', 'Menos de 6 horas', 'Menos de 24 horas', 'Esta semana'],
                  selectedValue: _filterOptions.selectedExpiration,
                  onSelected: (val) {
                    setState(() {
                      _filterOptions = _filterOptions.copyWith(selectedExpiration: val);
                    });
                  },
                );
              },
            ),
            const SizedBox(width: 8),

            // Pill: Descuento
            _buildFilterPill(
              label: 'Descuento',
              currentValue: _filterOptions.selectedDiscount,
              isDark: isDark,
              onTap: () {
                OfferFilterDialog.showOptions(
                  context: context,
                  title: 'Filtrar por Porcentaje de Descuento',
                  options: const ['Todos', '15% o más', '20% o más', '25% o más', '30% o más', '40% o más'],
                  selectedValue: _filterOptions.selectedDiscount,
                  onSelected: (val) {
                    setState(() {
                      _filterOptions = _filterOptions.copyWith(selectedDiscount: val);
                    });
                  },
                );
              },
            ),
            const SizedBox(width: 8),

            // Pill: Negocios
            _buildFilterPill(
              label: 'Negocios',
              currentValue: _filterOptions.selectedBusinessCategory,
              isDark: isDark,
              onTap: () {
                OfferFilterDialog.showOptions(
                  context: context,
                  title: 'Filtrar por Negocios',
                  options: const ['Todos', 'De los que sigues'],
                  selectedValue: _filterOptions.selectedBusinessCategory,
                  onSelected: (val) {
                    setState(() {
                      _filterOptions = _filterOptions.copyWith(selectedBusinessCategory: val);
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFilterChip(bool isDark) {
    final hasActive = _filterOptions.hasActiveFilters;
    final count = _filterOptions.activeCount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _openFullFilters,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
          decoration: BoxDecoration(
            color: hasActive
                ? (isDark ? const Color(0xFF4C1D95) : AppColors.primaryFixed)
                : (isDark ? const Color(0xFF1E1B24) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasActive
                  ? (isDark ? const Color(0xFFC084FC) : AppColors.primary)
                  : (isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB)),
              width: hasActive ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x22000000) : const Color(0x06000000),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: hasActive
                    ? (isDark ? const Color(0xFFE9D5FF) : AppColors.primary)
                    : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
              ),
              const SizedBox(width: 6),
              Text(
                hasActive ? 'Filtros ($count)' : 'Filtros',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: hasActive ? FontWeight.w700 : FontWeight.w600,
                  color: hasActive
                      ? (isDark ? const Color(0xFFE9D5FF) : AppColors.primary)
                      : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required String currentValue,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = currentValue != 'Todos';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF3B1E63) : const Color(0xFFF3E8FF))
              : (isDark ? const Color(0xFF1E1B24) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7014F2)
                : (isDark ? const Color(0xFF2C2836) : const Color(0xFFE5E7EB)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSelected ? '$label: $currentValue' : label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? const Color(0xFFE9D5FF) : const Color(0xFF7014F2))
                    : (isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151)),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isSelected
                  ? const Color(0xFF7014F2)
                  : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN SECTIONS SCROLL VIEW (Matches exact 3 sections from image)
  // ---------------------------------------------------------------------------
  Widget _buildMainOffersContent(bool isDark) {
    final expiringOffers = _offers
        .where((o) => o.sectionType == OfferSectionType.expiringSoon)
        .toList();
    final followingOffers = _offers
        .where((o) => o.sectionType == OfferSectionType.followingBusinesses)
        .toList();
    final allOffers = _offers
        .where((o) => o.sectionType == OfferSectionType.allOffers)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------
          // SECCIÓN 1: Terminan pronto (🔥)
          // -------------------------------------------------------------
          _buildSectionHeader(
            icon: const Text(
              '🔥',
              style: TextStyle(fontSize: 22),
            ),
            title: 'Terminan pronto',
            subtitle: 'No dejes pasar estas ofertas, se acaban pronto.',
            isDark: isDark,
            onSeeAll: () {
              setState(() {
                _activeSectionFilter = OfferSectionType.expiringSoon;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildHorizontalCardList(expiringOffers),
          const SizedBox(height: 24),

          // -------------------------------------------------------------
          // SECCIÓN 2: De los negocios que sigues (💜)
          // -------------------------------------------------------------
          _buildSectionHeader(
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: Color(0xFF7014F2),
              size: 24,
            ),
            title: 'De los negocios que sigues',
            subtitle: 'Tus negocios favoritos también tienen ofertas.',
            isDark: isDark,
            onSeeAll: () {
              setState(() {
                _activeSectionFilter = OfferSectionType.followingBusinesses;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildHorizontalCardList(followingOffers),
          const SizedBox(height: 24),

          // -------------------------------------------------------------
          // SECCIÓN 3: Todas las ofertas (⭐)
          // -------------------------------------------------------------
          _buildSectionHeader(
            icon: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7014F2), width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.star_rounded,
                  color: Color(0xFF7014F2),
                  size: 18,
                ),
              ),
            ),
            title: 'Todas las ofertas',
            subtitle: 'Explora todas las promociones disponibles.',
            isDark: isDark,
            onSeeAll: () {
              setState(() {
                _activeSectionFilter = OfferSectionType.allOffers;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildHorizontalCardList(allOffers),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required Widget icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onSeeAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: [
                  Text(
                    'Ver todas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7014F2),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF7014F2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCardList(List<OfferModel> offers) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: offers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final offer = offers[index];
          return OfferCard(
            offer: offer,
            onFavoriteToggle: (isFav) => _toggleFavorite(offer.id, isFav),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTERED RESULTS VIEW (When search or filter or "Ver todas" is active)
  // ---------------------------------------------------------------------------
  Widget _buildFilteredResultsView(List<OfferModel> offers, bool isDark) {
    return Column(
      children: [
        // Active Filter Clear Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${offers.length} ${offers.length == 1 ? "oferta encontrada" : "ofertas encontradas"}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _filterOptions = const OfferFilterOptions();
                    _activeSectionFilter = null;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                icon: const Icon(Icons.clear_all_rounded, size: 16, color: Color(0xFF7014F2)),
                label: Text(
                  'Ver todo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7014F2),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Results Grid
        Expanded(
          child: offers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No encontramos ofertas para tu búsqueda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Prueba ajustando los filtros seleccionados',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.64,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return OfferCard(
                      offer: offer,
                      onFavoriteToggle: (isFav) => _toggleFavorite(offer.id, isFav),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
