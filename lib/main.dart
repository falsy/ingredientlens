import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/nutrition_analysis_screen.dart';
import 'screens/calorie_analysis_screen.dart';
import 'services/localization_service.dart';
import 'services/preferences_service.dart';
import 'services/consent_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Lock to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    // Firebase Analytics instance (will be used throughout the app)
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Firebase 초기화가 실패해도 앱을 계속 실행
  }

  // 상태바와 네비게이션 바 색상 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 투명한 상태바
      statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상 (어두운 색)
      statusBarBrightness: Brightness.light, // iOS용 상태바 밝기
      systemNavigationBarColor: Colors.white, // 흰색 네비게이션 바
      systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
    ),
  );

  // PreferencesService만 먼저 초기화 (필수)
  await PreferencesService.instance.init();

  // 다른 서비스들은 백그라운드에서 초기화 (블로킹하지 않음)
  _initializeServicesInBackground();

  runApp(const IngredientLensApp());
}

// 백그라운드에서 서비스들을 초기화하는 함수
void _initializeServicesInBackground() {
  // Google Mobile Ads와 ConsentService를 백그라운드에서 초기화
  Future.microtask(() async {
    try {
      // Google Mobile Ads 초기화
      await MobileAds.instance.initialize();
      debugPrint('MobileAds initialized successfully');

      // 애드몹 음소거 설정
      await MobileAds.instance.setAppMuted(true);
      await MobileAds.instance.setAppVolume(0.0);
      debugPrint('AdMob muted successfully');

      // 동의 관리 초기화
      await ConsentService().requestConsentInfoUpdate();
      debugPrint('ConsentService initialized successfully');
    } catch (e) {
      debugPrint('Background service initialization failed: $e');
      // 초기화 실패해도 앱은 정상 동작해야 함
    }
  });
}

class IngredientLensApp extends StatefulWidget {
  const IngredientLensApp({super.key});

  @override
  State<IngredientLensApp> createState() => _IngredientLensAppState();
}

class _IngredientLensAppState extends State<IngredientLensApp>
    with WidgetsBindingObserver {
  late LocalizationService _localizationService;

  @override
  void initState() {
    super.initState();
    _localizationService = LocalizationService.instance;

    // 시스템 테마 변경 감지를 위한 옵저버 등록 (no longer needed)
    // WidgetsBinding.instance.addObserver(this);

    // 저장된 언어 설정 다시 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _localizationService.reloadSavedLocale();
    });
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this); // no longer needed
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // No longer needed - always use light mode
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
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          navigatorObservers: [
            HomeScreen.routeObserver,
            NutritionAnalysisScreen.routeObserver,
            CalorieAnalysisScreen.routeObserver,
          ],
          // 전체 앱에서 디바이스 폰트 크기 무시
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          theme: AppTheme.lightTheme.copyWith(
            appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
          ),
          home: LanguageInitializer(
            localizationService: _localizationService,
            child: const InitialScreen(),
          ),
          routes: {
            '/home': (context) => const MainNavigationScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
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

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkConsentAndNavigate();
  }

  Future<void> _checkConsentAndNavigate() async {
    // 짧은 지연 후 실행하여 위젯 트리가 완전히 구성되도록 함
    await Future.delayed(const Duration(milliseconds: 100));

    debugPrint('🚀 Starting navigation check...');

    try {
      // 스플래시 제거 전에 시스템 UI 스타일 재설정
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // 스플래시 화면을 먼저 제거
      FlutterNativeSplash.remove();
      debugPrint('✅ Splash removed');

      if (!mounted) {
        debugPrint('❌ Widget not mounted, aborting navigation');
        return;
      }

      // 첫 실행 여부 확인
      final isFirstLaunch = PreferencesService.instance.isFirstLaunch();
      debugPrint('📱 Is first launch: $isFirstLaunch');

      // 다음 프레임에서 네비게이션 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        debugPrint('🔄 Executing navigation...');

        if (isFirstLaunch) {
          debugPrint('➡️ Navigating to onboarding');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        } else {
          debugPrint('➡️ Navigating to home');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        }
      });
    } catch (e) {
      debugPrint('💥 Navigation error: $e');
      FlutterNativeSplash.remove();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('➡️ Fallback navigation to home');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const MainNavigationScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
