import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../business/presentation/screens/business_profile_screen.dart';
import '../../../home/presentation/widgets/business_card_item.dart';
import '../../../offers/presentation/widgets/offer_card.dart';
import '../../../offers/presentation/widgets/offer_detail_bottom_sheet.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;

  const FavoritesScreen({
    super.key,
    this.onExploreTap,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // null means showing the 2x2 Category Overview Grid (from Stitch "Favoritos - Vikus")
  // 0: Negocios, 1: Servicios, 2: Productos, 3: Ofertas
  int? _selectedCategoryIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context, _) {
        if (_selectedCategoryIndex != null) {
          return _buildCategoryDetailView(_selectedCategoryIndex!, isDark);
        }

        final favService = FavoritesService.instance;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: "Favoritos 💜" matching Favoritos - Vikus
              _buildMainHeader(isDark),
              const SizedBox(height: 18),

              // 2x2 Category Grid matching Stitch "Favoritos (1).jpg"
              _buildCategoriesGrid(isDark, favService),
              const SizedBox(height: 20),

              // Bottom Callout Banner matching Stitch "Favoritos - Vikus"
              _buildBookmarkCalloutBanner(isDark),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainHeader(bool isDark) {
    return Row(
      children: [
        Text(
          'Favoritos',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.favorite_rounded,
          color: Color(0xFF8B1FF5),
          size: 26,
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(bool isDark, FavoritesService favService) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                index: 0,
                title: 'Negocios favoritos',
                count: '${favService.favoriteBusinesses.length} guardados',
                illustration: const _StorefrontIllustration(),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildCategoryCard(
                index: 1,
                title: 'Servicios favoritos',
                count: '${favService.favoriteServices.length} guardados',
                illustration: const _ServicesIllustration(),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                index: 2,
                title: 'Productos favoritos',
                count: '${favService.favoriteProducts.length} guardados',
                illustration: const _ProductsIllustration(),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildCategoryCard(
                index: 3,
                title: 'Ofertas favoritas',
                count: '${favService.favoriteOffers.length} guardados',
                illustration: const _OffersIllustration(),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required int index,
    required String title,
    required String count,
    required Widget illustration,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Container with 28px corners
          Container(
            height: 146,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1B24) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(28),
              border: isDark ? Border.all(color: AppColors.darkBorder) : null,
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x33000000) : const Color(0x08000000),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: illustration,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Label
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111827),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),

          // Count
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCalloutBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF272330) : const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFD8B4FE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x06000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Purple heart badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3B1D66) : const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFF7C3AED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aún no tienes favoritos',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Empieza guardando lo que más te gusta y aparecerá aquí.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Decorative 3D Bookmark Ribbon & Sparkles
          SizedBox(
            width: 46,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gold Sparkle Top Left
                Positioned(
                  top: 2,
                  left: 2,
                  child: Text(
                    '✦',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                // Lilac Sparkle Bottom
                Positioned(
                  bottom: 0,
                  right: 2,
                  child: Text(
                    '✦',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: const Color(0xFFC084FC),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                // Ribbon
                Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    width: 24,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFA855F7),
                          Color(0xFF7E22CE),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7E22CE).withValues(alpha: 0.35),
                          blurRadius: 5,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Drill-down View for inspecting individual category items
  Widget _buildCategoryDetailView(int index, bool isDark) {
    final titles = [
      'Negocios favoritos',
      'Servicios favoritos',
      'Productos favoritos',
      'Ofertas favoritas',
    ];
    final categoryName = titles[index];
    final favService = FavoritesService.instance;

    int count = 0;
    if (index == 0) count = favService.favoriteBusinesses.length;
    if (index == 1) count = favService.favoriteServices.length;
    if (index == 2) count = favService.favoriteProducts.length;
    if (index == 3) count = favService.favoriteOffers.length;

    return Column(
      children: [
        // Detail Header with Back Button
        Container(
          color: isDark ? AppColors.darkCard : Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 10, 20, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedCategoryIndex = null),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  categoryName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3B1D66)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count guardados',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6)),

        // Content
        Expanded(
          child: _buildDetailContent(index, categoryName, isDark, favService),
        ),
      ],
    );
  }

  Widget _buildDetailContent(
    int index,
    String categoryName,
    bool isDark,
    FavoritesService favService,
  ) {
    switch (index) {
      case 0:
        // Negocios
        final businesses = favService.favoriteBusinesses;
        if (businesses.isEmpty) return _buildEmptyCategoryState(categoryName, isDark);
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: businesses.length,
          itemBuilder: (context, i) {
            final b = businesses[i];
            return BusinessCardItem(
              business: b,
              showDivider: i < businesses.length - 1,
              onFavoriteToggle: (isFav) {
                favService.toggleBusinessFavorite(b, context);
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BusinessProfileScreen(
                      business: b,
                      onFavoriteToggle: (isFav) {
                        favService.toggleBusinessFavorite(b, context);
                      },
                    ),
                  ),
                );
              },
            );
          },
        );

      case 1:
        // Servicios
        final services = favService.favoriteServices;
        if (services.isEmpty) return _buildEmptyCategoryState(categoryName, isDark);
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: services.length,
          itemBuilder: (context, i) {
            final s = services[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x22000000) : const Color(0x06000000),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: Image.network(
                        s.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? AppColors.darkCardAlt : const Color(0xFFF3F4F6),
                          child: const Icon(Icons.medical_services_rounded, color: Color(0xFF9CA3AF), size: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (s.businessName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            s.businessName,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 3),
                        Text(
                          s.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        s.price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFFC084FC) : const Color(0xFF1B1C1C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          favService.toggleServiceFavorite(s, context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF233C).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 18,
                            color: Color(0xFFEF233C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

      case 2:
        // Productos
        final products = favService.favoriteProducts;
        if (products.isEmpty) return _buildEmptyCategoryState(categoryName, isDark);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 16,
              childAspectRatio: 0.74,
            ),
            itemBuilder: (context, i) {
              final prod = products[i];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color(0x22000000) : const Color(0x06000000),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image & Badges
                      AspectRatio(
                        aspectRatio: 1.2,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              prod.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: isDark ? AppColors.darkCardAlt : const Color(0xFFF3F4F6),
                                child: const Icon(Icons.shopping_bag_outlined, size: 30, color: Color(0xFF9CA3AF)),
                              ),
                            ),
                            if (prod.discount.isNotEmpty)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF331F),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    prod.discount,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => favService.toggleProductFavorite(prod, context),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    size: 16,
                                    color: Color(0xFFEF233C),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Details
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (prod.businessName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                prod.businessName,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              prod.price,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFFC084FC) : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

      case 3:
        // Ofertas
        final offers = favService.favoriteOffers;
        if (offers.isEmpty) return _buildEmptyCategoryState(categoryName, isDark);
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: offers.length,
          itemBuilder: (context, i) {
            final offer = offers[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: OfferCard(
                offer: offer,
                onFavoriteToggle: (isFav) {
                  favService.toggleOfferFavorite(offer, context);
                },
                onTap: () {
                  OfferDetailBottomSheet.show(
                    context,
                    title: offer.title,
                    subtitle: offer.businessCategory,
                    businessName: offer.businessName,
                    businessCategory: offer.businessCategory,
                    price: 'Bs ${offer.discountedPrice.toInt()}',
                    originalPrice: 'Bs ${offer.originalPrice.toInt()}',
                    discountBadge: offer.discountBadge,
                    timerRemaining: offer.timeRemaining,
                    stockRemaining: offer.stockRemaining,
                    validUntil: offer.validUntil,
                    imageUrl: offer.imageUrl,
                    isFavorite: favService.isOfferFavorite(offer.id),
                    onFavoriteToggle: (isFav) {
                      favService.toggleOfferFavorite(offer, context);
                    },
                  );
                },
              ),
            );
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyCategoryState(String categoryTitle, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3B1D66) : const Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 34,
                color: isDark ? const Color(0xFFC084FC) : const Color(0xFF8B1FF5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin $categoryTitle',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1B1C1C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Guarda tus $categoryTitle tocando el corazón en las fichas para verlos aquí.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onExploreTap,
              icon: const Icon(Icons.explore_rounded, size: 16, color: Colors.white),
              label: Text(
                'Explorar',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Visual Category Illustrations (matching Stitch "Favoritos (1).jpg")
// ---------------------------------------------------------------------------

/// 1. Negocios favoritos illustration (Storefront with purple striped awning, window & door)
class _StorefrontIllustration extends StatelessWidget {
  const _StorefrontIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base Ground platform
          Positioned(
            bottom: 4,
            child: Container(
              width: 90,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Main Building Wall
          Positioned(
            bottom: 10,
            child: Container(
              width: 78,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Window with glossy cyan reflection
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 6, 4, 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF93C5FD),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF334155), width: 1.5),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(2)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Door with silver knob
                  Container(
                    width: 22,
                    margin: const EdgeInsets.only(right: 6, top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF475569),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                    child: Align(
                      alignment: const Alignment(-0.4, 0.1),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Striped Purple/White Awning
          Positioned(
            top: 14,
            child: Container(
              width: 88,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D28D9).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(5, (i) {
                  final isPurple = i % 2 == 0;
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPurple ? const Color(0xFF7C3AED) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(3),
                          bottom: Radius.circular(i == 0 || i == 4 ? 6 : 4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Little Green Bush on the right corner
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F16A34A),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Servicios favoritos illustration (Dumbbell, Stethoscope, Briefcase, Stack of Books)
class _ServicesIllustration extends StatelessWidget {
  const _ServicesIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Purple Dumbbell (top left)
          Positioned(
            top: 12,
            left: 8,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 18, decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(2))),
                    Container(width: 16, height: 5, color: const Color(0xFF6D28D9)),
                    Container(width: 6, height: 18, decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ),
            ),
          ),
          // Stethoscope / Health Icon (top right)
          Positioned(
            top: 10,
            right: 12,
            child: const Icon(
              Icons.medical_services_rounded,
              size: 26,
              color: Color(0xFF334155),
            ),
          ),
          // Stack of colorful Books (bottom right)
          Positioned(
            bottom: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(width: 24, height: 5, decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(1.5))),
                const SizedBox(height: 2),
                Container(width: 28, height: 6, decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(1.5))),
              ],
            ),
          ),
          // Professional Briefcase (center)
          Positioned(
            bottom: 12,
            child: Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tooth shape (bottom left)
          Positioned(
            bottom: 14,
            left: 10,
            child: Container(
              width: 18,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.clean_hands_rounded, size: 10, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Productos favoritos illustration (Purple shopping bag with handle & cardboard delivery box)
class _ProductsIllustration extends StatelessWidget {
  const _ProductsIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Purple Shopping Bag (left)
          Positioned(
            left: 14,
            bottom: 12,
            child: Column(
              children: [
                // Bag Handle
                Container(
                  width: 22,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    border: Border.all(color: const Color(0xFF5B21B6), width: 3),
                  ),
                ),
                // Bag Body
                Container(
                  width: 44,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF6D28D9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6D28D9).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Amber/Brown Delivery Parcel Box (front right)
          Positioned(
            right: 14,
            bottom: 8,
            child: Container(
              width: 38,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEAB308),
                    Color(0xFFD97706),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 4,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Tape strip
                  Center(
                    child: Container(
                      width: 8,
                      height: double.infinity,
                      color: const Color(0xFF92400E).withValues(alpha: 0.6),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB45309).withValues(alpha: 0.7),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. Ofertas favoritas illustration (Fire flame with % discount badge)
class _OffersIllustration extends StatelessWidget {
  const _OffersIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Fire Flame
          Container(
            width: 58,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFFFF5722),
                  Color(0xFFFF9800),
                  Color(0xFFFFC107),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5722).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              // Inner hot flame
              child: Container(
                width: 28,
                height: 38,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFFFFEB3B),
                      Color(0xFFFFF59D),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          // Purple % Discount Tag on right
          Positioned(
            right: 14,
            bottom: 12,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E000000),
                      blurRadius: 4,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sparkle accents
          Positioned(
            top: 14,
            left: 18,
            child: Text(
              '✦',
              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFFF9800), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
