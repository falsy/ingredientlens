import 'package:flutter/material.dart';
import 'package:ingredient_lens/widgets/ad_banner_widget.dart';
import 'package:ingredient_lens/widgets/home_footer_widget.dart';
import '../widgets/tab_header_widget.dart';
import '../widgets/calorie_image_source_bottom_sheet.dart';
import '../widgets/today_calories_section_widget.dart';
import '../widgets/weekly_calories_section_widget.dart';
import '../widgets/interstitial_ad_widget.dart';
// import '../widgets/user_customization_banner_widget.dart';
import '../models/calorie_analysis_result.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/consent_service.dart';
import '../services/usage_limit_service.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'custom_camera_screen.dart';
import 'calorie_result_screen.dart';
import 'monthly_calorie_report_screen.dart';
// import 'profile_screen.dart';

class CalorieAnalysisScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const CalorieAnalysisScreen({super.key, this.scrollController});

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  State<CalorieAnalysisScreen> createState() => _CalorieAnalysisScreenState();
}

class _CalorieAnalysisScreenState extends State<CalorieAnalysisScreen>
    with WidgetsBindingObserver, RouteAware {
  final ImagePicker _picker = ImagePicker();
  bool _isAnalysisCancelled = false;
  Key _todayCaloriesKey = UniqueKey();
  Key _weeklyCaloriesKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CalorieAnalysisScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      CalorieAnalysisScreen.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 칼로리 데이터 새로고침
    _refreshCalorieData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 처리
      _refreshCalorieData();
    }
  }

  void _refreshCalorieData() {
    // 칼로리 섹션들 새로고침 (키 기반으로 강제 리빌드)
    if (mounted) {
      setState(() {
        // 위젯 키를 변경하여 강제로 새로고침
        _todayCaloriesKey = UniqueKey();
        _weeklyCaloriesKey = UniqueKey();
      });
    }
  }

  void _showCalorieImageSourceBottomSheet() async {
    // 동의 상태 확인 (UMP에서 자동으로 처리하므로 커스텀 체크 제거)
    final canUseService = await ConsentService().canUseService();
    if (!canUseService && mounted) {
      // 동의가 필요한 경우 UMP가 자동으로 동의 양식을 표시함
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalorieImageSourceBottomSheet(
        onGalleryTap: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 100), () {
            _pickImageFromGallery();
          });
        },
        onCameraTap: () {
          Navigator.pop(context);
          _openCustomCamera();
        },
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        _showImagePreview(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.photo_error(e.toString()),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  void _openCustomCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCameraScreen(
          category: 'calorie', // 칼로리 전용 카테고리
          isCompareMode: false,
          onImageSelected: (File imageFile) {
            Navigator.pop(context); // 카메라 화면 닫기
            _showImagePreview(imageFile);
          },
        ),
      ),
    );
  }

  void _showImagePreview(File imageFile) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // 이미지 미리보기
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.gray300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(imageFile, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 안내 메시지
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.cardBorderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.confirm_analysis_notice,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: AppTheme.getButtonStyle('cancel'),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: AppTheme.getButtonTextStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startCalorieAnalysis(imageFile);
                      },
                      style: AppTheme.getButtonStyle('action'),
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: AppTheme.getButtonTextStyle(),
                      ),
                    ),
                  ),
                ],
              ),

              // 하단 SafeArea
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  void _startCalorieAnalysis(File imageFile) async {
    final usageLimitService = UsageLimitService();
    final canMakeRequest = await usageLimitService.canMakeRequest();

    if (!canMakeRequest) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.daily_limit_reached),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    _isAnalysisCancelled = false;
    await usageLimitService.incrementUsage();
    final analysisResult = _performCalorieAnalysisWithErrorHandling(imageFile);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterstitialAdWidget(
          onAdDismissed: () async {
            final errorMsg = await analysisResult;
            if (errorMsg != null && mounted) {
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        errorMsg,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.negativeColor,
                    ),
                  );
                }
              });
            }
          },
          onAnalysisCancelled: () {
            _isAnalysisCancelled = true;
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<String?> _performCalorieAnalysisWithErrorHandling(
      File imageFile) async {
    try {
      await _performCalorieAnalysis(imageFile);
      return null;
    } catch (e) {
      if (e.toString().contains('FOOD_NOT_FOUND')) {
        return AppLocalizations.of(context)!.food_not_found;
      }
      return AppLocalizations.of(context)!.analysis_failed;
    }
  }

  Future<void> _performCalorieAnalysis(File imageFile) async {
    // 현재 언어 코드 가져오기
    final langCode = Localizations.localeOf(context).languageCode;

    // API 호출
    final resultJson = await ApiService.analyzeCalorie(
      imageFile: imageFile,
      langCode: langCode,
    );

    // 결과를 모델로 변환
    final result = CalorieAnalysisResult.fromJson(resultJson);

    if (mounted && !_isAnalysisCancelled) {
      // Analytics: 칼로리 분석 완료 이벤트
      double totalCalories = 0;
      int foodCount = 0;
      String mealType = 'main_meal'; // 기본값

      if (result.foods.isNotEmpty) {
        foodCount = result.foods.length;
        for (var food in result.foods) {
          totalCalories += food.calories;
        }
      }

      await AnalyticsService.logCalorieAnalysisCompleted(
        mealType: mealType,
        totalCalories: totalCalories,
        foodCount: foodCount,
      );

      // 결과 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => CalorieResultScreen(
            analysisResult: result,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  // void _navigateToUserCustomization() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const ProfileScreen(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          ),
        ),
        child: Column(
          children: [
            // 고정 헤더
            SafeArea(
              bottom: false,
              child: TabHeaderWidget(
                title: AppLocalizations.of(context)!.calorie_short,
              ),
            ),
            // 스크롤 가능한 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // 그라데이션 섹션
                    Container(
                      height: 110,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0, -2.5), // 더 위쪽에서 시작
                          end: Alignment(0, 2.5), // 더 아래쪽에서 끝
                          colors: [
                            Color(0xFF4ECDC4), // 옥색
                            Color(0xFF7FD18C), // 연두색
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: [
                          // 아이콘 이미지 (오른쪽에 배치)
                          Positioned(
                            right: 15,
                            top: 17,
                            child: Container(
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                'assets/images/kcal.webp',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // 텍스트 (왼쪽에 배치)
                          Positioned(
                            left: 20,
                            top: 0,
                            bottom: 0,
                            right: 110, // 아이콘 공간 확보
                            child: Center(
                              child: SizedBox(
                                width: 200, // 텍스트 최대 너비 고정
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .calorie_screen_header_title_1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        height: 1.3,
                                        shadows: [
                                          Shadow(
                                            color: Color.fromARGB(15, 0, 0, 0),
                                            offset: Offset(0, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .calorie_screen_header_text_1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 오늘의 칼로리 섹션
                    TodayCaloriesSectionWidget(key: _todayCaloriesKey),

                    const SizedBox(height: 32),

                    // 사용자 정의 배너 (나중에 사용할 예정)
                    // UserCustomizationBannerWidget(
                    //   onTap: _navigateToUserCustomization,
                    // ),
                    // const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 6,
                      color: AppTheme.dividerColor,
                    ),

                    // Ad banner - full width, no padding
                    const AdBannerWidget(),

                    Container(
                      width: double.infinity,
                      height: 6,
                      color: AppTheme.dividerColor,
                    ),

                    const SizedBox(height: 32),

                    // 주간 칼로리 섹션
                    WeeklyCaloriesSectionWidget(key: _weeklyCaloriesKey),

                    // const SizedBox(height: 32),

                    // Container(
                    //   width: double.infinity,
                    //   height: 6,
                    //   color: AppTheme.dividerColor,
                    // ),

                    // const SizedBox(height: 32),

                    // // 월간 열량 리포트 버튼
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) =>
                    //               const MonthlyCalorieReportScreen(),
                    //         ),
                    //       );
                    //     },
                    //     child: Container(
                    //       width: double.infinity,
                    //       padding: const EdgeInsets.symmetric(
                    //           vertical: 12, horizontal: 16),
                    //       decoration: BoxDecoration(
                    //         color: AppTheme.whiteColor,
                    //         borderRadius: BorderRadius.circular(12),
                    //         boxShadow: AppTheme.cardBoxShadow,
                    //       ),
                    //       child: Row(
                    //         children: [
                    //           Image.asset(
                    //             'assets/images/report.webp',
                    //             width: 36,
                    //             height: 36,
                    //           ),
                    //           const SizedBox(width: 8),
                    //           Expanded(
                    //             child: Text(
                    //               AppLocalizations.of(context)!
                    //                   .monthly_calorie_report,
                    //               style: const TextStyle(
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.w700,
                    //                 // color: AppTheme.blackColor,
                    //                 color: AppTheme.blackColor,
                    //               ),
                    //             ),
                    //           ),
                    //           const Icon(
                    //             Icons.arrow_forward_ios,
                    //             size: 16,
                    //             // color: AppTheme.gray600,
                    //             color: AppTheme.gray500,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(height: 32),

                    Container(
                      width: double.infinity,
                      height: 6,
                      color: AppTheme.dividerColor,
                    ),

                    // Footer - 전체 폭 사용
                    const HomeFooterWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: _showCalorieImageSourceBottomSheet,
          backgroundColor: const Color.fromARGB(255, 250, 185, 55),
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
