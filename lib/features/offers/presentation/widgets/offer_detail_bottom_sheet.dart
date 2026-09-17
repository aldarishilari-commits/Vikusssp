import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/widgets/whatsapp_button.dart';
import '../../data/models/offer_model.dart';

class OfferDetailBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String businessName;
  final String businessCategory;
  final String price;
  final String originalPrice;
  final String? discountBadge;
  final String? timerRemaining;
  final String stockRemaining;
  final String validUntil;
  final String imageUrl;
  final bool initialIsFavorite;
  final ValueChanged<bool>? onFavoriteToggle;
  final String phoneNumber;

  const OfferDetailBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    this.businessName = 'Panadería & Cafetería Central',
    required this.businessCategory,
    required this.price,
    required this.originalPrice,
    this.discountBadge,
    this.timerRemaining,
    this.stockRemaining = '8 disponibles',
    this.validUntil = 'Válido hoy\nhasta 22:00',
    required this.imageUrl,
    this.initialIsFavorite = false,
    this.onFavoriteToggle,
    this.phoneNumber = '70123456',
  });

  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    String businessName = 'Panadería & Cafetería Central',
    required String businessCategory,
    required String price,
    required String originalPrice,
    String? discountBadge,
    String? timerRemaining,
    required String stockRemaining,
    required String validUntil,
    required String imageUrl,
    bool isFavorite = false,
    ValueChanged<bool>? onFavoriteToggle,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OfferDetailBottomSheet(
        title: title,
        subtitle: subtitle,
        businessName: businessName,
        businessCategory: businessCategory,
        price: price,
        originalPrice: originalPrice,
        discountBadge: discountBadge,
        timerRemaining: timerRemaining,
        stockRemaining: stockRemaining,
        validUntil: validUntil,
        imageUrl: imageUrl,
        initialIsFavorite: isFavorite,
        onFavoriteToggle: onFavoriteToggle,
      ),
    );
  }

  @override
  State<OfferDetailBottomSheet> createState() => _OfferDetailBottomSheetState();
}

class _OfferDetailBottomSheetState extends State<OfferDetailBottomSheet> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Header Image with Badges & Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFFEF3C7),
                        child: const Icon(Icons.storefront_rounded, size: 48, color: Color(0xFFD97706)),
                      ),
                    ),
                  ),
                ),

                // Close Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                ),

                // Discount Badge (if any)
                if (widget.discountBadge != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.discountBadge!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Countdown Timer Pill (if flash offer)
                if (widget.timerRemaining != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            widget.timerRemaining!,
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
              ],
            ),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Category & Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF4C1D95) : const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.businessCategory,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF7014F2),
                        ),
                      ),
                    ),
                    Text(
                      widget.stockRemaining,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFC084FC) : const Color(0xFF8C4FF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Offer Title
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 4),

                // Offer Terms / Subtitle
                Text(
                  widget.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 12),

                // Pricing Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7014F2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.originalPrice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 14, color: Color(0xFFEF233C)),
                          const SizedBox(width: 4),
                          Text(
                            widget.validUntil.replaceAll('\n', ' '),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEF233C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // CTAs: WhatsApp Claim Button & Favorite
                Row(
                  children: [
                    // Favorite Toggle Button
                    GestureDetector(
                      onTap: () {
                        if (widget.onFavoriteToggle != null) {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          widget.onFavoriteToggle!(_isFavorite);
                        } else {
                          final offer = OfferModel(
                            id: 'off_${widget.title.hashCode}',
                            title: widget.title,
                            businessName: widget.businessName,
                            businessCategory: widget.businessCategory,
                            categoryIcon: Icons.local_offer_rounded,
                            originalPrice: double.tryParse(widget.originalPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 100.0,
                            discountedPrice: double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 70.0,
                            discountBadge: widget.discountBadge ?? '',
                            timeRemaining: widget.timerRemaining ?? 'Disponible',
                            distance: 'Cerca de ti',
                            imageUrl: widget.imageUrl,
                            sectionType: OfferSectionType.allOffers,
                            phoneNumber: widget.phoneNumber,
                            stockRemaining: widget.stockRemaining,
                            validUntil: widget.validUntil,
                          );
                          final newFav = FavoritesService.instance.toggleOfferFavorite(offer, context);
                          setState(() {
                            _isFavorite = newFav;
                          });
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isFavorite
                              ? (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFEE2E2))
                              : (isDark ? const Color(0xFF2E2B36) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isFavorite
                                ? const Color(0xFFFCA5A5)
                                : (isDark ? const Color(0xFF3F3B4B) : const Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isFavorite
                              ? const Color(0xFFEF233C)
                              : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Primary Action Button (WhatsApp Claim)
                    Expanded(
                      child: WhatsAppButton(
                        phoneNumber: widget.phoneNumber,
                        businessName: widget.businessName,
                        customMessage: '¡Hola ${widget.businessName}! Quiero canjear la oferta de "${widget.title}" (${widget.price}) que vi en Vikus.',
                        label: 'WhatsApp',
                        height: 50,
                        borderRadius: 16,
                        onBeforeLaunch: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
