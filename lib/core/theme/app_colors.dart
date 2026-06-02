import 'package:flutter/material.dart';

/// Gastronomy brand palette — Olive system.
/// Asosiy: zaytun #46603D, chuqur #2F4429, siyoh #1F2C1B,
/// krem #F6F1E4, oq #FFFFFF, oltin aksent #E8D27A, yulduz #C98A3A.
class AppColors {
  AppColors._();

  // ── Brand (Olive) ──────────────────────────────────────────────
  static const Color primary = Color(0xFF46603D); // zaytun
  static const Color primaryDark = Color(0xFF2F4429); // chuqur
  static const Color ink = Color(0xFF1F2C1B); // siyoh
  static const Color primaryLight = Color(0xFFD7DECB); // ochiq zaytun fon

  // ── Surfaces ───────────────────────────────────────────────────
  static const Color cream = Color(0xFFF6F1E4); // krem fon
  static const Color background = cream;
  static const Color backgroundLight = cream;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // ── Accent ─────────────────────────────────────────────────────
  static const Color accent = Color(0xFFE8D27A); // oltin (kursiv sarlavhalar)
  static const Color gold = accent;
  static const Color orange = Color(0xFFC98A3A); // iliq aksent (remap)
  static const Color orangeLight = Color(0xFFF0E7CC);

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF6B7264);
  static const Color textHint = Color(0xFF9AA08F);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Status ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF3F8F4F);
  static const Color successLight = Color(0xFFCDE6CF);
  static const Color error = Color(0xFFC0492F);
  static const Color warning = Color(0xFFC98A3A);
  static const Color warningLight = Color(0xFFF0E7CC);

  // ── Icons ──────────────────────────────────────────────────────
  static const Color iconPrimary = primary;
  static const Color iconSecondary = Color(0xFF6B7264);
  static const Color iconSuccess = success;
  static const Color iconInactive = Color(0xFF9AA08F);

  // ── Lines & misc ───────────────────────────────────────────────
  static const Color border = Color(0xFFE7E0CF);
  static const Color shadow = Color(0x14000000);
  static const Color starRating = Color(0xFFC98A3A); // oltin yulduz
  static const Color divider = Color(0xFFECE6D6);

  // ── App Bar gradient overlay (rasm ustidan) ────────────────────
  static const List<Color> appBarOverlay = [
    Color(0x8C1F2C1B), // rgba(31,44,27,0.55)
    Color(0x9E46603D), // rgba(70,96,61,0.62)
    Color(0xC71F2C1B), // rgba(31,44,27,0.78)
  ];
  static const List<double> appBarOverlayStops = [0.0, 0.55, 1.0];

  // ── Brand chip gradient (135deg olive→deep) ────────────────────
  static const List<Color> brandGradient = [primary, primaryDark];
}
