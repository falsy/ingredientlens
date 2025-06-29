import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/consent_required_screen.dart';
import 'screens/consent_check_screen.dart';
import 'utils/theme.dart';
import 'services/localization_service.dart';
import 'services/preferences_service.dart';
import 'services/consent_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // 상태바와 네비게이션 바를 투명하게 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 투명한 상태바
      statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상 (어두운 색)
      statusBarBrightness: Brightness.light, // iOS용 상태바 밝기
      systemNavigationBarColor: Colors.transparent, // 투명한 네비게이션 바
      systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
    ),
  );

  // Google Mobile Ads 초기화
  await MobileAds.instance.initialize();

  // 동의 관리 초기화
  await ConsentService().requestConsentInfoUpdate();

  await PreferencesService.instance.init();
  runApp(const IngredientLensApp());
}

class IngredientLensApp extends StatefulWidget {
  const IngredientLensApp({super.key});

  @override
  State<IngredientLensApp> createState() => _IngredientLensAppState();
}

class _IngredientLensAppState extends State<IngredientLensApp> {
  late LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _localizationService = LocalizationService();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _localizationService,
      builder: (context, child) {
        return MaterialApp(
          title: 'IngredientLens',
          debugShowCheckedModeBanner: false,
          locale: _localizationService.locale,
          supportedLocales: LocalizationService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorObservers: [HomeScreen.routeObserver],
          theme: ThemeData(
            primarySwatch: Colors.grey,
            scaffoldBackgroundColor: AppTheme.whiteColor,
            fontFamily: AppTheme.getFontFamily(
                _localizationService.locale.languageCode),
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent, // 투명한 상태바
                statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상 (어두운 색)
                statusBarBrightness: Brightness.light, // iOS용 상태바 밝기
                systemNavigationBarColor: Colors.transparent, // 투명한 네비게이션 바
                systemNavigationBarIconBrightness:
                    Brightness.dark, // 네비게이션 바 아이콘 색상
              ),
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackColor,
                fontFamily: AppTheme.getFontFamily(
                    _localizationService.locale.languageCode),
              ),
              headlineMedium: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackColor,
                fontFamily: AppTheme.getFontFamily(
                    _localizationService.locale.languageCode),
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.blackColor,
                fontFamily: AppTheme.getFontFamily(
                    _localizationService.locale.languageCode),
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.blackColor,
                fontFamily: AppTheme.getFontFamily(
                    _localizationService.locale.languageCode),
              ),
            ),
          ),
          home: LanguageInitializer(
            localizationService: _localizationService,
            child: const ConsentCheckScreen(),
          ),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/consent': (context) => const ConsentRequiredScreen(),
          },
        );
      },
    );
  }
}

class LanguageInitializer extends StatelessWidget {
  final LocalizationService localizationService;
  final Widget child;

  const LanguageInitializer({
    super.key,
    required this.localizationService,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
