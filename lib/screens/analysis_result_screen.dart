import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/usage_limit_service.dart';
import '../models/recent_result.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/save_result_bottom_sheet.dart';
import '../widgets/ingredient_search_bottom_sheet.dart';
import '../widgets/interstitial_ad_widget.dart';
import '../screens/ingredient_detail_screen.dart';
import '../config/app_config.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.translate('daily_limit_reached')),
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

    // 광고 표시 (로딩과 광고를 한번에)
    if (AppConfig.enableAds) {
      _isAdShowing = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InterstitialAdWidget(
            onAdDismissed: () {
              _isAdShowing = false;
              // 광고가 닫혔을 때 대기 중인 결과가 있으면 처리
              if (_pendingApiResult != null) {
                _navigateToResult(_pendingApiResult!, ingredientName);
                _pendingApiResult = null;
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
      );
    }
  }

  void _performIngredientSearch(String ingredientName) async {
    try {
      final langCode = Localizations.localeOf(context).languageCode;
      
      final result = await ApiService.getIngredientDetail(
        ingredient: ingredientName,
        category: widget.category,
        langCode: langCode,
      );

      if (mounted) {
        if (_isAdShowing) {
          // 광고가 표시 중이면 결과를 저장하고 대기
          _pendingApiResult = result;
        } else {
          // 광고가 없으면 바로 결과 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IngredientDetailScreen(
                ingredientDetail: result,
                ingredientName: ingredientName,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.translate('analysis_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
        // 에러 시 로딩 화면까지 모두 닫기
        Navigator.popUntil(context, (route) => 
          route.settings.name != null || route.isFirst);
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
        ),
      ),
    );
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!
              .translate('analysis_results')
              .toUpperCase(),
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
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
          icon: const Icon(Icons.arrow_back,
              color: AppTheme.blackColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _buildSectionsWithSpacing(context),
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        // ListView 대신 Column으로 최적화
        ...items.map((item) => _buildIngredientCard(context, item, color)),
      ],
    );
  }

  Widget _buildIngredientCard(
      BuildContext context, dynamic item, Color accentColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cardBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            child: Row(
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
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showIngredientSearchBottomSheet(item['name'] ?? ''),
                  child: SvgPicture.asset(
                    'assets/icons/wandstars.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.gray500,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['description'] ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: AppTheme.gray700,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionsWithSpacing(BuildContext context) {
    List<Widget> sections = [];

    // 긍정적인 성분
    final positiveSection = _buildSection(
      context,
      title: AppLocalizations.of(context)!.translate('positive_ingredients'),
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
      title: AppLocalizations.of(context)!.translate('negative_ingredients'),
      items: widget.analysisResult['negative_ingredients'] ?? [],
      color: AppTheme.blackColor,
      icon: Icons.not_interested,
    );
    if (negativeSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(negativeSection);
    }

    // 기타 성분
    final otherSection = _buildSection(
      context,
      title: AppLocalizations.of(context)!.translate('other_ingredients'),
      items: widget.analysisResult['other_ingredients'] ?? [],
      color: AppTheme.blackColor,
      icon: Icons.local_offer_outlined,
    );
    if (otherSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(otherSection);
    }

    // 총평
    final overallSection = _buildOverallReview(context);
    if (overallSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(overallSection);
    }

    // 광고 섹션 (총평 후에)
    if (sections.isNotEmpty) {
      sections.add(const SizedBox(height: 24));
      sections.add(const AdBannerWidget());
    }

    // 저장 버튼 추가 (저장된 결과에서 온 경우가 아닐 때만)
    if (sections.isNotEmpty && !widget.fromSavedResults) {
      sections.add(const SizedBox(height: 32));
      sections.add(_buildScreenshotButton(context));
    }

    // AI 안내 메시지 추가
    if (sections.isNotEmpty) {
      sections.add(const SizedBox(height: 32));
      sections.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cardBorderColor,
              width: 1,
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.translate('ai_disclaimer'),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray500,
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
        icon: const Icon(Icons.save_alt, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.translate('save_result'),
          style: AppTheme.getButtonTextStyle(color: Colors.white),
        ),
        style: AppTheme.getButtonStyle('action'),
      ),
    );
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
        Text(
          AppLocalizations.of(context)!.translate('overall_review'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cardBorderColor,
              width: 1,
            ),
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
