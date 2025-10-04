// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import 'dart:io';
import '../utils/theme.dart';
import '../utils/category_translation_util.dart';
import '../services/usage_limit_service.dart';
import '../services/user_preference_service.dart';
import '../services/preferences_service.dart';
import '../services/analytics_service.dart';
import '../widgets/interstitial_ad_widget.dart';
import '../widgets/image_source_bottom_sheet.dart';
import '../widgets/profile_preference_widget.dart';
import '../widgets/multi_profile_preference_widget.dart';
import '../services/api_service.dart';
import '../config/ad_config.dart';
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
  String _selectedPreference = 'user'; // 'none', 'user', 'baby', 'pet'
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // 저장된 프로필 선택 상태 불러오기
    _selectedPreference = PreferencesService.instance
        .getCategoryPreferenceSelection(widget.category);

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
        statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상
        statusBarBrightness: Brightness.light, // iOS용 상태바 밝기
        systemNavigationBarColor: Colors.transparent, // 투명한 네비게이션 바
        systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
      ),
    );
  }

  bool _isBabyCategory(String category) {
    return category == 'baby_products' || category.startsWith('baby_');
  }

  bool _isPetCategory(String category) {
    return category == 'pet_products' || category.startsWith('pet_');
  }

  bool _isBabyOrPetCategory(String category) {
    return _isBabyCategory(category) || _isPetCategory(category);
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
              CategoryTranslationUtil.getTranslatedCategoryOrSubcategory(
                  context, widget.category),
          analysisType: AnalysisType.ingredient, // 성분 비교
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
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.photo_error(e.toString()),
            style: const TextStyle(color: Colors.white),
          ),
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
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.select_both_products,
            style: const TextStyle(color: Colors.white),
          ),
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

    // 분석 시작 시 취소 플래그 초기화
    _isAnalysisCancelled = false;

    // 사용량 증가
    await usageLimitService.incrementUsage();

    // API 호출 Future 저장
    final comparisonResult = _performComparisonWithErrorHandling();

    // 전면 광고와 API 통신을 병렬로 실행 (API는 이미 시작됨)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterstitialAdWidget(
          customAdUnitId: AdConfig.compareAdUnitId, // 비교용 광고 ID
          onAdDismissed: () async {
            if (kDebugMode) print('📺 비교 광고 종료, API 완료 대기 중...');
            // 광고 종료 후 API 완료까지 기다림
            final errorMsg = await comparisonResult;
            if (errorMsg != null && mounted) {
              // API 에러가 있으면 광고 화면 닫고 에러 표시
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        errorMsg,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppTheme.negativeColor,
                    ),
                  );
                }
              });
            }
            // API 성공 시에는 _performComparison에서 이미 화면 이동이 처리됨
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

  Future<String?> _performComparisonWithErrorHandling() async {
    try {
      await _performComparison();
      return null; // 성공한 경우 에러 메시지 없음
    } catch (e) {
      // Vision API 에러 확인
      if (e.toString().contains('VISION_API_ERROR')) {
        return AppLocalizations.of(context)!.vision_api_error;
      }
      return AppLocalizations.of(context)!.analysis_failed;
    }
  }

  Future<void> _performComparison() async {
    // 현재 로케일에서 언어 코드 가져오기
    final langCode = Localizations.localeOf(context).languageCode;

    // 선호도 설정 가져오기
    Map<String, List<String>>? profileData;
    Map<String, List<String>>? babyData;
    Map<String, List<String>>? petData;

    if (_selectedPreference != 'none') {
      final userPreferenceService = UserPreferenceService();
      final allPreferences = await userPreferenceService.getAllPreferences();

      if (_selectedPreference == 'baby') {
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

        // 빈 리스트는 제거
        babyData.removeWhere((key, value) => value.isEmpty);
        if (babyData.isEmpty) babyData = null;
      } else if (_selectedPreference == 'pet') {
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

        // 빈 리스트는 제거
        petData.removeWhere((key, value) => value.isEmpty);
        if (petData.isEmpty) petData = null;
      } else if (_selectedPreference == 'user') {
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

        // 빈 리스트는 제거
        profileData.removeWhere((key, value) => value.isEmpty);
        if (profileData.isEmpty) profileData = null;
      }
    }

    if (kDebugMode) {
      print('🚀 비교 API 호출 전 최종 데이터:');
      print('   - _selectedPreference: $_selectedPreference');
      print('   - profileData: $profileData');
      print('   - babyData: $babyData');
      print('   - petData: $petData');
    }

    // 실제 API 호출
    final result = await ApiService.compareIngredients(
      imageA: _imageA!,
      imageB: _imageB!,
      category: widget.category,
      langCode: langCode,
      profile: profileData,
      baby: babyData,
      pet: petData,
    );

    // 취소되지 않았을 때만 결과 화면으로 이동
    if (mounted && !_isAnalysisCancelled) {
      // Analytics: 비교 분석 완료 이벤트
      await AnalyticsService.logComparisonCompleted(
        category: widget.category,
        preferenceType: _selectedPreference,
      );

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
  }

  Widget _buildProductCard(String title, File? image, bool isProductA) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: image == null ? () => _selectImage(isProductA) : null,
          child: Container(
            height: 180,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: image != null
                    ? AppTheme.primaryTextColor
                    : AppTheme.gray300,
                width: image != null ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                // 이미지 또는 빈 상태
                image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
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
                              AppLocalizations.of(context)!.tap_to_add,
                              style: const TextStyle(
                                color: AppTheme.gray500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                // X 버튼 (이미지가 있을 때만 표시)
                if (image != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isProductA) {
                            _imageA = null;
                          } else {
                            _imageB = null;
                          }
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(60, 0, 0, 0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
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
          AppLocalizations.of(context)!.compare,
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: AppTheme.appBarTitleFontSize,
            fontWeight: AppTheme.appBarTitleFontWeight,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // 투명한 상태바
          statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상
          statusBarBrightness: Brightness.light, // iOS용 상태바 밝기
          systemNavigationBarColor: Colors.transparent, // 투명한 네비게이션 바
          systemNavigationBarIconBrightness: Brightness.dark, // 네비게이션 바 아이콘 색상
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
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Category indicator
                    Center(
                      child: Container(
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
                          AppLocalizations.of(context)!.category_label(
                              CategoryTranslationUtil
                                  .getTranslatedCategoryOrSubcategory(
                                      context, widget.category)),
                          style: const TextStyle(
                            color: AppTheme.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Product cards in 2 columns
                    Row(
                      children: [
                        Expanded(
                          child: _buildProductCard(
                            AppLocalizations.of(context)!.product_a,
                            _imageA,
                            true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildProductCard(
                            AppLocalizations.of(context)!.product_b,
                            _imageB,
                            false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Instruction message
                    Text(
                      AppLocalizations.of(context)!.compare_instruction,
                      style: const TextStyle(
                        color: AppTheme.gray500,
                        fontSize: 14,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // 프로필 설정 위젯
                    _isBabyOrPetCategory(widget.category)
                        ? ProfilePreferenceWidget(
                            category: widget.category,
                            applyProfile: _selectedPreference != 'none',
                            onProfileToggled: (value) {
                              setState(() {
                                if (_isBabyCategory(widget.category)) {
                                  _selectedPreference = value ? 'baby' : 'none';
                                } else {
                                  _selectedPreference = value ? 'pet' : 'none';
                                }
                              });
                              // 선택 상태 저장
                              PreferencesService.instance
                                  .setCategoryPreferenceSelection(
                                      widget.category, _selectedPreference);
                            },
                          )
                        : MultiProfilePreferenceWidget(
                            selectedPreference: _selectedPreference,
                            onPreferenceChanged: (preference) {
                              setState(() {
                                _selectedPreference = preference;
                              });
                              // 선택 상태 저장
                              PreferencesService.instance
                                  .setCategoryPreferenceSelection(
                                      widget.category, preference);
                            },
                          ),

                    const SizedBox(height: 16),

                    // Compare button
                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      child: ElevatedButton(
                        onPressed: (_imageA != null && _imageB != null)
                            ? _compareProducts
                            : null,
                        style: (_imageA == null || _imageB == null)
                            ? AppTheme.getButtonStyle('disabled')
                            : AppTheme.getButtonStyle('action'),
                        child: Text(
                          AppLocalizations.of(context)!.compare_ingredients,
                          style: AppTheme.getButtonTextStyle(),
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
