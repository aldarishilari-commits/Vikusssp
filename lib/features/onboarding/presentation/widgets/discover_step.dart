import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class DiscoverStep extends StatelessWidget {
  const DiscoverStep({super.key});

  static const String heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAvGbMWGhFN0UDWHaaarJXKpCCVK5m59kvSv7DiMI1DhankOTEGItAp55Roosb8H3QMzb7oRxHPNOS112MIRVo6nkifT-bHY_sRsfSOzqn6fl4py9Ys_fWuViXPDrxMTR1a-080ZZL7Ye5PD5OGR_V_iaDtC1EdNteKKgLd5cuNaAuRDUZ6N5Opa-lu_-_W98H5NxO5QkdcbU3ZLB-yHt4IA-ZVrz5RDz884G8ORRvcRcOGVgaaaYPp0i1_n_1zV6t2CMo';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Hero image with soft fade gradient into white card
        Expanded(
          flex: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                heroImageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFFF6F4F9),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF6F4F9),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded, size: 80, color: Color(0xFF8E05FF)),
                    ),
                  );
                },
              ),
              // Fade mask gradient at the bottom of the photo
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 120,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCCFFFFFF),
                        Colors.white,
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Text Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Descubre negocios\ncerca de ti',
                textAlign: TextAlign.center,
                style: AppTypography.headlineXL,
              ),
              const SizedBox(height: 12),
              Text(
                'Explora tiendas, restaurantes,\nservicios y más en tu zona.',
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
