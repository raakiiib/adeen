import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors definitions ---
  // Emerald Presets
  static const Color emeraldDeep = Color(0xFF0B2A18);
  static const Color emeraldSage = Color(0xFF2C5E43);
  static const Color emeraldBgLight = Color(0xFFF9F6F0);
  static const Color emeraldBgDark = Color(0xFF08140E);
  static const Color emeraldCardDark = Color(0xFF0F241A);

  // Sapphire Presets
  static const Color sapphireDeep = Color(0xFF0A1D37);
  static const Color sapphireRoyal = Color(0xFF1B3B6F);
  static const Color sapphireBgLight = Color(0xFFF4F6F9);
  static const Color sapphireBgDark = Color(0xFF050E1A);
  static const Color sapphireCardDark = Color(0xFF0A1A2E);

  // Ruby Presets
  static const Color rubyDeep = Color(0xFF3A0F0F);
  static const Color rubyAmber = Color(0xFF8C3B3B);
  static const Color rubyBgLight = Color(0xFFFAF5F5);
  static const Color rubyBgDark = Color(0xFF1A0707);
  static const Color rubyCardDark = Color(0xFF2C0F0F);

  // Constants
  static const Color warmGold = Color(0xFFC5A880);
  static const Color premiumGold = Color(0xFFD4AF37);

  static ThemeData getTheme(Brightness brightness, String preset) {
    final bool isDark = brightness == Brightness.dark;
    
    // 1. Choose Colors & Accent (tertiary) based on preset & brightness
    Color primaryColor;
    Color secondaryColor;
    Color backgroundColor;
    Color cardColor;
    Color textPrimary;
    Color textSecondary;
    Color borderCol;
    Color accentColor;

    // 2. Choose Fonts based on preset
    String headerFont;
    String bodyFont;

    if (preset == 'sapphire') {
      primaryColor = isDark ? const Color(0xFF5A9BE6) : sapphireDeep;
      secondaryColor = sapphireRoyal;
      backgroundColor = isDark ? sapphireBgDark : sapphireBgLight;
      cardColor = isDark ? sapphireCardDark : Colors.white;
      textPrimary = isDark ? const Color(0xFFE2E7EB) : const Color(0xFF16222F);
      textSecondary = isDark ? const Color(0xFF909CA6) : const Color(0xFF4C5865);
      borderCol = isDark ? const Color(0xFF172C41) : const Color(0xFFE2E7EB);
      accentColor = const Color(0xFF8DA9C4);

      headerFont = 'Outfit';
      bodyFont = 'Inter';
    } else if (preset == 'ruby') {
      primaryColor = isDark ? premiumGold : rubyDeep;
      secondaryColor = rubyAmber;
      backgroundColor = isDark ? rubyBgDark : rubyBgLight;
      cardColor = isDark ? rubyCardDark : Colors.white;
      textPrimary = isDark ? const Color(0xFFEBE2E2) : const Color(0xFF2F1616);
      textSecondary = isDark ? const Color(0xFFA69090) : const Color(0xFF654C4C);
      borderCol = isDark ? const Color(0xFF411717) : const Color(0xFFEBE2E2);
      accentColor = premiumGold;

      headerFont = 'Lora';
      bodyFont = 'Georgia';
    } else {
      // Default: Emerald
      primaryColor = isDark ? warmGold : emeraldDeep;
      secondaryColor = emeraldSage;
      backgroundColor = isDark ? emeraldBgDark : emeraldBgLight;
      cardColor = isDark ? emeraldCardDark : Colors.white;
      textPrimary = isDark ? const Color(0xFFE2EBE5) : const Color(0xFF1C2D24);
      textSecondary = isDark ? const Color(0xFF90A397) : const Color(0xFF556B5F);
      borderCol = isDark ? const Color(0xFF1E3A2B) : const Color(0xFFE5EDE8);
      accentColor = warmGold;

      headerFont = 'Playfair Display';
      bodyFont = 'Poppins';
    }

    // Dynamic Google Fonts resolver helper
    TextTheme resolveGoogleTextTheme(String fontName, TextTheme baseTheme) {
      switch (fontName) {
        case 'Poppins':
          return GoogleFonts.poppinsTextTheme(baseTheme);
        case 'Inter':
          return GoogleFonts.interTextTheme(baseTheme);
        case 'Outfit':
          return GoogleFonts.outfitTextTheme(baseTheme);
        case 'Playfair Display':
          return GoogleFonts.playfairDisplayTextTheme(baseTheme);
        case 'Lora':
          return GoogleFonts.loraTextTheme(baseTheme);
        default:
          // For system default serif fallbacks like Georgia, fall back cleanly
          return baseTheme;
      }
    }

    final baseTextTheme = ThemeData(brightness: brightness).textTheme;
    final bodyTextTheme = resolveGoogleTextTheme(bodyFont, baseTextTheme);
    final headerTextTheme = resolveGoogleTextTheme(headerFont, baseTextTheme);

    final TextTheme textTheme = TextTheme(
      displayLarge: headerTextTheme.displayLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.bold, fontFamily: headerFont) ??
          TextStyle(fontFamily: headerFont, color: textPrimary, fontWeight: FontWeight.bold),
      displayMedium: headerTextTheme.displayMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.bold, fontFamily: headerFont) ??
          TextStyle(fontFamily: headerFont, color: textPrimary, fontWeight: FontWeight.bold),
      displaySmall: headerTextTheme.displaySmall?.copyWith(color: textPrimary, fontWeight: FontWeight.bold, fontFamily: headerFont) ??
          TextStyle(fontFamily: headerFont, color: textPrimary, fontWeight: FontWeight.bold),
      headlineLarge: headerTextTheme.headlineLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.bold, fontFamily: headerFont) ??
          TextStyle(fontFamily: headerFont, color: textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: headerTextTheme.headlineMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.bold, fontFamily: headerFont) ??
          TextStyle(fontFamily: headerFont, color: textPrimary, fontWeight: FontWeight.bold),
      headlineSmall: headerTextTheme.headlineSmall?.copyWith(color: textPrimary, fontWeight: FontWeight.bold, fontFamily: headerFont) ??
          TextStyle(fontFamily: headerFont, color: textPrimary, fontWeight: FontWeight.bold),
      
      titleLarge: bodyTextTheme.titleLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: bodyTextTheme.titleMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
      titleSmall: bodyTextTheme.titleSmall?.copyWith(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 14, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
      
      bodyLarge: bodyTextTheme.bodyLarge?.copyWith(color: textPrimary, fontSize: 15, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: textPrimary, fontSize: 15),
      bodyMedium: bodyTextTheme.bodyMedium?.copyWith(color: textSecondary, fontSize: 14, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: textSecondary, fontSize: 14),
      bodySmall: bodyTextTheme.bodySmall?.copyWith(color: textSecondary, fontSize: 12, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: textSecondary, fontSize: 12),
      
      labelLarge: bodyTextTheme.labelLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: primaryColor, fontWeight: FontWeight.bold),
      labelMedium: bodyTextTheme.labelMedium?.copyWith(color: primaryColor, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: primaryColor),
      labelSmall: bodyTextTheme.labelSmall?.copyWith(color: primaryColor, fontFamily: bodyFont) ??
          TextStyle(fontFamily: bodyFont, color: primaryColor),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: borderCol,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: isDark ? const Color(0xFF0F1E15) : Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: Colors.red.shade400,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: textPrimary,
        surface: cardColor,
        onSurface: textPrimary,
        tertiary: accentColor,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isDark ? 4 : 2,
        shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderCol, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: headerFont,
        ),
      ),
      textTheme: textTheme,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontFamily: bodyFont, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? backgroundColor : Colors.white,
        selectedColor: primaryColor,
        disabledColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        labelStyle: TextStyle(color: textPrimary, fontSize: 13, fontFamily: bodyFont),
        secondaryLabelStyle: TextStyle(color: isDark ? const Color(0xFF0F1E15) : Colors.white, fontSize: 13, fontFamily: bodyFont),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
