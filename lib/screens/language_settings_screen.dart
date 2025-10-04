import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../services/localization_service.dart';
import '../services/preferences_service.dart';
import '../utils/theme.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  Locale? _currentLocale;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _loadCurrentLocale();
      _hasInitialized = true;
    }
  }

  Future<void> _loadCurrentLocale() async {
    final languageCode = PreferencesService.instance.getLanguageCode();
    if (languageCode != null) {
      final locale = LocalizationService.supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
        orElse: () => LocalizationService.supportedLocales.first,
      );
      setState(() {
        _currentLocale = locale;
      });
    } else {
      // 저장된 언어가 없으면 현재 시스템 언어로 설정
      final currentSystemLocale = Localizations.localeOf(context);
      final matchingLocale = LocalizationService.supportedLocales.firstWhere(
        (locale) => locale.languageCode == currentSystemLocale.languageCode,
        orElse: () => LocalizationService.supportedLocales.first,
      );
      setState(() {
        _currentLocale = matchingLocale;
      });
    }
  }

  void _changeLanguage(Locale locale) async {
    await LocalizationService.instance.setLocale(locale);
    setState(() {
      _currentLocale = locale;
    });

    // 스낵바 제거 - 언어 변경 시 알림 없이 바로 적용
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.language,
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: AppTheme.appBarTitleFontSize,
            fontWeight: AppTheme.appBarTitleFontWeight,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Transform.rotate(
            angle: 3.141592653589793, // 180도 회전 (π 라디안)
            child: Image.asset(
              'assets/images/icons/right-arrow.webp',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: LocalizationService.supportedLocales.length,
                  itemBuilder: (context, index) {
                    final locale = LocalizationService.supportedLocales[index];
                    final isSelected =
                        _currentLocale?.languageCode == locale.languageCode;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _changeLanguage(locale),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryTextColor.withOpacity(0.08)
                                  : AppTheme.cardBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryTextColor
                                    : AppTheme.cardBorderColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        LocalizationService.instance
                                            .getLanguageName(locale),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? AppTheme.primaryTextColor
                                              : const Color.fromARGB(
                                                  160, 0, 0, 0),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
