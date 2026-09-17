import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class WhatsAppStep extends StatelessWidget {
  const WhatsAppStep({super.key});

  static const String illustrationUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCO7pktehyJXGB7_KhcY4pBHg0672pVEXvPcWA4Fz8TuRMXaweeaU3yMKIvKYECCZRFLi0x7JXFSh6Cj3hNgB-0E7snuD1OzHnRY10MAJoWQkocD9iNvEbJ39l093tl0RfIJ15fghnVcPlSyxqyZUtLX898OXyjkrjz0kPa0Jc_IpG4PpnSLac1DcimBpkYvP2AN5wnKDv3ogONKc7EUbZmCQ_11NZ5Uxpq7cMLEeTKb3lu5sSwhzKoWDuHpgiR46Ol3Ig';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top 3D WhatsApp Illustration Container
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                illustrationUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.chat_bubble_rounded,
                          size: 70,
                          color: Color(0xFF25D366),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'WhatsApp Directo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Text Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Conecta al instante\npor WhatsApp',
                textAlign: TextAlign.center,
                style: AppTypography.headlineXL,
              ),
              const SizedBox(height: 12),
              Text(
                'Habla directamente con los negocios\nde forma rápida y fácil.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMD,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
