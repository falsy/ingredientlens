import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/usage_limit_service.dart';
import '../widgets/interstitial_ad_widget.dart';
import '../widgets/image_source_bottom_sheet.dart';
import '../services/api_service.dart';
import '../config/ad_config.dart';
import '../config/app_config.dart';
import 'custom_camera_screen.dart';
import 'image_crop_screen.dart';
import 'comparison_result_screen.dart';

class CompareScreen extends StatefulWidget {
  final String category;
  final String? initialImageAPath;
  final String? initialImageBPath;

  const CompareScreen({
    super.key,
    required this.category,
    this.initialImageAPath,
    this.initialImageBPath,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  File? _imageA;
  File? _imageB;
  bool _isAnalysisCancelled = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // 초기 이미지 설정
    if (widget.initialImageAPath != null) {
      _imageA = File(widget.initialImageAPath!);
    }
    if (widget.initialImageBPath != null) {
      _imageB = File(widget.initialImageBPath!);
    }

    // 상태바 색상 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 투명한 상태바
        statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상 (어두운 색)
        statusBarBrightness: Brightness.light, // iOS용 상태바 밝기
        systemNavigationBarColor: Colors.transparent, // 투명한 네비게이션 바
        systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
      ),
    );
  }

  void _selectImage(bool isProductA) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ImageSourceBottomSheet(
          categoryName:
              AppLocalizations.of(context)!.translate(widget.category),
          onGalleryTap: () {
            Navigator.pop(context); // 바텀시트 닫기
            _pickImageFromGallery(isProductA);
          },
          onCameraTap: () {
            Navigator.pop(context); // 바텀시트 닫기
            _openCustomCamera(isProductA);
          },
        );
      },
    );
  }

  Future<void> _pickImageFromGallery(bool isProductA) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageCropScreen(
              imagePath: image.path,
              category: widget.category,
              isCompareMode: true,
              onImageSelected: (File croppedImage) {
                setState(() {
                  if (isProductA) {
                    _imageA = croppedImage;
                  } else {
                    _imageB = croppedImage;
                  }
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('photo_error', {'error': e.toString()})),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    }
  }

  void _openCustomCamera(bool isProductA) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCameraScreen(
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

  void _startComparison() async {
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

    // 분석 시작 시 취소 플래그 초기화
    _isAnalysisCancelled = false;

    // 사용량 증가
    await usageLimitService.incrementUsage();

    // API 호출을 먼저 시작
    _performComparison();

    // 광고가 활성화된 경우만 전면 광고 표시 (API는 이미 시작됨)
    if (AppConfig.enableAds) {
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
        // 모든 중간 화면을 제거하고 결과 화면으로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ComparisonResultScreen(
              comparisonResult: result,
              category: widget.category,
            ),
          ),
          (route) => route.isFirst, // 홈 화면만 남김
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectImage(isProductA),
          child: Container(
            height: 180,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: image != null ? AppTheme.blackColor : AppTheme.gray300,
                width: image != null ? 2 : 1,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                          decoration: const BoxDecoration(
                            color: AppTheme.cardBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppTheme.gray500,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.translate('tap_to_add'),
                          style: const TextStyle(
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
          statusBarColor: Colors.transparent, // 투명한 상태바
          statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상 (어두운 색)
          statusBarBrightness: Brightness.light, // iOS용 상태바 밝기
          systemNavigationBarColor: Colors.transparent, // 투명한 네비게이션 바
          systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppTheme.blackColor, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Category indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.cardBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate(
                            'category_label', {
                          'category': AppLocalizations.of(context)!
                              .translate(widget.category)
                        }),
                        style: const TextStyle(
                          color: AppTheme.blackColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Product cards in 2 columns
                    Row(
                      children: [
                        Expanded(
                          child: _buildProductCard(
                            AppLocalizations.of(context)!
                                .translate('product_a'),
                            _imageA,
                            true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildProductCard(
                            AppLocalizations.of(context)!
                                .translate('product_b'),
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
                      style: const TextStyle(
                        color: AppTheme.gray500,
                        fontSize: 12,
                        height: 1.3,
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
                          backgroundColor: AppTheme.blackColor,
                          disabledBackgroundColor: AppTheme.cardBackgroundColor,
                          foregroundColor: AppTheme.whiteColor,
                          disabledForegroundColor: AppTheme.gray500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: (_imageA == null || _imageB == null)
                                ? const BorderSide(
                                    color: AppTheme.cardBorderColor,
                                    width: 1,
                                  )
                                : BorderSide.none,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate('compare_ingredients'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
