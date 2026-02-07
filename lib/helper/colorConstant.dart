import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorConstant {
  // Brand Colors
  static const Color cyanAccent = Color(0xFF09FACA);
  static const Color darkTeal = Color(0xFF0D7C7C);
  static const Color blueAction = Color(0xFF007AFF);
  
  // Neutral / Background Colors
  static const Color themeBg = Color(0xFF0F1114);
  static const Color scaffoldBg = Color(0xFF13151E);
  static const Color appBarBg = Color(0xFF1A1D29);
  static const Color cardBg = Color(0xFF252836);
  
  // Status Colors
  static const Color error = Colors.red;
  static const Color textMain = Colors.white;
  static const Color textMuted = Colors.white54;
}

class AppStyles {
  // Text Styles
  static TextStyle navTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorConstant.textMain,
  );

  static TextStyle bodyText = GoogleFonts.roboto(
    fontSize: 14,
    color: ColorConstant.textMain,
    height: 1.5,
  );

  static TextStyle hintText = GoogleFonts.roboto(
    color: ColorConstant.textMuted,
    fontSize: 14,
  );

  // Reusable Decorations
  static BoxDecoration searchBarDeco = BoxDecoration(
    color: ColorConstant.cardBg,
    borderRadius: BorderRadius.circular(25),
    border: Border.all(
      color: ColorConstant.cyanAccent.withOpacity(0.3),
      width: 1,
    ),
  );

  static BoxDecoration postCardDeco(bool isPinned) => BoxDecoration(
    color: ColorConstant.cardBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isPinned 
          ? ColorConstant.cyanAccent.withOpacity(0.6) 
          : ColorConstant.cyanAccent.withOpacity(0.2),
      width: isPinned ? 1.5 : 1,
    ),
  );

  static BoxDecoration gradientButtonDeco = BoxDecoration(
    gradient: const LinearGradient(
      colors: [ColorConstant.cyanAccent, ColorConstant.darkTeal],
    ),
    borderRadius: BorderRadius.circular(12),
  );
}