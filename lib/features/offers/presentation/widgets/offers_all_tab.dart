import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/favorites_service.dart';
import '../../data/models/offer_model.dart';
import 'offer_detail_bottom_sheet.dart';

class OffersAllTab extends StatefulWidget {
  const OffersAllTab({super.key});

  @override
  State<OffersAllTab> createState() => _OffersAllTabState();
}

class _OffersAllTabState extends State<OffersAllTab> {
  void _toggleFavorite(
    String id, {
    String title = 'Oferta Especial',
    String businessName = 'Panadería & Pastelería',
    String businessCategory = 'Panadería & Pastelería',
    String price = 'Bs 50',
    String originalPrice = 'Bs 70',
    String? discountBadge,
    String? timerRemaining,
    String imageUrl = '',
  }) {
    final offer = OfferModel(
      id: id,
      title: title,
      businessName: businessName,
      businessCategory: businessCategory,
      categoryIcon: Icons.local_offer_rounded,
      originalPrice: double.tryParse(originalPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 70.0,
      discountedPrice: double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 50.0,
      discountBadge: discountBadge ?? '',
      timeRemaining: timerRemaining ?? 'Disponible',
      distance: 'Cerca de ti',
      imageUrl: imageUrl,
      sectionType: OfferSectionType.allOffers,
    );
    FavoritesService.instance.toggleOfferFavorite(offer, context);
    setState(() {});
  }

  void _openOfferDetail({
    required String title,
    required String subtitle,
    required String businessCategory,
    required String price,
    required String originalPrice,
    String? discountBadge,
    String? timerRemaining,
    required String stockRemaining,
    required String validUntil,
    required String imageUrl,
    required String id,
  }) {
    OfferDetailBottomSheet.show(
      context,
      title: title,
      subtitle: subtitle,
      businessCategory: businessCategory,
      price: price,
      originalPrice: originalPrice,
      discountBadge: discountBadge,
      timerRemaining: timerRemaining,
      stockRemaining: stockRemaining,
      validUntil: validUntil,
      imageUrl: imageUrl,
      isFavorite: FavoritesService.instance.isOfferFavorite(id),
      onFavoriteToggle: (isFav) => _toggleFavorite(
        id,
        title: title,
        businessCategory: businessCategory,
        price: price,
        originalPrice: originalPrice,
        discountBadge: discountBadge,
        timerRemaining: timerRemaining,
        imageUrl: imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Section 1: Ofertas Especiales Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Transform.rotate(
                  angle: 1.57,
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: Color(0xFF8C4FF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ofertas especiales',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Special Offer Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSpecialOfferCard(
              id: 'special_1',
              title: '3x2 en Pasteles',
              subtitle: 'En cualquier pastel de la tienda',
              validUntil: 'Valida hasta el 31\nde agosto',
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBCGojBT1xHpJiKobIOv6CBpCdMstoN25vOP7Jry4Gk-cYbnoQb-pEyla5qj7UE7hOui33kz_5n7JXEC9f5rX8kZrGOZCdzb5WkXf_5VrkaSP4FEljHa1hF8eu_Rm7fTIPu7N9ggLL-X1MtSh1LrhlNZAjRIAgqaUmAiY3kwTOdDrU4ROBTGXZn5zsqI9wlQZL-Byn8DVPdfGzfi0IkE25-KnGde8JG88nSt2fvlegE3-j-S9ncyNhHPA',
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Ofertas Flash Header
          Center(
            child: Text(
              'Ofertas Flash',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: 1.2,
            color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 10),

          // Flash Offers List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildFlashOfferItem(
                  id: 'flash_1',
                  businessCategory: 'Cafetería',
                  title: '3x2 en pasteles',
                  description: 'En cualquier pastel',
                  price: 'Bs. 65',
                  originalPrice: 'Bs. 50',
                  timerRemaining: '1:00',
                  stockRemaining: 'Quedan 2',
                  discountBadge: null,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAhCUKWWasyNuWJxULwBOItGv9uLKNc3P06cAFiITJGiBfIReDz5T6N9xKbjDY_iRt_NkyHe5CQAFUo7zDB59YMuwtl_GfdvuRMzdmVDhiRrL2gb2D9ETLF0CqeTnAz8x2DqDaagbp8ZdbMCFYaEH5dxw2Io4tHW25sCvRcaYRBYkH3zYdWGhN8giVlxX8p3R2a1DqQbk27j4fq0iL83UUTgzRNhy9GbGRCAy0sn8bOl750oebuhNj1ew',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Divider(color: Color(0xFFE5E7EB), height: 1),
                ),
                _buildFlashOfferItem(
                  id: 'flash_2',
                  businessCategory: 'Cafetería',
                  title: '3x2 en pasteles',
                  description: 'En cualquier pastel',
                  price: 'Bs. 65',
                  originalPrice: 'Bs. 50',
                  timerRemaining: '1:00',
                  stockRemaining: 'Quedan 2',
                  discountBadge: '-15%',
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBaDRFv7iZk1GrT3JDH3BekM68QkiQAJgOYAmuprjjwYGEn_ie6uD2_roO5H8MshSsAIuWzY0TEsedrZSXKMYqChRptvq-AzLOLRoO-f8HcAANHn7wHB6h5fVR28c3z1OVS7iqMWb8HrN3I_Dhr9QycWskqHyY_EvHRFtkHsMTkNBek-hs1i9XLs_WvGyVp5CqBx46c2RNoJu11l2xZA5NzpTifcOSP4H2CtRVqIeRXddpENup5TreZFA',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOfferCard({
    required String id,
    required String title,
    required String subtitle,
    required String validUntil,
    required String imageUrl,
  }) {
    final isFav = FavoritesService.instance.isOfferFavorite(id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openOfferDetail(
          id: id,
          title: title,
          subtitle: subtitle,
          businessCategory: 'Pastelería & Café',
          price: '3x2',
          originalPrice: 'Bs. 90',
          stockRemaining: 'Disponible hoy',
          validUntil: validUntil,
          imageUrl: imageUrl,
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B24) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF2E2B36) : const Color(0xFFE5E7EB),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x22000000) : const Color(0x0A000000),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image with Favorite Icon (>= 44x44 tap target)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 130,
                      height: 125,
                      color: const Color(0xFFFEF3C7),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.cake_rounded,
                          size: 50,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(
                        id,
                        title: title,
                        businessName: subtitle,
                        businessCategory: 'Pastelería & Café',
                        price: '3x2',
                        originalPrice: 'Bs. 90',
                        imageUrl: imageUrl,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E2B36) : Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: isFav ? const Color(0xFFEF233C) : (isDark ? Colors.white70 : const Color(0xFF1B1C1C)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8C4FF6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          validUntil,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashOfferItem({
    required String id,
    String businessName = 'Panadería & Pastelería',
    required String businessCategory,
    required String title,
    required String description,
    required String price,
    required String originalPrice,
    required String timerRemaining,
    required String stockRemaining,
    required String? discountBadge,
    required String imageUrl,
  }) {
    final isFav = FavoritesService.instance.isOfferFavorite(id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openOfferDetail(
          id: id,
          title: title,
          subtitle: description,
          businessCategory: businessCategory,
          price: price,
          originalPrice: originalPrice,
          discountBadge: discountBadge,
          timerRemaining: timerRemaining,
          stockRemaining: stockRemaining,
          validUntil: 'Válido hoy',
          imageUrl: imageUrl,
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image with timer and stock badges
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 140,
                      height: 135,
                      color: const Color(0xFFFEF3C7),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.storefront_rounded,
                          size: 45,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),

                  // Top-left Discount Badge (if any) or Coral tab
                  if (discountBadge != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5252),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          discountBadge,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 36,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5252),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),

                  // Heart Favorite (>= 44x44 tap target)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(
                        id,
                        title: title,
                        businessName: businessName,
                        businessCategory: businessCategory,
                        price: price,
                        originalPrice: originalPrice,
                        discountBadge: discountBadge,
                        timerRemaining: timerRemaining,
                        imageUrl: imageUrl,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E2B36) : Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: isFav ? const Color(0xFFEF233C) : (isDark ? Colors.white70 : const Color(0xFF1B1C1C)),
                        ),
                      ),
                    ),
                  ),

                  // Center Countdown Timer Badge
                  Positioned(
                    top: 50,
                    left: 18,
                    right: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time_filled_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timerRemaining,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom-left Stock Badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8C4FF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stockRemaining,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Info details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessCategory,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFFC084FC) : const Color(0xFF1B1C1C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          originalPrice,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
