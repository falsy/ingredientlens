import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../models/recent_result.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/preferences_service.dart';
import '../services/consent_service.dart';
import '../utils/theme.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/category_section_widget.dart';
import '../widgets/recent_results_section_widget.dart';
import '../widgets/category_action_bottom_sheet.dart';
import '../widgets/image_source_bottom_sheet.dart';
import '../widgets/home_footer_widget.dart';
import 'custom_camera_screen.dart';
import 'image_crop_screen.dart';
import 'compare_screen.dart';
import 'saved_results_screen.dart';
import 'analysis_result_screen.dart';
import 'comparison_result_screen.dart';
import 'consent_required_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, RouteAware {
  List<RecentResult> _recentResults = [];
  String? _currentCategoryId;
  String? _currentCategoryName;
  String? _customCategoryText;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRecentResults();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 Recent Results 새로고침
      _loadRecentResults();
    }
  }

  void _loadRecentResults() async {
    try {
      final results = await DatabaseService().getRecentResults();
      setState(() {
        _recentResults = results;
      });
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HomeScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 갱신
    _loadRecentResults();
  }

  void _showCategoryActionBottomSheet(
      String categoryId, String categoryName, bool isCustom) {
    setState(() {
      _currentCategoryId = categoryId;
      _currentCategoryName = categoryName;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryActionBottomSheet(
        categoryId: categoryId,
        categoryName: categoryName,
        isCustomCategory: isCustom,
        onCustomCategoryChanged: (customText) {
          _customCategoryText = customText;
        },
        onAnalyze: _showImageSourceBottomSheet,
        onCompare: _onComparePressed,
      ),
    );
  }

  void _showImageSourceBottomSheet(String category) async {
    // 동의 상태 확인
    final canUseService = await ConsentService().canUseService();
    if (!canUseService && mounted) {
      // 동의하지 않은 경우 동의 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ConsentRequiredScreen()),
      );
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
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        categoryName: _currentCategoryName ?? category,
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

  void _onComparePressed() async {
    // 동의 상태 확인
    final canUseService = await ConsentService().canUseService();
    if (!canUseService && mounted) {
      // 동의하지 않은 경우 동의 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ConsentRequiredScreen()),
      );
      return;
    }

    String? categoryToCompare;

    if (_currentCategoryId == 'other') {
      // Custom category - this will be handled in the bottom sheet
      categoryToCompare = _customCategoryText?.trim();
    } else {
      categoryToCompare = _currentCategoryId;
    }

    if (categoryToCompare != null && categoryToCompare.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompareScreen(category: categoryToCompare!),
          settings: const RouteSettings(name: '/compare'),
        ),
      ).then((_) {
        // 비교 화면에서 돌아왔을 때 Recent Results 새로고침
        _loadRecentResults();
      });
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('photo_error', {'error': e.toString()})),
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

  void _navigateToSavedResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedResultsScreen(),
        settings: const RouteSettings(name: '/saved-results'),
      ),
    );
  }

  void _onRecentResultTap(RecentResult result) {
    try {
      final resultData = jsonDecode(result.resultData);

      if (result.type == 'analysis') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              analysisResult: resultData,
              category: result.category,
              fromSavedResults: true,
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
              fromSavedResults: true,
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

  void _onRecentResultDelete(RecentResult result) async {
    try {
      await DatabaseService().deleteRecentResult(result.id!);
      _loadRecentResults(); // Refresh the list
    } catch (e) {
      // Error deleting - ignore silently
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return AppLocalizations.of(context)!
          .translate('time_days_ago')
          .replaceAll('{days}', '${difference.inDays}');
    } else if (difference.inHours > 0) {
      return AppLocalizations.of(context)!
          .translate('time_hours_ago')
          .replaceAll('{hours}', '${difference.inHours}');
    } else if (difference.inMinutes > 0) {
      return AppLocalizations.of(context)!
          .translate('time_minutes_ago')
          .replaceAll('{minutes}', '${difference.inMinutes}');
    } else {
      return AppLocalizations.of(context)!.translate('time_just_now');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false, // 하단 SafeArea 비활성화
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    // padding: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.only(
                      top: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - 48, // vertical padding 제외
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 340),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Section
                                    HomeHeaderWidget(
                                      onSavedResultsTap:
                                          _navigateToSavedResults,
                                    ),
                                    const SizedBox(height: 38),

                                    // Category Section
                                    CategorySectionWidget(
                                      onCategoryTap:
                                          _showCategoryActionBottomSheet,
                                    ),
                                    const SizedBox(height: 38),

                                    // Ad banner
                                    const AdBannerWidget(),
                                    const SizedBox(height: 38),

                                    // Recent Results Section
                                    RecentResultsSectionWidget(
                                      recentResults: _recentResults,
                                      formatDateTime: _formatDateTime,
                                      onResultTap: _onRecentResultTap,
                                      onDeleteTap: _onRecentResultDelete,
                                    ),
                                    const SizedBox(height: 38),

                                    // Announcements Section
                                    // const AnnouncementsSectionWidget(),
                                    // const SizedBox(height: 38),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Footer - 전체 폭 사용
                          const HomeFooterWidget(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 안드로이드 시스템 네비게이션 바 영역 고려
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
