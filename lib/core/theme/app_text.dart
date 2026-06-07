import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Brend tipografiyasi:
///  • Sarlavha (serif, kursiv aksent uchun): Instrument Serif
///  • Asosiy (sans): Manrope (400/500/600/700)
class AppText {
  AppText._();

  /// Instrument Serif — katta serif sarlavhalar uchun.
  static TextStyle serif({
    double fontSize = 28,
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.instrumentSerif(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Manrope — asosiy matn/tugma/yorliqlar uchun.
  static TextStyle sans({
    double fontSize = 14,
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w500,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Kichik bo'sh-harfli bo'lim yorliqlari (FEATURED, EXPLORE ...).
  static TextStyle overline({
    Color color = AppColors.textSecondary,
    double fontSize = 11,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    );
  }
}
