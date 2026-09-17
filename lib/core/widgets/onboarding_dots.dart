import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OnboardingDots extends StatelessWidget {
  final int totalDots;
  final int currentIndex;
  final ValueChanged<int>? onDotTap;

  const OnboardingDots({
    super.key,
    this.totalDots = 3,
    required this.currentIndex,
    this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        final bool isActive = index == currentIndex;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onDotTap?.call(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isActive ? 28 : 20,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.dotActive : AppColors.dotInactive,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      }),
    );
  }
}
