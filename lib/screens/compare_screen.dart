import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/interstitial_ad_widget.dart';
import '../services/api_service.dart';
import '../config/ad_config.dart';
import 'image_source_screen.dart';
import 'comparison_result_screen.dart';

class CompareScreen extends StatefulWidget {
  final String category;

  const CompareScreen({
    super.key,
    required this.category,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  File? _imageA;
  File? _imageB;
  bool _isAnalysisCancelled = false;

  @override
  void initState() {
    super.initState();
    // 상태바 색상 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F5F5),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF5F5F5),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _selectImage(bool isProductA) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageSourceScreen(
          category: widget.category,
          isCompareMode: true,
          onImageSelected: (File image) {
            setState(() {
              if (isProductA) {
                _imageA = image;
              } else {
                _imageB = image;
              }
            });
          },
        ),
      ),
    );
  }

  void _compareProducts() {
    if (_imageA == null || _imageB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate('select_both_products')),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
      return;
    }

    // 분석 시작
    _startComparison();
  }

  void _startComparison() {
    // 분석 시작 시 취소 플래그 초기화
    _isAnalysisCancelled = false;

    // API 호출을 먼저 시작
    _performComparison();

    // 전면 광고 표시 (API는 이미 시작됨)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterstitialAdWidget(
          customAdUnitId: AdConfig.compareAdUnitId, // 비교용 광고 ID
          onAdDismissed: () {
            // 광고가 끝났을 때는 아무것도 하지 않음 (API는 이미 진행 중)
          },
          onAnalysisCancelled: () {
            // 분석 취소 플래그 설정
            _isAnalysisCancelled = true;
            // 분석 취소 시 광고 화면 닫기
            Navigator.pop(context); // 광고 화면 닫기
          },
        ),
      ),
    );
  }

  void _performComparison() async {
    try {
      // 현재 로케일에서 언어 코드 가져오기
      final langCode = Localizations.localeOf(context).languageCode;

      // 실제 API 호출
      final result = await ApiService.compareIngredients(
        imageA: _imageA!,
        imageB: _imageB!,
        category: widget.category,
        langCode: langCode,
      );

      // 취소되지 않았을 때만 결과 화면으로 이동
      if (mounted && !_isAnalysisCancelled) {
        // 모든 화면을 닫고 결과 화면으로 이동
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ComparisonResultScreen(comparisonResult: result),
          ),
        );
      }
    } catch (e) {
      // 에러 처리 (취소되지 않았을 때만)
      if (mounted && !_isAnalysisCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.translate('analysis_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
        Navigator.pop(context); // 광고 화면 닫기
      }
    }
  }

  Widget _buildProductCard(String title, File? image, bool isProductA) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectImage(isProductA),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: image != null ? AppTheme.primaryGreen : AppTheme.gray300,
                width: image != null ? 2 : 1,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.gray100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppTheme.gray500,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.translate('tap_to_add'),
                          style: TextStyle(
                            color: AppTheme.gray500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('compare').toUpperCase(),
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF5F5F5),
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFFF5F5F5),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryGreen, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Category indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate(
                          'category_label', {
                        'category': AppLocalizations.of(context)!
                            .translate(widget.category)
                      }),
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product cards in 2 columns
                  Row(
                    children: [
                      Expanded(
                        child: _buildProductCard(
                          AppLocalizations.of(context)!.translate('product_a'),
                          _imageA,
                          true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildProductCard(
                          AppLocalizations.of(context)!.translate('product_b'),
                          _imageB,
                          false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Instruction message
                  Text(
                    AppLocalizations.of(context)!
                        .translate('compare_instruction'),
                    style: TextStyle(
                      color: AppTheme.gray700,
                      fontSize: 12,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Compare button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_imageA != null && _imageB != null)
                          ? _compareProducts
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        disabledBackgroundColor: AppTheme.gray300,
                        foregroundColor: AppTheme.whiteColor,
                        disabledForegroundColor: AppTheme.gray500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate('compare_ingredients'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 광고 배너
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
