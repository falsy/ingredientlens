import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../widgets/ad_banner_widget.dart';
import 'save_result_overlay_screen.dart';

class ComparisonResultScreen extends StatefulWidget {
  final Map<String, dynamic> comparisonResult;
  final String category;
  final bool fromSavedResults;

  const ComparisonResultScreen({
    super.key,
    required this.comparisonResult,
    required this.category,
    this.fromSavedResults = false,
  });

  @override
  State<ComparisonResultScreen> createState() => _ComparisonResultScreenState();
}

class _ComparisonResultScreenState extends State<ComparisonResultScreen> {
  void _showSaveBottomSheet() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) => SaveResultOverlayScreen(
          resultData: widget.comparisonResult,
          resultType: 'comparison',
          category: widget.category,
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        // 저장 성공 시 처리는 overlay screen에서 이미 했으므로 추가 작업 없음
      }
    });
  }

  void _handleBackNavigation() {
    if (widget.fromSavedResults) {
      // 저장된 결과에서 온 경우 저장된 결과 목록으로 돌아가기
      Navigator.pop(context);
    } else {
      // 그 외의 경우는 모두 홈 화면으로 돌아가기
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppTheme.backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false; // 기본 뒤로가기 동작을 막음
      },
      child: Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!
              .translate('compare_ingredients')
              .toUpperCase(),
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.backgroundColor,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.backgroundColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryGreen, size: 28),
          onPressed: _handleBackNavigation,
        ),
      ),
      body: Column(
        children: [
          Expanded(
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
          // 하단 광고 배너
          const AdBannerWidget(),
          // 안드로이드 시스템 네비게이션 바 영역 고려
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
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
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gray100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name'] ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.blackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['description'] ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

    // Product A 성분
    final productASection = _buildSection(
      title: AppLocalizations.of(context)!.translate('product_a'),
      items: widget.comparisonResult['product_a_ingredients'] ?? [],
      color: AppTheme.primaryGreen,
      icon: Icons.label_outline,
    );
    if (productASection is! SizedBox) {
      sections.add(productASection);
    }

    // Product B 성분
    final productBSection = _buildSection(
      title: AppLocalizations.of(context)!.translate('product_b'),
      items: widget.comparisonResult['product_b_ingredients'] ?? [],
      color: AppTheme.primaryGreen,
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

    // 스크린샷 저장 버튼 추가 (저장된 결과에서 온 경우가 아닐 때만)
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            AppLocalizations.of(context)!.translate('ai_disclaimer'),
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildScreenshotButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showSaveBottomSheet,
        icon: const Icon(Icons.save_alt, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.translate('save_result'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildOverallComparison(BuildContext context) {
    final overallReview = widget.comparisonResult['overall_comparative_review'];
    if (overallReview == null || (overallReview is List && overallReview.isEmpty)) {
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
            Icon(Icons.compare_arrows, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.translate('overall_comparison'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.whiteColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.gray100,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < reviewList.length; i++) ...[
                Text(
                  reviewList[i],
                  style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.blackColor,
                        height: 1.6,
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
