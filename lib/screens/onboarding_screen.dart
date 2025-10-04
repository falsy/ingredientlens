import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../services/preferences_service.dart';
import '../services/consent_service.dart';
import '../utils/theme.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    // Debug: 현재 언어 코드 확인
    print('Current locale: $locale');

    final List<OnboardingStep> steps = [
      OnboardingStep(
        title: localizations.onboarding_step1_title,
        description: localizations.onboarding_step1_description,
        imagePath: 'assets/images/step/${locale}1.webp',
      ),
      OnboardingStep(
        title: localizations.onboarding_step2_title,
        description: localizations.onboarding_step2_description,
        imagePath: 'assets/images/step/${locale}2.webp',
      ),
      OnboardingStep(
        title: localizations.onboarding_step3_title,
        description: localizations.onboarding_step3_description,
        imagePath: 'assets/images/step/${locale}3.webp',
      ),
      OnboardingStep(
        title: localizations.onboarding_step4_title,
        description: localizations.onboarding_step4_description,
        imagePath: 'assets/images/step/${locale}4.webp',
      ),
      OnboardingStep(
        title: localizations.onboarding_step5_title,
        description: localizations.onboarding_step5_description,
        imagePath: 'assets/images/step/${locale}5.webp',
      ),
      OnboardingStep(
        title: localizations.onboarding_step6_title,
        description: localizations.onboarding_step6_description,
        imagePath: 'assets/images/step/${locale}6.webp',
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  steps[index].imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                        'Failed to load image: ${steps[index].imagePath}');
                                    print('Error: $error');
                                    // Fallback to English images if localized image not found
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        'assets/images/step/en${index + 1}.webp',
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          print(
                                              'Failed to load English fallback image: assets/images/step/en${index + 1}.webp');
                                          print('Error: $error');
                                          // If even English images don't exist, show placeholder
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.image,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                steps[index].title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  steps[index].description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        height: 1.5,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicator dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: _currentPage == index ? 24.0 : 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: _currentPage == index
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
            // Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 첫 실행 완료 표시
                    await PreferencesService.instance.setFirstLaunchCompleted();

                    // 동의 상태 확인 후 적절한 화면으로 이동
                    final canUseService =
                        await ConsentService().canUseService();

                    if (mounted) {
                      if (canUseService) {
                        // 동의가 필요없거나 이미 동의한 경우 홈 화면으로
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const MainNavigationScreen()),
                        );
                      } else {
                        // 동의가 필요한 경우 UMP가 자동으로 동의 양식을 표시하므로 홈으로 이동
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const MainNavigationScreen()),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation:
                        Theme.of(context).brightness == Brightness.dark ? 0 : 2,
                    shadowColor:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.3),
                  ),
                  child: Text(
                    localizations.get_started,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final String imagePath;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
