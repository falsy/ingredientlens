import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/category.dart';
import '../models/recent_result.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/preferences_service.dart';
import '../utils/theme.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/category_section_widget.dart';
import '../widgets/recent_results_section_widget.dart';
import '../widgets/announcements_section_widget.dart';
import '../widgets/category_action_bottom_sheet.dart';
import '../widgets/home_footer_widget.dart';
import 'image_source_screen.dart';
import 'compare_screen.dart';
import 'saved_results_screen.dart';
import 'analysis_result_screen.dart';
import 'comparison_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RecentResult> _recentResults = [];
  String? _currentCategoryId;
  String? _currentCategoryName;
  String? _customCategoryText;

  @override
  void initState() {
    super.initState();
    _loadRecentResults();
    // 홈 화면에서 상태바와 네비게이션 바를 투명하게 설정
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 포커스될 때마다 Recent Results 새로고침
    _loadRecentResults();
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
  void dispose() {
    super.dispose();
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
        onAnalyze: _onAnalyzePressed,
        onCompare: _onComparePressed,
      ),
    );
  }

  void _onAnalyzePressed() {
    String? categoryToAnalyze;

    if (_currentCategoryId == 'other') {
      // Custom category - this will be handled in the bottom sheet
      categoryToAnalyze = _customCategoryText?.trim();
    } else {
      categoryToAnalyze = _currentCategoryId;
    }

    if (categoryToAnalyze != null && categoryToAnalyze.isNotEmpty) {
      if (_currentCategoryId != 'other') {
        PreferencesService.instance
            .setLastSelectedCategory(_currentCategoryId!);
      }
      _navigateToImageSource(categoryToAnalyze);
    }
  }

  void _onComparePressed() {
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
      );
    }
  }

  void _navigateToImageSource(String category) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageSourceScreen(category: category),
        ),
      );
    }
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
        );
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
        );
      }
    } catch (e) {
      // JSON parsing failed - ignore silently
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
