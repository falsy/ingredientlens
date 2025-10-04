import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/usage_limit_service.dart';
import '../services/share_service.dart';
import '../services/analytics_service.dart';
import '../services/user_preference_service.dart';
import '../services/preferences_service.dart';
import '../models/recent_result.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/result_banner_ad_widget.dart';
import '../widgets/save_result_bottom_sheet.dart';
import '../widgets/ingredient_search_bottom_sheet.dart';
import '../widgets/interstitial_ad_widget.dart';
import '../widgets/hexagon_chart.dart';
import '../screens/ingredient_detail_screen.dart';

class AnalysisResultScreen extends StatefulWidget {
  final Map<String, dynamic> analysisResult;
  final String category;
  final bool fromSavedResults;
  final bool isFromRecentResults;

  const AnalysisResultScreen({
    super.key,
    required this.analysisResult,
    required this.category,
    this.fromSavedResults = false,
    this.isFromRecentResults = false,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _saveRecentResult();
  }

  void _saveRecentResult() async {
    // Don't save to recent results if this is from saved results screen or from recent results
    if (widget.fromSavedResults || widget.isFromRecentResults) return;

    try {
      final overallReviewList =
          widget.analysisResult['overall_review'] as List<dynamic>?;
      final overallReview = overallReviewList?.isNotEmpty == true
          ? overallReviewList!.join(' ')
          : '';

      if (overallReview.isNotEmpty) {
        final recentResult = RecentResult(
          type: 'analysis',
          category: widget.category,
          overallReview: overallReview,
          resultData: jsonEncode(widget.analysisResult),
          createdAt: DateTime.now(),
        );

        await DatabaseService().saveRecentResult(recentResult);
      }
    } catch (e) {
      // Error saving recent result - ignore silently
    }
  }

  void _showSaveBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => SaveResultBottomSheet(
        resultData: widget.analysisResult,
        resultType: 'analysis',
        category: widget.category,
      ),
    ).then((result) {
      if (result == true && mounted) {
        // 저장 성공 시 처리는 bottom sheet에서 이미 했으므로 추가 작업 없음
      }
    });
  }

  void _showIngredientSearchBottomSheet(String ingredientName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => IngredientSearchBottomSheet(
        ingredientName: ingredientName,
        category: widget.category,
        onSearchRequested: () => _startIngredientSearch(ingredientName),
      ),
    );
  }

  bool _isAdShowing = false;
  Map<String, dynamic>? _pendingApiResult;

  void _startIngredientSearch(String ingredientName) async {
    // 사용량 제한 확인
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

    // 사용량 증가
    await usageLimitService.incrementUsage();

    // 상태 초기화
    _isAdShowing = false;
    _pendingApiResult = null;

    // API 호출 시작
    _performIngredientSearch(ingredientName);

    // 전면 광고와 API 통신을 병렬로 실행
    _isAdShowing = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterstitialAdWidget(
          onAdDismissed: () {
            _isAdShowing = false;
            // 광고가 닫혔을 때 대기 중인 결과가 있으면 처리
            final pendingResult = _pendingApiResult;
            if (pendingResult != null) {
              _pendingApiResult = null;
              _navigateToResult(pendingResult, ingredientName);
            }
          },
          onAnalysisCancelled: () {
            _isAdShowing = false;
            _pendingApiResult = null;
            // 취소 시 현재 화면만 닫기
            Navigator.pop(context);
          },
        ),
      ),
    ).then((_) {
      // 광고 화면이 닫혔을 때 (뒤로가기 등)
      _isAdShowing = false;
      // 대기 중인 결과가 있으면 바로 이동
      final pendingResult = _pendingApiResult;
      if (pendingResult != null) {
        _pendingApiResult = null;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IngredientDetailScreen(
              ingredientDetail: pendingResult,
              ingredientName: ingredientName,
              category: widget.category,
            ),
          ),
        );
      }
    });
  }

  void _performIngredientSearch(String ingredientName) async {
    try {
      final langCode = Localizations.localeOf(context).languageCode;

      // 현재 카테고리에 맞는 프로필 설정 가져오기
      final selectedPreference = PreferencesService.instance
          .getCategoryPreferenceSelection(widget.category);

      Map<String, List<String>>? profileData;
      Map<String, List<String>>? babyData;
      Map<String, List<String>>? petData;

      if (selectedPreference != 'none') {
        final userPreferenceService = UserPreferenceService();
        final allPreferences = await userPreferenceService.getAllPreferences();

        if (selectedPreference == 'baby') {
          babyData = {
            'age': allPreferences
                .where((pref) => pref.category == 'baby_age')
                .map((pref) => pref.value)
                .toList(),
            'skin': allPreferences
                .where((pref) => pref.category == 'baby_skin')
                .map((pref) => pref.value)
                .toList(),
            'allergy': allPreferences
                .where((pref) => pref.category == 'baby_allergy')
                .map((pref) => pref.value)
                .toList(),
            'health': allPreferences
                .where((pref) => pref.category == 'baby_health')
                .map((pref) => pref.value)
                .toList(),
          };
          babyData.removeWhere((key, value) => value.isEmpty);
          if (babyData.isEmpty) babyData = null;
        } else if (selectedPreference == 'pet') {
          petData = {
            'type': allPreferences
                .where((pref) => pref.category == 'pet_type')
                .map((pref) => pref.value)
                .toList(),
            'breed': allPreferences
                .where((pref) => pref.category == 'pet_breed')
                .map((pref) => pref.value)
                .toList(),
            'age': allPreferences
                .where((pref) => pref.category == 'pet_age')
                .map((pref) => pref.value)
                .toList(),
            'weight': allPreferences
                .where((pref) => pref.category == 'pet_weight')
                .map((pref) => pref.value)
                .toList(),
            'allergy': allPreferences
                .where((pref) => pref.category == 'pet_allergy')
                .map((pref) => pref.value)
                .toList(),
            'health': allPreferences
                .where((pref) => pref.category == 'pet_health')
                .map((pref) => pref.value)
                .toList(),
            'neutered': allPreferences
                .where((pref) => pref.category == 'pet_neutered')
                .map((pref) => pref.value)
                .toList(),
          };
          petData.removeWhere((key, value) => value.isEmpty);
          if (petData.isEmpty) petData = null;
        } else if (selectedPreference == 'user') {
          profileData = {
            'religion': allPreferences
                .where((pref) => pref.category == 'religion')
                .map((pref) => pref.value)
                .toList(),
            'skin': allPreferences
                .where((pref) => pref.category == 'skin')
                .map((pref) => pref.value)
                .toList(),
            'allergy': allPreferences
                .where((pref) => pref.category == 'allergy')
                .map((pref) => pref.value)
                .toList(),
            'diet': allPreferences
                .where((pref) => pref.category == 'diet')
                .map((pref) => pref.value)
                .toList(),
            'health': allPreferences
                .where((pref) => pref.category == 'health')
                .map((pref) => pref.value)
                .toList(),
          };
          profileData.removeWhere((key, value) => value.isEmpty);
          if (profileData.isEmpty) profileData = null;
        }
      }

      final result = await ApiService.getIngredientDetail(
        ingredient: ingredientName,
        category: widget.category,
        langCode: langCode,
        profile: profileData,
        baby: babyData,
        pet: petData,
      );

      // Analytics: 성분 검색 이벤트
      await AnalyticsService.logIngredientSearch(
        ingredientName: ingredientName,
        category: widget.category,
      );

      if (mounted) {
        // 항상 결과를 저장
        _pendingApiResult = result;

        if (_isAdShowing) {
          // 광고가 표시 중이면 결과를 저장하고 대기
        } else {
          // 광고가 이미 닫혔다면 광고 화면을 명시적으로 닫고 결과 화면으로 이동
          // 현재 광고 화면을 닫기
          Navigator.pop(context);
          // 잠시 후 성분 상세 화면으로 이동
          Future.delayed(const Duration(milliseconds: 50), () {
            final pendingResult = _pendingApiResult;
            if (mounted && pendingResult != null) {
              _pendingApiResult = null;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IngredientDetailScreen(
                    ingredientDetail: pendingResult,
                    ingredientName: ingredientName,
                    category: widget.category,
                  ),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.analysis_failed),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
        // 에러 시 로딩 화면까지 모두 닫기
        Navigator.popUntil(
            context, (route) => route.settings.name != null || route.isFirst);
      }
    }
  }

  void _navigateToResult(Map<String, dynamic> result, String ingredientName) {
    // 광고 화면을 결과 화면으로 교체
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IngredientDetailScreen(
          ingredientDetail: result,
          ingredientName: ingredientName,
          category: widget.category,
        ),
      ),
    );
  }

  Future<void> _shareResults() async {
    try {
      // 캡처 모드 활성화 (광고 숨김)
      setState(() {
        _isCapturing = true;
      });

      // UI 업데이트 대기
      await Future.delayed(const Duration(milliseconds: 100));

      await ShareService.captureAndShare(
        repaintBoundaryKey: _repaintBoundaryKey,
        fileName: 'analysis_result_${DateTime.now().millisecondsSinceEpoch}',
        shareText:
            'IngredientLens - ${AppLocalizations.of(context)!.analysis_results}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.share_error(e.toString())),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    } finally {
      // 캡처 모드 비활성화 (광고 복원)
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 결과 화면에서도 상태바와 네비게이션 바를 배경색으로 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.analysis_results,
            style: const TextStyle(
              color: AppTheme.blackColor,
              fontSize: AppTheme.appBarTitleFontSize,
              fontWeight: AppTheme.appBarTitleFontWeight,
              letterSpacing: 0.4,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: _buildSectionsWithSpacing(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<dynamic> items,
    required Color color,
    required IconData icon,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 1),
            SvgPicture.asset(
              'assets/icons/emergency.svg',
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppTheme.blackColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ListView 대신 Column으로 최적화
        ...items.map((item) => _buildIngredientCard(context, item, color)),
      ],
    );
  }

  Widget _buildIngredientCard(
      BuildContext context, dynamic item, Color accentColor) {
    final personalizedScore = item['personalized_score'];
    final score = item['score'];
    final scoreToUse = personalizedScore ?? score;
    final isPersonalized = personalizedScore != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showIngredientSearchBottomSheet(item['name'] ?? ''),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardBoxShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.blackColor,
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        return SvgPicture.asset(
                          'assets/icons/arrow-right.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Color.fromARGB(160, 0, 0, 0),
                            BlendMode.srcIn,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item['description'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: AppTheme.adjustFontSizeForPlatform(15),
                        color: AppTheme.gray700,
                        height: 1.5,
                      ),
                ),
                if (scoreToUse != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${(scoreToUse as num).round()}${AppLocalizations.of(context)!.points}',
                        style: TextStyle(
                          fontSize: AppTheme.adjustFontSizeForPlatform(14),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (isPersonalized) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!
                                .personalized_info_applied,
                            style: TextStyle(
                              fontSize: AppTheme.adjustFontSizeForPlatform(12),
                              fontWeight: FontWeight.w400,
                              color: AppTheme.gray600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildSectionsWithSpacing(BuildContext context) {
    List<Widget> sections = [];

    // 긍정적인 성분
    final positiveSection = _buildSection(
      context,
      title: AppLocalizations.of(context)!.positive_ingredients,
      items: widget.analysisResult['positive_ingredients'] ?? [],
      color: AppTheme.blackColor,
      icon: Icons.check,
    );
    if (positiveSection is! SizedBox) {
      sections.add(positiveSection);
    }

    // 부정적인 성분
    final negativeSection = _buildSection(
      context,
      title: AppLocalizations.of(context)!.negative_ingredients,
      items: widget.analysisResult['negative_ingredients'] ?? [],
      color: AppTheme.blackColor,
      icon: Icons.not_interested,
    );
    if (negativeSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(negativeSection);
    }

    // 광고 섹션 (캡처 모드가 아닐 때만)
    if (sections.isNotEmpty && !_isCapturing) {
      sections.add(const SizedBox(height: 24));
      sections.add(const ResultBannerAdWidget());
    }

    // AI 평가 점수
    final aiScoreSection = _buildAiEvaluationScore(context);
    if (aiScoreSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(aiScoreSection);
    }

    // 카테고리 점수 차트
    final categoryChartSection = _buildCategoryChart(context);
    if (categoryChartSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(categoryChartSection);
    }

    // 총평
    final overallSection = _buildOverallReview(context);
    if (overallSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(overallSection);
    }

    // 광고 섹션 (캡처 모드가 아닐 때만)
    if (sections.isNotEmpty && !_isCapturing) {
      sections.add(const SizedBox(height: 32));
      sections.add(const AdBannerWidget());
    }

    // 저장 및 공유 버튼 추가
    if (sections.isNotEmpty) {
      sections.add(const SizedBox(height: 32));

      // 저장 버튼 (저장된 결과에서 온 경우가 아닐 때만)
      if (!widget.fromSavedResults) {
        sections.add(_buildScreenshotButton(context));
        sections.add(const SizedBox(height: 16));
      }

      // 공유 버튼 (항상 표시)
      sections.add(_buildShareButton(context));
    }

    // AI 안내 메시지 추가
    if (sections.isNotEmpty) {
      sections.add(const SizedBox(height: 32));
      sections.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.cardBoxShadow,
          ),
          child: Text(
            AppLocalizations.of(context)!.ai_disclaimer,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildScreenshotButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showSaveBottomSheet,
        icon: const Icon(Icons.save_alt, color: AppTheme.backgroundColor),
        label: Text(
          AppLocalizations.of(context)!.save_result,
          style: AppTheme.getButtonTextStyle(color: AppTheme.backgroundColor),
        ),
        style: AppTheme.getButtonStyle('action'),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (!_isCapturing) {
            _shareResults();
          }
        },
        icon: _isCapturing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.whiteColor),
                ),
              )
            : const Icon(Icons.share, color: AppTheme.whiteColor),
        label: Text(
          _isCapturing
              ? AppLocalizations.of(context)!.sharing
              : AppLocalizations.of(context)!.share,
          style: AppTheme.getButtonTextStyle(color: AppTheme.whiteColor),
        ),
        style: AppTheme.getButtonStyle('action2'),
      ),
    );
  }

  Widget _buildAiEvaluationScore(BuildContext context) {
    final personalizedScore = widget.analysisResult['personalized_score'];
    final productScore = widget.analysisResult['product_score'];

    // personalized_score가 있으면 우선 사용, 없으면 product_score 사용
    final scoreToUse = personalizedScore ?? productScore;
    final isPersonalized = personalizedScore != null;

    // 점수가 없으면 위젯을 표시하지 않음
    if (scoreToUse == null) {
      return const SizedBox.shrink();
    }

    // 점수를 정수로 변환
    int score;
    if (scoreToUse is num) {
      score = scoreToUse.round();
    } else {
      return const SizedBox.shrink();
    }

    // 점수에 따른 등급 결정
    String gradeKey;
    if (score >= 80) {
      gradeKey = 'excellent';
    } else if (score >= 60) {
      gradeKey = 'good';
    } else if (score >= 40) {
      gradeKey = 'average';
    } else {
      gradeKey = 'caution';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 1),
            SvgPicture.asset(
              'assets/icons/emergency.svg',
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppTheme.blackColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.ai_evaluation_score,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.blackColor,
                      ),
                    ),
                    if (isPersonalized)
                      TextSpan(
                        text:
                            ' ${AppLocalizations.of(context)!.personalized_info_applied}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.gray600,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.cardBoxShadow,
          ),
          child: Text(
            '${score}${AppLocalizations.of(context)!.points} (${_getLocalizedGrade(context, gradeKey)})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.blackColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _getLocalizedGrade(BuildContext context, String gradeKey) {
    switch (gradeKey) {
      case 'excellent':
        return AppLocalizations.of(context)!.excellent;
      case 'good':
        return AppLocalizations.of(context)!.good;
      case 'average':
        return AppLocalizations.of(context)!.average;
      case 'caution':
        return AppLocalizations.of(context)!.caution;
      default:
        return AppLocalizations.of(context)!.average;
    }
  }

  Widget _buildCategoryChart(BuildContext context) {
    final categoryScores =
        widget.analysisResult['category_scores'] as Map<String, dynamic>?;
    if (categoryScores == null || categoryScores.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert to Map<String, double>
    final scores = <String, double>{};
    categoryScores.forEach((key, value) {
      scores[key] = (value as num).toDouble();
    });

    // 다국어 라벨 매핑
    final labels = _getCategoryLabels(context, scores.keys.toList());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 1),
            SvgPicture.asset(
              'assets/icons/emergency.svg',
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppTheme.blackColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.category_analysis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppTheme.blackColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: HexagonChart(
            data: scores,
            labels: labels,
            maxValue: 100.0,
            size: 280,
            primaryColor: AppTheme.primaryColor,
            secondaryColor: AppTheme.secondaryColor,
            backgroundColor: Colors.transparent,
            gridColor: AppTheme.blackColor.withOpacity(0.08),
          ),
        ),
      ],
    );
  }

  Map<String, String> _getCategoryLabels(
      BuildContext context, List<String> keys) {
    final localizations = AppLocalizations.of(context)!;
    final labels = <String, String>{};

    for (final key in keys) {
      switch (key) {
        case 'nutritional_value':
          labels[key] = localizations.nutritional_value;
          break;
        case 'safety':
          labels[key] = localizations.safety;
          break;
        case 'natural_ingredients':
          labels[key] = localizations.natural_ingredients;
          break;
        case 'functional_benefits':
          labels[key] = localizations.functional_benefits;
          break;
        case 'taste_quality':
          labels[key] = localizations.taste_quality;
          break;
        case 'moisturizing':
          labels[key] = localizations.moisturizing;
          break;
        case 'hypoallergenic':
          labels[key] = localizations.hypoallergenic;
          break;
        case 'longevity':
          labels[key] = localizations.longevity;
          break;
        case 'stability':
          labels[key] = localizations.stability;
          break;
        case 'absorption':
          labels[key] = localizations.absorption;
          break;
        case 'effectiveness':
          labels[key] = localizations.effectiveness;
          break;
        case 'gentleness':
          labels[key] = localizations.gentleness;
          break;
        case 'safety_standards':
          labels[key] = localizations.safety_standards;
          break;
        case 'nutritional_balance':
          labels[key] = localizations.nutritional_balance;
          break;
        case 'digestibility':
          labels[key] = localizations.digestibility;
          break;
        case 'palatability':
          labels[key] = localizations.palatability;
          break;
        case 'functionality':
          labels[key] = localizations.functionality;
          break;
        case 'side_effects':
          labels[key] = localizations.side_effects;
          break;
        case 'quality_standards':
          labels[key] = localizations.quality_standards;
          break;
        case 'interactions':
          labels[key] = localizations.interactions;
          break;
        default:
          labels[key] = key; // fallback to key itself
      }
    }

    return labels;
  }

  Widget _buildOverallReview(BuildContext context) {
    final overallReview = widget.analysisResult['overall_review'];
    if (overallReview == null ||
        (overallReview is List && overallReview.isEmpty)) {
      return const SizedBox.shrink();
    }

    // 이전 버전 호환성을 위해 String인 경우도 처리
    final List<String> reviewList = overallReview is String
        ? [overallReview]
        : (overallReview as List).cast<String>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 1),
            SvgPicture.asset(
              'assets/icons/emergency.svg',
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppTheme.blackColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.overall_review,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppTheme.blackColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.cardBoxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < reviewList.length; i++) ...[
                Text(
                  reviewList[i],
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.gray700,
                    height: 1.5,
                  ),
                ),
                if (i < reviewList.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
