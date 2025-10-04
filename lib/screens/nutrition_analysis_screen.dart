import 'package:flutter/material.dart';
import 'package:ingredient_lens/widgets/ad_banner_widget.dart';
import 'package:ingredient_lens/widgets/home_footer_widget.dart';
import '../widgets/nutrition_analysis_section_widget.dart';
import '../widgets/recent_nutrition_results_section_widget.dart';
import '../widgets/tab_header_widget.dart';
import '../widgets/image_source_bottom_sheet.dart';
// import '../widgets/user_customization_banner_widget.dart';
import '../services/consent_service.dart';
import '../services/preferences_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../models/recent_nutrition_result.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_camera_screen.dart';
import 'nutrition_image_crop_screen.dart';
import 'nutrition_result_screen.dart';
// import 'profile_screen.dart';
import 'dart:convert';

class NutritionAnalysisScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const NutritionAnalysisScreen({super.key, this.scrollController});

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  State<NutritionAnalysisScreen> createState() =>
      _NutritionAnalysisScreenState();
}

class _NutritionAnalysisScreenState extends State<NutritionAnalysisScreen>
    with WidgetsBindingObserver, RouteAware {
  final ImagePicker _picker = ImagePicker();
  List<RecentNutritionResult> _recentNutritionResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRecentNutritionResults();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NutritionAnalysisScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 갱신
      _loadRecentNutritionResults();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      NutritionAnalysisScreen.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 갱신
    _loadRecentNutritionResults();
  }

  void _loadRecentNutritionResults() {
    setState(() {
      _recentNutritionResults =
          PreferencesService.instance.getRecentNutritionResults();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inDays > 0) {
      return l10n.time_days_ago(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.time_hours_ago(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.time_minutes_ago(difference.inMinutes);
    } else {
      return l10n.time_just_now;
    }
  }

  void _onRecentNutritionResultTap(RecentNutritionResult result) {
    try {
      final nutritionResult = jsonDecode(result.responseData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionResultScreen(
            nutritionResult: nutritionResult,
            category: result.category,
            fromSavedResults: false, // 저장 버튼 표시
            isFromRecentResults: true, // 최근 결과에 중복 저장 방지
          ),
        ),
      ).then((_) {
        // 돌아왔을 때 최근 결과 새로고침
        _loadRecentNutritionResults();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.analysis_failed),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    }
  }

  void _onDeleteNutritionResult(RecentNutritionResult result) async {
    final success = await PreferencesService.instance
        .removeRecentNutritionResult(result.createdAt);
    if (success) {
      _loadRecentNutritionResults();
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.delete_success),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  void _onNutritionCategoryTap(String categoryId, String categoryName) {
    _showImageSourceBottomSheet(categoryId, categoryName);
  }

  void _showImageSourceBottomSheet(String category, String categoryName) async {
    // 동의 상태 확인 (UMP에서 자동으로 처리하므로 커스텀 체크 제거)
    final canUseService = await ConsentService().canUseService();
    if (!canUseService && mounted) {
      // 동의가 필요한 경우 UMP가 자동으로 동의 양식을 표시함
      return;
    }

    // Save last selected category
    if (category != 'other') {
      PreferencesService.instance.setLastSelectedCategory(category);
    }

    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        categoryName: categoryName,
        analysisType: AnalysisType.nutrition, // 영양 분석
        onGalleryTap: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 100), () {
            _pickImageFromGallery(category);
          });
        },
        onCameraTap: () {
          Navigator.pop(context);
          _openCustomCamera(category);
        },
      ),
    );
  }

  Future<void> _pickImageFromGallery(String category) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionImageCropScreen(
              imagePath: image.path,
              category: category,
            ),
          ),
        );
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

  void _openCustomCamera(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCameraScreen(
          category: category,
          isCompareMode: false,
        ),
      ),
    );
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
                title: AppLocalizations.of(context)!.nutrition_short,
              ),
            ),
            // 스크롤 가능한 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // 옥색-연두색 대각선 그라데이션 섹션
                    Container(
                      height: 110,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7FD18C), // 연두색
                            Color(0xFF81D4E0), // 라이트 청록색
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: [
                          // 아이콘 이미지 (오른쪽에 배치)
                          Positioned(
                            right: 13,
                            top: 13,
                            child: Container(
                              width: 84,
                              height: 84,
                              child: Image.asset(
                                'assets/images/antelope.webp',
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
                                          .nutrition_screen_header_title,
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
                                          .nutrition_screen_header_text,
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

                    // 영양 분석 섹션
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: NutritionAnalysisSectionWidget(
                        onCategoryTap: _onNutritionCategoryTap,
                      ),
                    ),

                    const SizedBox(height: 18),

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

                    // 최근 영양 분석 섹션
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: RecentNutritionResultsSectionWidget(
                        recentNutritionResults: _recentNutritionResults,
                        formatDateTime: _formatDateTime,
                        onResultTap: _onRecentNutritionResultTap,
                        onDeleteTap: _onDeleteNutritionResult,
                      ),
                    ),

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
    );
  }
}
