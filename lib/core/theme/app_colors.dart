import 'package:flutter/material.dart';

/// Design tokens extracted directly from Stitch MCP Design System (Vibrant Marketplace)
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF8E05FF);
  static const Color primaryAlt = Color(0xFF9D00FF);
  static const Color primaryDark = Color(0xFF7B00E3);
  static const Color primaryDarker = Color(0xFF6812C7);
  static const Color primaryLight = Color(0xFFA832FF);
  static const Color primaryFixed = Color(0xFFF1DAFF);

  // Accent & Gold (Guest button border & highlights)
  static const Color goldBorder = Color(0xFFD2A249);
  static const Color goldBorderLight = Color(0xFFD9A74A);
  static const Color amberAccent = Color(0xFFFEB700);
  static const Color orangeAccent = Color(0xFFFF7A2F);

  // Surface & Canvas
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceOffWhite = Color(0xFFFBF9F8);
  static const Color surfaceContainer = Color(0xFFF6F4F9);
  static const Color surfaceAlt = Color(0xFFF5F3F3);
  static const Color backgroundGrey = Color(0xFFF3F4F6);

  // Typography & Text
  static const Color textMain = Color(0xFF1B1C1C);
  static const Color textMuted = Color(0xFF4E4356);
  static const Color textGrey = Color(0xFF666666);
  static const Color textPlaceholder = Color(0xFFA09FA1);

  // Outlines & Borders
  static const Color outline = Color(0xFF787679);
  static const Color outlineLight = Color(0xFFE5E0EA);
  static const Color outlineVariant = Color(0xFFD1C1D9);
  static const Color dotInactive = Color(0xFFE2E2E2);
  static const Color dotActive = Color(0xFF9D00FF);

  // Shadows
  static const Color shadowPurple = Color(0x478E05FF); // rgba(142, 5, 255, 0.28)
  static const Color shadowCard = Color(0x1F000000);

  // Flash Offers & Badges
  static const Color flashRedDark = Color(0xFFB91C1C);
  static const Color flashRed = Color(0xFFDC2626);
  static const Color flashRedLight = Color(0xFFEF4444);
  static const Color flashYellow = Color(0xFFFBBF24);
  static const Color flashYellowText = Color(0xFF450A0A);
  static const Color proOrange = Color(0xFFFF5500);
  static const Color proOrangeLight = Color(0xFFFF7A2F);
  static const Color statusOpen = Color(0xFF22C55E);
  static const Color searchFieldBg = Color(0xFFF4F6F8);

  // Dark Mode Semantic Tokens
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1B24);
  static const Color darkCardAlt = Color(0xFF272330);
  static const Color darkBorder = Color(0xFF2E2B36);
  static const Color darkBorderLight = Color(0xFF3F3B48);
  static const Color darkTextMain = Color(0xFFF3F4F6);
  static const Color darkTextMuted = Color(0xFF9CA3AF);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkSearchField = Color(0xFF272430);
}
