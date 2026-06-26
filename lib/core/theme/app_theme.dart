import 'package:flutter/material.dart';

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
    
    // Choose Colors based on preset & brightness
    Color primaryColor;
    Color secondaryColor;
    Color backgroundColor;
    Color cardColor;
    Color textPrimary;
    Color textSecondary;
    Color borderCol;

    if (preset == 'sapphire') {
      primaryColor = isDark ? warmGold : sapphireDeep;
      secondaryColor = sapphireRoyal;
      backgroundColor = isDark ? sapphireBgDark : sapphireBgLight;
      cardColor = isDark ? sapphireCardDark : Colors.white;
      textPrimary = isDark ? const Color(0xFFE2E7EB) : const Color(0xFF16222F);
      textSecondary = isDark ? const Color(0xFF909CA6) : const Color(0xFF4C5865);
      borderCol = isDark ? const Color(0xFF172C41) : const Color(0xFFE2E7EB);
    } else if (preset == 'ruby') {
      primaryColor = isDark ? premiumGold : rubyDeep;
      secondaryColor = rubyAmber;
      backgroundColor = isDark ? rubyBgDark : rubyBgLight;
      cardColor = isDark ? rubyCardDark : Colors.white;
      textPrimary = isDark ? const Color(0xFFEBE2E2) : const Color(0xFF2F1616);
      textSecondary = isDark ? const Color(0xFFA69090) : const Color(0xFF654C4C);
      borderCol = isDark ? const Color(0xFF411717) : const Color(0xFFEBE2E2);
    } else {
      // Default: Emerald
      primaryColor = isDark ? warmGold : emeraldDeep;
      secondaryColor = emeraldSage;
      backgroundColor = isDark ? emeraldBgDark : emeraldBgLight;
      cardColor = isDark ? emeraldCardDark : Colors.white;
      textPrimary = isDark ? const Color(0xFFE2EBE5) : const Color(0xFF1C2D24);
      textSecondary = isDark ? const Color(0xFF90A397) : const Color(0xFF556B5F);
      borderCol = isDark ? const Color(0xFF1E3A2B) : const Color(0xFFE5EDE8);
    }

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
        tertiary: warmGold,
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
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display',
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Playfair Display', color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'Poppins', color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: TextStyle(fontFamily: 'Poppins', color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: textPrimary, fontSize: 15),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: textSecondary, fontSize: 14),
        labelLarge: TextStyle(fontFamily: 'Poppins', color: primaryColor, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? backgroundColor : Colors.white,
        selectedColor: primaryColor,
        disabledColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        labelStyle: TextStyle(color: textPrimary, fontSize: 13, fontFamily: 'Poppins'),
        secondaryLabelStyle: TextStyle(color: isDark ? const Color(0xFF0F1E15) : Colors.white, fontSize: 13, fontFamily: 'Poppins'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
