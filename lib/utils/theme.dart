import 'package:flutter/material.dart';

class AppTheme {
  // 지원하는 언어 코드에서 Paperlogy 폰트 사용
  static String? getFontFamily(String languageCode) {
    const supportedLanguages = ['ko', 'en', 'ja'];
    return supportedLanguages.contains(languageCode) ? 'Paperlogy' : null;
  }
  static const Color blackColor = Color(0xFF000000);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color gray900 = Color(0xFF1A1A1A);
  static const Color gray700 = Color(0xFF4A4A4A);
  static const Color gray500 = Color(0xFF8A8A8A);
  static const Color gray300 = Color(0xFFD0D0D0);
  static const Color gray100 = Color(0xFFF0F0F0);

  static const Color positiveColor = Color(0xFF22C55E);
  static const Color negativeColor = Color(0xFFEF4444);
  
  // 새로운 디자인 색상
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color primaryGreen = Color(0xFF1B5E3F);  // 더 어두운 초록색
  static const Color cardShadow = Color(0x1A000000);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: whiteColor,
    primaryColor: blackColor,
    colorScheme: const ColorScheme.light(
      primary: blackColor,
      secondary: gray700,
      surface: gray100,
      onPrimary: whiteColor,
      onSecondary: whiteColor,
      onSurface: blackColor,
    ),
    fontFamily: 'Arial',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: blackColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: blackColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: blackColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: blackColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: blackColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: blackColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: blackColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: blackColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: gray700,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: blackColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: blackColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: gray700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: blackColor,
        foregroundColor: whiteColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: blackColor,
        side: const BorderSide(color: blackColor, width: 2),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: blackColor),
      titleTextStyle: TextStyle(
        color: blackColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
