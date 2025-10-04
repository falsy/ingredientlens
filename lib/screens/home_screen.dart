import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
// import 'package:ingredient_lens/widgets/ad_banner_2_widget.dart';
import '../services/preferences_service.dart';
import '../services/consent_service.dart';
import '../utils/theme.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/tab_header_widget.dart';
import '../widgets/category_section_widget.dart';
import '../widgets/recent_results_section_widget.dart';
import '../widgets/category_action_bottom_sheet.dart';
import '../widgets/image_source_bottom_sheet.dart';
import '../widgets/home_footer_widget.dart';
import '../widgets/popular_categories_section_widget.dart';
// import '../widgets/user_customization_banner_widget.dart';
import '../models/recent_result.dart';
import '../services/database_service.dart';
import 'custom_camera_screen.dart';
import 'image_crop_screen.dart';
import 'compare_screen.dart';
import 'analysis_result_screen.dart';
import 'comparison_result_screen.dart';
// import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeScreen({super.key, this.scrollController});

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  String? _currentCategoryId;
  final ImagePicker _picker = ImagePicker();
  final List<Widget> _hiddenSvgs = [];
  List<RecentResult> _recentResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateSystemUIOverlay();
    _loadRecentResults();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 갱신
      _loadRecentResults();
    }
  }

  Future<void> _loadRecentResults() async {
    try {
      final results = await DatabaseService().getRecentResults();
      if (mounted) {
        setState(() {
          _recentResults = results;
        });
      }
    } catch (e) {
      // Error loading recent results - ignore silently
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      HomeScreen.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 갱신
    _loadRecentResults();
  }

  void _updateSystemUIOverlay() {
    // 홈 화면에서 상태바와 네비게이션 바를 투명하게 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HomeScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _showCategoryActionBottomSheet(
      String categoryId, String categoryName, bool isCustom) {
    setState(() {
      _currentCategoryId = categoryId;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryActionBottomSheet(
        categoryId: categoryId,
        categoryName: categoryName,
        isCustomCategory: isCustom,
        onCustomCategoryChanged: (customText) {},
        onAnalyze: (categoryId, categoryName) =>
            _showImageSourceBottomSheet(categoryId, categoryName),
        onCompare: (categoryName) => _onComparePressed(categoryName),
      ),
    );
  }

  void _showImageSourceBottomSheet(String category, String categoryName) async {
    // 동의 상태 확인 (UMP에서 자동으로 처리하므로 커스텀 체크 제거)
    final canUseService = await ConsentService().canUseService();
    if (!canUseService && mounted) {
      // 동의가 필요한 경우 UMP가 자동으로 동의 양식을 표시함
      return;
    }

    // Save last selected category
    if (_currentCategoryId != null && _currentCategoryId != 'other') {
      PreferencesService.instance.setLastSelectedCategory(_currentCategoryId!);
    }

    // 바텀시트 열기 전에 상태바 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        categoryName: categoryName,
        analysisType: AnalysisType.ingredient, // 성분 분석
        onGalleryTap: () {
          Navigator.pop(context);
          // 바텀시트 닫힌 후 잠시 대기
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

  void _onComparePressed(String categoryName) async {
    // 동의 상태 확인 (UMP에서 자동으로 처리하므로 커스텀 체크 제거)
    final canUseService = await ConsentService().canUseService();
    if (!canUseService && mounted) {
      // 동의가 필요한 경우 UMP가 자동으로 동의 양식을 표시함
      return;
    }

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => CompareScreen(category: categoryName),
        settings: const RouteSettings(name: '/compare'),
      ),
    ).then((_) {
      // 비교 화면에서 돌아왔을 때 Recent Results 새로고침
      _loadRecentResults();
    });
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
        // 갤러리에서 선택한 이미지를 크롭 화면으로 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageCropScreen(
              imagePath: image.path,
              category: category,
              isCompareMode: false,
            ),
          ),
        ).then((_) {
          // 분석 화면에서 돌아왔을 때 Recent Results 새로고침
          _loadRecentResults();
        });
      }
    } catch (e) {
      // 오류 발생 시에도 상태바 복원
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.photo_error(e.toString()),
              style: TextStyle(color: Colors.white),
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
    ).then((_) {
      // 카메라 화면에서 돌아왔을 때 Recent Results 새로고침
      _loadRecentResults();
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

  void _onResultTap(RecentResult result) {
    try {
      final resultData = jsonDecode(result.resultData);

      if (result.type == 'analysis') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              analysisResult: resultData,
              category: result.category,
              fromSavedResults: false, // Show save button
              isFromRecentResults: true, // Don't save to recent results again
            ),
          ),
        ).then((_) {
          _loadRecentResults();
        });
      } else if (result.type == 'compare') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComparisonResultScreen(
              comparisonResult: resultData,
              category: result.category,
              fromSavedResults: false, // Show save button
              isFromRecentResults: true, // Don't save to recent results again
            ),
          ),
        ).then((_) {
          _loadRecentResults();
        });
      }
    } catch (e) {
      // JSON parsing failed - ignore silently
    }
  }

  void _onDeleteResult(RecentResult result) async {
    try {
      await DatabaseService().deleteRecentResult(result.id!);
      _loadRecentResults(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.delete_success),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.delete_failed,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
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
    // 테마 변경 시 상태바 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlay();
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          ),
        ),
        child: Stack(
          children: [
            // 숨겨진 SVG 위젯들 (캐싱 목적)
            ..._hiddenSvgs,
            // 메인 UI
            Column(
              children: [
                // 고정 헤더
                SafeArea(
                  bottom: false,
                  child: TabHeaderWidget(
                    title: AppLocalizations.of(context)!.ingredients_short,
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
                                right: 14,
                                top: 14,
                                child: Container(
                                  width: 82,
                                  height: 82,
                                  child: Image.asset(
                                    'assets/images/bulb.webp',
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .ingredient_screen_header_title_1,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            height: 1.3,
                                            shadows: [
                                              Shadow(
                                                color:
                                                    Color.fromARGB(15, 0, 0, 0),
                                                offset: Offset(0, 1),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .ingredient_screen_header_text_1,
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

                        // Category Section without white background
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: CategorySectionWidget(
                            onCategoryTap: _showCategoryActionBottomSheet,
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

                        // Popular Categories Section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: PopularCategoriesSectionWidget(
                            onCategoryTap:
                                (categoryId, categoryName, isCustom) {
                              _showImageSourceBottomSheet(
                                  categoryId, categoryName);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        Container(
                          width: double.infinity,
                          height: 6,
                          color: AppTheme.dividerColor,
                        ),

                        const SizedBox(height: 32),

                        // Recent Results Section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: RecentResultsSectionWidget(
                            recentResults: _recentResults,
                            formatDateTime: _formatDateTime,
                            onResultTap: _onResultTap,
                            onDeleteTap: _onDeleteResult,
                          ),
                        ),

                        const SizedBox(height: 32),

                        Container(
                          width: double.infinity,
                          height: 6,
                          color: AppTheme.dividerColor,
                        ),

                        // Ad banner 2 - full width, no padding
                        // const AdBanner2Widget(),

                        // Container(
                        //   width: double.infinity,
                        //   height: 6,
                        //   color: AppTheme.dividerColor,
                        // ),

                        // Footer - 전체 폭 사용
                        const HomeFooterWidget(),

                        // 안드로이드 시스템 네비게이션 바 영역 고려
                        SafeArea(
                          top: false,
                          child: SizedBox(
                              height:
                                  MediaQuery.of(context).viewPadding.bottom),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
