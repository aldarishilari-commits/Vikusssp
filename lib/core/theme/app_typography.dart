import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography definitions matching the Stitch Design System
class AppTypography {
  AppTypography._();

  // Headlines (Plus Jakarta Sans)
  static TextStyle get headlineXL => GoogleFonts.plusJakartaSans(
        fontSize: 31,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.5,
        height: 1.18,
      );

  static TextStyle get headlineLG => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.3,
        height: 1.22,
      );

  static TextStyle get headlineMD => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.25,
      );

  // Body text (Plus Jakarta Sans / Inter)
  static TextStyle get bodyLG => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 1.5,
      );

  static TextStyle get bodyMD => GoogleFonts.plusJakartaSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textGrey,
        height: 1.45,
      );

  static TextStyle get bodySM => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
        height: 1.4,
      );

  // Button text
  static TextStyle get buttonPrimary => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonSecondary => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
        letterSpacing: 0.1,
      );

  // Input & Labels
  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textMain,
      );

  static TextStyle get inputPlaceholder => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPlaceholder,
      );

  static TextStyle get link => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );
}
