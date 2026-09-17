import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ProBusinessModel {
  final String id;
  final String name;
  final String distance;
  final bool isOpen;
  final String imageUrl;

  const ProBusinessModel({
    required this.id,
    required this.name,
    required this.distance,
    this.isOpen = true,
    required this.imageUrl,
  });
}

class ProFeaturedSection extends StatelessWidget {
  final List<ProBusinessModel>? businesses;
  final ValueChanged<ProBusinessModel>? onBusinessTap;

  const ProFeaturedSection({
    super.key,
    this.businesses,
    this.onBusinessTap,
  });

  static const List<ProBusinessModel> defaultFeatured = [
    ProBusinessModel(
      id: 'pro_1',
      name: 'BODY XTREME',
      distance: 'A 300 m de ti',
      isOpen: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDju68yaBsmsQqkD1WWoIj0yaCNUb_04oEgnJ5FgykjrtGLzYYsy3YaDVW6ZOxRDE7lO-hnVSd6pWTFGuxdQ6t3FCzLfQn0mqNgTE8uqtp_wwT8W8_PbzhUwdWqBdNiR4ZOQp6C9oDEJ5-3NDAgkXS9jjxKVti31pKfsj2HiBu-Wzz_fhQagoKOuK5ochVXlq0zJUI1DZPaAeAmmMXnNBhN8WknLuh8tjd0dXZkPlerd0f_Z4O49xQuUQ',
    ),
    ProBusinessModel(
      id: 'pro_2',
      name: 'PIZZA CENTER PRO',
      distance: 'A 250 m de ti',
      isOpen: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuButZJlynU3jOVwe5FMbI1e5mfUjxN63Q2SezRjtRjDI2NQRM93Tjt8EoKeXiAen8VizI_UZSSOdy-MIzUbC8A2M-vkC-34AyGlyxhd8MYExpTbpzOpJ4rORbLXjNUsfPtPCwaH_4r5QomQvbiOCu5IlAWfjCniktzM7_QUpgFiOKrD3TYSPKaJsEXksrZiFs3KpJk2E38gYfP9Aw4E1PATeOhR3bIuazDTYJSNcs9jH1PIvhsBwKTY_Q',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = businesses ?? defaultFeatured;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with PRO Badge
          Row(
            children: [
              Text(
                'Negocios destacados',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textMain,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.proOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PRO',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2-Column Grid
          Row(
            children: list.map((item) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: list.indexOf(item) == 0 ? 6 : 0,
                    left: list.indexOf(item) == 1 ? 6 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onBusinessTap?.call(item),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container with Lightning Badge
                        Stack(
                          children: [
                            Container(
                              height: 125,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(
                                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.storefront, size: 36, color: Color(0xFF9CA3AF)),
                                ),
                              ),
                            ),

                            // PRO Lightning Ribbon Badge on top left
                            Positioned(
                              top: 0,
                              left: 10,
                              child: Container(
                                width: 26,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.proOrange,
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x33000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFFFEF08A),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          item.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),

                        // Footer Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 11,
                                  color: Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  item.distance,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: AppColors.statusOpen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Abierto',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.statusOpen,
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
