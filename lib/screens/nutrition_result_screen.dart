import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/share_service.dart';
import '../services/preferences_service.dart';
import '../models/recent_nutrition_result.dart';
import '../widgets/result_banner_ad_widget.dart';
import '../widgets/save_result_bottom_sheet.dart';

class NutritionResultScreen extends StatefulWidget {
  final Map<String, dynamic> nutritionResult;
  final String category;
  final bool fromSavedResults;
  final bool isFromRecentResults;

  const NutritionResultScreen({
    super.key,
    required this.nutritionResult,
    required this.category,
    this.fromSavedResults = false,
    this.isFromRecentResults = false,
  });

  @override
  State<NutritionResultScreen> createState() => _NutritionResultScreenState();
}

class _NutritionResultScreenState extends State<NutritionResultScreen> {
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
      final overallSummary =
          widget.nutritionResult['personalized_overall_summary'] ??
              widget.nutritionResult['overall_summary'];

      if (overallSummary != null && overallSummary.toString().isNotEmpty) {
        // 영양 분석 전용 최근 결과에 저장
        String summaryText;
        if (overallSummary is List) {
          summaryText = (overallSummary).join(' ');
        } else {
          summaryText = overallSummary.toString();
        }

        final recentNutritionResult = RecentNutritionResult(
          overallReview: summaryText,
          category: widget.category,
          responseData: jsonEncode(widget.nutritionResult),
          createdAt: DateTime.now(),
        );

        await PreferencesService.instance
            .addRecentNutritionResult(recentNutritionResult);
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
        resultData: widget.nutritionResult,
        resultType: 'nutrition',
        category: widget.category,
      ),
    ).then((result) {
      if (result == true && mounted) {
        // 저장 성공 시 처리는 bottom sheet에서 이미 했으므로 추가 작업 없음
      }
    });
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
        fileName: 'nutrition_result_${DateTime.now().millisecondsSinceEpoch}',
        shareText:
            'IngredientLens - ${AppLocalizations.of(context)!.nutrition_analysis_title}',
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
            AppLocalizations.of(context)!.nutrition_analysis_title,
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

  Widget _buildNutritionAnalysisSection(BuildContext context) {
    final nutritionAnalysis =
        widget.nutritionResult['nutrition_analysis'] as List<dynamic>?;
    if (nutritionAnalysis == null || nutritionAnalysis.isEmpty) {
      return const SizedBox.shrink();
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
              child: Text(
                AppLocalizations.of(context)!.nutrition_analysis_title,
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
        ...nutritionAnalysis.map((item) => _buildNutrientCard(context, item)),
      ],
    );
  }

  Widget _buildNutrientCard(BuildContext context, dynamic item) {
    final nutrient = item['nutrient'] ?? '';
    final amount = item['amount'] ?? '';
    final dailyValuePercentage = item['daily_value_percentage'] ?? '';
    final evaluation = item['evaluation'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                      nutrient,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.blackColor,
                      ),
                    ),
                  ),
                  if (amount.isNotEmpty) ...[
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    // 1일 권장량 비율이 있고 '정보없음'이 아닌 경우 함량 옆에 표기
                    if (dailyValuePercentage.isNotEmpty &&
                        dailyValuePercentage != '정보없음') ...[
                      const SizedBox(width: 4),
                      Text(
                        '($dailyValuePercentage)',
                        style: TextStyle(
                          fontSize: AppTheme.adjustFontSizeForPlatform(13),
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              if (evaluation.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  evaluation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: AppTheme.adjustFontSizeForPlatform(15),
                        color: AppTheme.gray700,
                        height: 1.5,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHealthSection(BuildContext context, String title,
      List<dynamic> items, String iconAsset, bool isWarning) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 1),
            SvgPicture.asset(
              iconAsset,
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
        // 각 항목을 개별 카드로 표시
        ...items.map((item) => _buildHealthItemCard(context, item, isWarning)),
      ],
    );
  }

  Widget _buildHealthItemCard(
      BuildContext context, dynamic item, bool isWarning) {
    final component = item['component'] ?? '';
    final description =
        isWarning ? (item['warning'] ?? '') : (item['benefit'] ?? '');

    return Column(
      children: [
        Container(
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
              if (component.isNotEmpty) ...[
                Text(
                  component,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.blackColor,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (description.isNotEmpty)
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: AppTheme.adjustFontSizeForPlatform(15),
                        color: AppTheme.gray700,
                        height: 1.5,
                      ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildSectionsWithSpacing(BuildContext context) {
    List<Widget> sections = [];

    // 영양성분 분석
    final nutritionSection = _buildNutritionAnalysisSection(context);
    if (nutritionSection is! SizedBox) {
      sections.add(nutritionSection);
    }

    // 건강 경고사항
    final healthWarnings =
        widget.nutritionResult['health_warnings'] as List<dynamic>? ?? [];
    final warningsSection = _buildHealthSection(
        context,
        AppLocalizations.of(context)!.nutrition_warnings,
        healthWarnings,
        'assets/icons/emergency.svg',
        true); // isWarning = true
    if (warningsSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(warningsSection);
    }

    // 건강 이점
    final healthBenefits =
        widget.nutritionResult['health_benefits'] as List<dynamic>? ?? [];
    final benefitsSection = _buildHealthSection(
        context,
        AppLocalizations.of(context)!.nutrition_benefits,
        healthBenefits,
        'assets/icons/emergency.svg',
        false); // isWarning = false
    if (benefitsSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(benefitsSection);
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

    // 총평
    final overallSection = _buildOverallSummary(context);
    if (overallSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(overallSection);
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
    final personalizedScore =
        widget.nutritionResult['personalized_nutrition_score'];
    final nutritionScore = widget.nutritionResult['nutrition_score'];

    // personalized_nutrition_score가 있으면 우선 사용, 없으면 nutrition_score 사용
    final scoreToUse = personalizedScore ?? nutritionScore;
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

  Widget _buildOverallSummary(BuildContext context) {
    final personalizedSummary =
        widget.nutritionResult['personalized_overall_summary'];
    final overallSummary = widget.nutritionResult['overall_summary'];

    // personalized_overall_summary가 있으면 우선 사용, 없으면 overall_summary 사용
    final summaryToUse = personalizedSummary ?? overallSummary;
    final isPersonalized = personalizedSummary != null;

    if (summaryToUse == null ||
        (summaryToUse is List && summaryToUse.isEmpty)) {
      return const SizedBox.shrink();
    }

    // 배열을 List<String>으로 변환
    final List<String> summaryList = summaryToUse is String
        ? [summaryToUse]
        : (summaryToUse as List).cast<String>();

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
                      text: AppLocalizations.of(context)!.overall_review,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.cardBoxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < summaryList.length; i++) ...[
                Text(
                  summaryList[i],
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.gray700,
                    height: 1.5,
                  ),
                ),
                if (i < summaryList.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
