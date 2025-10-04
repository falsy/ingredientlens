import 'package:flutter/material.dart';
import 'preferences_service.dart';

class LocalizationService extends ChangeNotifier {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('hi', 'IN'), // Hindi
    Locale('ja', 'JP'), // Japanese
    Locale('ko', 'KR'), // Korean
    Locale('pt', 'BR'), // Portuguese
    Locale('th', 'TH'), // Thai
    Locale('vi', 'VN'), // Vietnamese
  ];

  static LocalizationService? _instance;
  static LocalizationService get instance {
    _instance ??= LocalizationService._internal();
    return _instance!;
  }

  Locale _locale = supportedLocales.first;

  Locale get locale => _locale;

  LocalizationService._internal() {
    _loadSavedLocale();
  }

  LocalizationService() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    // PreferencesService가 초기화될 때까지 기다림
    await Future.delayed(Duration.zero);

    final languageCode = PreferencesService.instance.getLanguageCode();
    if (languageCode != null) {
      final newLocale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
        orElse: () => supportedLocales.first,
      );
      if (_locale != newLocale) {
        _locale = newLocale;
        notifyListeners();
      }
    } else {
      // 시스템 언어 감지
      final systemLocale = _getSystemLocale();
      if (_locale != systemLocale) {
        _locale = systemLocale;
        notifyListeners();
      }
    }
  }

  Locale _getSystemLocale() {
    // 시스템 언어를 확인하여 지원되는 언어 중에 있으면 사용
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;

    // 지원하는 언어인지 확인
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }

    // 지원하지 않는 언어면 영어 사용
    return supportedLocales.first;
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    await PreferencesService.instance.setLanguageCode(locale.languageCode);
    notifyListeners();
  }

  // 저장된 언어 설정을 다시 로드
  Future<void> reloadSavedLocale() async {
    await _loadSavedLocale();
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ko':
        return '한국어';
      case 'ja':
        return '日本語';
      case 'pt':
        return 'Português';
      case 'th':
        return 'ไทย';
      case 'vi':
        return 'Tiếng Việt';
      case 'hi':
        return 'हिंदी';
      default:
        return 'English';
    }
  }
}
