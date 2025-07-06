import 'package:flutter/material.dart';

class AppTheme {
  // 모든 언어에서 Pretendard 폰트 사용
  static String? getFontFamily(String languageCode) {
    return 'Pretendard';
  }

  static const Color blackColor = Color(0xFF000000);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color gray900 = Color(0xFF1A1A1A);
  static const Color gray800 = Color(0xFF2A2A2A);
  static const Color gray700 = Color(0xFF4A4A4A);
  static const Color gray600 = Color(0xFF6A6A6A);
  static const Color gray500 = Color(0xFF8A8A8A);
  static const Color gray400 = Color(0xFFB0B0B0);
  static const Color gray300 = Color(0xFFD0D0D0);
  static const Color gray200 = Color(0xFFE0E0E0);
  static const Color gray100 = Color(0xFFF0F0F0);

  static const Color positiveColor = Color(0xFF22C55E);
  static const Color negativeColor = Color(0xFFEF4444);

  // 새로운 카드 색상
  static const Color cardBackgroundColor = Color(0xFFF9F9F9);
  static const Color cardBorderColor = Color(0xFFEEEEEE);

  // 새로운 디자인 색상
  static const Color backgroundColor = Color(0xFFFFFFFF); // White background
  static const Color primaryGreen = Color(0xFF1B5E3F); // 더 어두운 초록색
  static const Color cardShadow = Color(0x1A000000);

  // App Bar
  static const double appBarTitleFontSize = 20.0;
  static const FontWeight appBarTitleFontWeight = FontWeight.w600;

  // Button Style Constants
  static const double buttonHeight = 48.0;
  static const double buttonRadius = 28.0;
  static const double buttonFontSize = 15.0;
  static const FontWeight buttonFontWeight = FontWeight.w500;

  // 섹션
  static const Color sectionTitleColor = blackColor;
  static const double sectionTitleFontSize = 18.0;
  static const FontWeight sectionTitleFontWeight = FontWeight.w500;
  static const double sectionTitleLineHeight = 1.2;

  static const Color sectionSubtitleColor = gray600;
  static const double sectionSubtitleFontSize = 17.0;
  static const FontWeight sectionSubtitleFontWeight = FontWeight.w400;
  static const double sectionSubtitleLineHeight = 1.2;

  static const Color bodyTitleColor = blackColor;
  static const double bodyTitleFontSize = 17.0;
  static const FontWeight bodyTitleFontWeight = FontWeight.w400;
  static const double bodyTitleLineHeight = 1.5;

  static const Color bodyTextColor = gray700;
  static const double bodyTextFontSize = 16.0;
  static const FontWeight bodyTextFontWeight = FontWeight.w400;
  static const double bodyTextLineHeight = 1.5;

  // Bottom Sheet
  static const Color bottomSheetTitleColor = blackColor;
  static const double bottomSheetTitleFontSize = 18.0;
  static const FontWeight bottomSheetTitleFontWeight = FontWeight.w500;
  static const double bottomSheetTitleLineHeight = 1.3;

  static const Color bottomSheetSubtitleColor = gray500;
  static const double bottomSheetSubtitleFontSize = 17.0;
  static const FontWeight bottomSheetSubtitleFontWeight = FontWeight.w400;
  static const double bottomSheetSubtitleLineHeight = 1.3;

  // Button Color Schemes
  static const Map<String, Map<String, Color>> buttonColors = {
    'action': {
      'background': blackColor,
      'text': whiteColor,
      'border': blackColor,
    },
    'action2': {
      'background': whiteColor,
      'text': blackColor,
      'border': blackColor,
    },
    'cancel': {
      'background': gray100,
      'text': gray800,
      'border': gray100,
    },
    'disabled': {
      'background': gray100,
      'text': gray500,
      'border': gray100,
    },
  };

  // Get button style by type
  static ButtonStyle getButtonStyle(String type) {
    final colors = buttonColors[type] ?? buttonColors['action']!;

    return ElevatedButton.styleFrom(
      backgroundColor: colors['background'],
      foregroundColor: colors['text'],
      minimumSize: const Size(double.infinity, buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        side: type == 'cancel' || type == 'disabled' || type == 'action2'
            ? BorderSide(color: colors['border']!, width: 1)
            : BorderSide.none,
      ),
      elevation: 0,
    );
  }

  // Get text style for buttons
  static TextStyle getButtonTextStyle({Color? color}) {
    return TextStyle(
      fontSize: buttonFontSize,
      fontWeight: buttonFontWeight,
      color: color,
    );
  }

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
    fontFamily: getFontFamily('en'), // 기본값으로 영어 설정
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
