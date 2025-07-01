import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/database_service.dart';
import '../models/recent_result.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/save_result_bottom_sheet.dart';

class ComparisonResultScreen extends StatefulWidget {
  final Map<String, dynamic> comparisonResult;
  final String category;
  final bool fromSavedResults;
  final bool isFromRecentResults;

  const ComparisonResultScreen({
    super.key,
    required this.comparisonResult,
    required this.category,
    this.fromSavedResults = false,
    this.isFromRecentResults = false,
  });

  @override
  State<ComparisonResultScreen> createState() => _ComparisonResultScreenState();
}

class _ComparisonResultScreenState extends State<ComparisonResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveRecentResult();
  }

  void _saveRecentResult() async {
    // Don't save to recent results if this is from saved results screen or from recent results
    if (widget.fromSavedResults || widget.isFromRecentResults) return;

    try {
      final overallComparativeReviewList = widget
          .comparisonResult['overall_comparative_review'] as List<dynamic>?;
      final overallComparativeReview =
          overallComparativeReviewList?.isNotEmpty == true
              ? overallComparativeReviewList!.join(' ')
              : '';

      if (overallComparativeReview.isNotEmpty) {
        final recentResult = RecentResult(
          type: 'compare',
          category: widget.category,
          overallReview: overallComparativeReview,
          resultData: jsonEncode(widget.comparisonResult),
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
        resultData: widget.comparisonResult,
        resultType: 'comparison',
        category: widget.category,
      ),
    ).then((result) {
      if (result == true && mounted) {
        // 저장 성공 시 처리는 bottom sheet에서 이미 했으므로 추가 작업 없음
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              .translate('compare_ingredients')
              .toUpperCase(),
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
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
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: _buildSectionsWithSpacing(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
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
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildIngredientCard(item, color)),
      ],
    );
  }

  Widget _buildIngredientCard(dynamic item, Color accentColor) {
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
          Text(
            item['name'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['description'] ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray700,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionsWithSpacing(BuildContext context) {
    List<Widget> sections = [];

    // Product A 성분
    final productASection = _buildSection(
      title: AppLocalizations.of(context)!.translate('product_a'),
      items: widget.comparisonResult['product_a_ingredients'] ?? [],
      color: AppTheme.blackColor,
      icon: Icons.label_outline,
    );
    if (productASection is! SizedBox) {
      sections.add(productASection);
    }

    // Product B 성분
    final productBSection = _buildSection(
      title: AppLocalizations.of(context)!.translate('product_b'),
      items: widget.comparisonResult['product_b_ingredients'] ?? [],
      color: AppTheme.blackColor,
      icon: Icons.label_outline,
    );
    if (productBSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(productBSection);
    }

    // 종합 비교 분석
    final overallSection = _buildOverallComparison(context);
    if (overallSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(overallSection);
    }

    // 광고 섹션 (종합 비교 분석 후에)
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

  Widget _buildOverallComparison(BuildContext context) {
    final overallReview = widget.comparisonResult['overall_comparative_review'];
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
            const Icon(Icons.compare_arrows,
                color: AppTheme.blackColor, size: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.translate('overall_comparison'),
              style: const TextStyle(
                fontSize: 15,
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
                    fontSize: 15,
                    color: AppTheme.gray700,
                    height: 1.45,
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
