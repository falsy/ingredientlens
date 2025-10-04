import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../services/usage_limit_service.dart';
import '../services/user_preference_service.dart';
import '../services/preferences_service.dart';
import '../services/analytics_service.dart';
import '../widgets/interstitial_ad_widget.dart';
import '../widgets/profile_preference_widget.dart';
import 'nutrition_result_screen.dart';

class NutritionImageCropScreen extends StatefulWidget {
  final String imagePath;
  final String category;

  const NutritionImageCropScreen({
    super.key,
    required this.imagePath,
    required this.category,
  });

  @override
  State<NutritionImageCropScreen> createState() =>
      _NutritionImageCropScreenState();
}

class _NutritionImageCropScreenState extends State<NutritionImageCropScreen> {
  final GlobalKey _imageKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  // 크롭 박스 상태
  Rect _cropRect = Rect.zero;
  String? _activeHandle; // 현재 활성화된 핸들 ('tl', 'tr', 'bl', 'br', 'move', null)
  Offset _dragStartOffset = Offset.zero;
  Rect _dragStartRect = Rect.zero;

  Size? _imageSize;
  Size? _containerSize;
  bool _isProcessing = false;
  double _rotationAngle = 0.0;
  bool _isAnalysisCancelled = false;
  String _selectedPreference = 'user';

  static const double _handleSize = 24.0;
  static const double _minCropSize = 30.0;

  @override
  void initState() {
    super.initState();
    // 영양 분석에서는 기본적으로 사용자 정보 반영
    _selectedPreference = 'user';
    _loadImageSize();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImageSize() async {
    final File imageFile = File(widget.imagePath);
    final bytes = await imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);
    setState(() {
      _imageSize = Size(image.width.toDouble(), image.height.toDouble());
    });
  }

  void _initializeCropRect() {
    if (_containerSize == null) return;

    // 초기 크롭 박스를 컨테이너의 70% 크기로 중앙에 배치
    final initialSize = _containerSize!.width * 0.7;
    final left = (_containerSize!.width - initialSize) / 2;
    final top = (_containerSize!.height - initialSize) / 2;

    setState(() {
      _cropRect = Rect.fromLTWH(left, top, initialSize, initialSize);
    });
  }

  void _onPanStart(DragStartDetails details, String handle) {
    setState(() {
      _activeHandle = handle;
      _dragStartOffset = details.globalPosition;
      _dragStartRect = _cropRect;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeHandle == null || _containerSize == null) return;

    final delta = details.globalPosition - _dragStartOffset;
    Rect newRect = _dragStartRect;

    switch (_activeHandle) {
      case 'move':
        // 크롭 박스 이동
        newRect = _dragStartRect.translate(delta.dx, delta.dy);
        // 컨테이너 범위 내로 제한
        if (newRect.left < 0) {
          newRect = newRect.translate(-newRect.left, 0);
        }
        if (newRect.top < 0) {
          newRect = newRect.translate(0, -newRect.top);
        }
        if (newRect.right > _containerSize!.width) {
          newRect = newRect.translate(_containerSize!.width - newRect.right, 0);
        }
        if (newRect.bottom > _containerSize!.height) {
          newRect =
              newRect.translate(0, _containerSize!.height - newRect.bottom);
        }
        break;

      case 'tl': // Top-left handle
        final newLeft = (_dragStartRect.left + delta.dx)
            .clamp(0.0, _dragStartRect.right - _minCropSize);
        final newTop = (_dragStartRect.top + delta.dy)
            .clamp(0.0, _dragStartRect.bottom - _minCropSize);
        newRect = Rect.fromLTRB(
            newLeft, newTop, _dragStartRect.right, _dragStartRect.bottom);
        break;

      case 'tr': // Top-right handle
        final newRight = (_dragStartRect.right + delta.dx)
            .clamp(_dragStartRect.left + _minCropSize, _containerSize!.width);
        final newTop = (_dragStartRect.top + delta.dy)
            .clamp(0.0, _dragStartRect.bottom - _minCropSize);
        newRect = Rect.fromLTRB(
            _dragStartRect.left, newTop, newRight, _dragStartRect.bottom);
        break;

      case 'bl': // Bottom-left handle
        final newLeft = (_dragStartRect.left + delta.dx)
            .clamp(0.0, _dragStartRect.right - _minCropSize);
        final newBottom = (_dragStartRect.bottom + delta.dy)
            .clamp(_dragStartRect.top + _minCropSize, _containerSize!.height);
        newRect = Rect.fromLTRB(
            newLeft, _dragStartRect.top, _dragStartRect.right, newBottom);
        break;

      case 'br': // Bottom-right handle
        final newRight = (_dragStartRect.right + delta.dx)
            .clamp(_dragStartRect.left + _minCropSize, _containerSize!.width);
        final newBottom = (_dragStartRect.bottom + delta.dy)
            .clamp(_dragStartRect.top + _minCropSize, _containerSize!.height);
        newRect = Rect.fromLTRB(
            _dragStartRect.left, _dragStartRect.top, newRight, newBottom);
        break;
    }

    setState(() {
      _cropRect = newRect;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _activeHandle = null;
    });
  }

  Widget _buildHandle(String position) {
    return GestureDetector(
      onPanStart: (details) => _onPanStart(details, position),
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: _handleSize,
        height: _handleSize,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cropAndSave() async {
    if (_imageSize == null || _containerSize == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 이미지 파일 읽기
      final imageFile = File(widget.imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        // 현재 변환 매트릭스 가져오기
        final Matrix4 transformation = _transformationController.value;

        // 컨테이너 내에서 이미지가 실제로 차지하는 영역 계산
        final containerAspectRatio =
            _containerSize!.width / _containerSize!.height;
        final imageAspectRatio = _imageSize!.width / _imageSize!.height;

        late double imageLeft, imageTop, imageWidth, imageHeight;

        if (imageAspectRatio > containerAspectRatio) {
          // 이미지가 더 가로로 길면, 좌우 꽉 채우고 상하에 여백
          imageLeft = 0;
          imageWidth = _containerSize!.width;
          imageHeight = _containerSize!.width / imageAspectRatio;
          imageTop = (_containerSize!.height - imageHeight) / 2;
        } else {
          // 이미지가 더 세로로 길면, 상하 꽉 채우고 좌우에 여백
          imageTop = 0;
          imageHeight = _containerSize!.height;
          imageWidth = _containerSize!.height * imageAspectRatio;
          imageLeft = (_containerSize!.width - imageWidth) / 2;
        }

        // 변환 매트릭스의 역행렬을 사용하여 크롭 영역을 원본 좌표계로 변환
        final Matrix4 inverse = Matrix4.inverted(transformation);

        // 크롭 박스의 네 모서리를 변환
        final vector.Vector3 topLeft = inverse
            .transform3(vector.Vector3(_cropRect.left, _cropRect.top, 0));
        final vector.Vector3 bottomRight = inverse
            .transform3(vector.Vector3(_cropRect.right, _cropRect.bottom, 0));

        // 변환된 크롭 영역
        final transformedCropRect = Rect.fromLTRB(
          topLeft.x,
          topLeft.y,
          bottomRight.x,
          bottomRight.y,
        );

        // 크롭 영역과 이미지 영역의 교집합 계산
        final imageRect =
            Rect.fromLTWH(imageLeft, imageTop, imageWidth, imageHeight);
        final intersection = transformedCropRect.intersect(imageRect);

        if (intersection.isEmpty) {
          // 크롭 영역이 이미지와 겹치지 않음
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.crop_area_required),
              backgroundColor: AppTheme.alertColor,
            ),
          );
          setState(() {
            _isProcessing = false;
          });
          return;
        }

        // 교집합 영역을 이미지 내 비율로 변환
        final cropLeftRatio = (intersection.left - imageLeft) / imageWidth;
        final cropTopRatio = (intersection.top - imageTop) / imageHeight;
        final cropWidthRatio = intersection.width / imageWidth;
        final cropHeightRatio = intersection.height / imageHeight;

        // 실제 이미지 픽셀 좌표로 변환
        final cropX =
            (cropLeftRatio * image.width).round().clamp(0, image.width);
        final cropY =
            (cropTopRatio * image.height).round().clamp(0, image.height);
        final cropWidth = (cropWidthRatio * image.width)
            .round()
            .clamp(1, image.width - cropX);
        final cropHeight = (cropHeightRatio * image.height)
            .round()
            .clamp(1, image.height - cropY);

        // 먼저 크롭 후 회전 적용
        final croppedImage = img.copyCrop(
          image,
          x: cropX,
          y: cropY,
          width: cropWidth,
          height: cropHeight,
        );

        // 회전 적용
        img.Image finalImage = croppedImage;
        if (_rotationAngle != 0.0) {
          finalImage = img.copyRotate(croppedImage, angle: _rotationAngle);
        }

        // 임시 파일로 저장
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/nutrition_cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(img.encodeJpg(finalImage, quality: 85));

        if (mounted) {
          _showPreviewDialog(tempFile);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showPreviewDialog(File imageFile) {
    _showPreviewBottomSheet(imageFile);
  }

  void _showPreviewBottomSheet(File imageFile) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.gray300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(imageFile, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.cardBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirm_analysis_notice,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 영양 분석에서는 사용자 정보만 반영 가능
                  ProfilePreferenceWidget(
                    category: widget.category,
                    applyProfile: _selectedPreference != 'none',
                    onProfileToggled: (value) {
                      setModalState(() {
                        _selectedPreference = value ? 'user' : 'none';
                      });
                      PreferencesService.instance
                          .setCategoryPreferenceSelection(
                              widget.category, _selectedPreference);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: AppTheme.getButtonStyle('cancel'),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: AppTheme.getButtonTextStyle(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _startNutritionAnalysis(imageFile);
                          },
                          style: AppTheme.getButtonStyle('action'),
                          child: Text(
                            AppLocalizations.of(context)!.analyze,
                            style: AppTheme.getButtonTextStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startNutritionAnalysis(File imageFile) async {
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

    _isAnalysisCancelled = false;
    await usageLimitService.incrementUsage();
    final analysisResult =
        _performNutritionAnalysisWithErrorHandling(imageFile);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterstitialAdWidget(
          onAdDismissed: () async {
            final errorMsg = await analysisResult;
            if (errorMsg != null && mounted) {
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
          },
          onAnalysisCancelled: () {
            _isAnalysisCancelled = true;
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<String?> _performNutritionAnalysisWithErrorHandling(
      File imageFile) async {
    try {
      await _performNutritionAnalysis(imageFile);
      return null;
    } catch (e) {
      if (e.toString().contains('NUTRITION_NOT_FOUND')) {
        return AppLocalizations.of(context)!.nutrition_not_found;
      }
      return AppLocalizations.of(context)!.analysis_failed;
    }
  }

  Future<void> _performNutritionAnalysis(File imageFile) async {
    final langCode = Localizations.localeOf(context).languageCode;

    Map<String, List<String>>? profileData;

    // 영양 분석에서는 사용자 정보만 반영
    if (_selectedPreference == 'user') {
      final userPreferenceService = UserPreferenceService();
      final allPreferences = await userPreferenceService.getAllPreferences();

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

    // 영양 분석 API 호출 (baby, pet 데이터는 null)
    final result = await ApiService.analyzeNutrition(
      imageFile: imageFile,
      category: widget.category,
      langCode: langCode,
      profile: profileData,
      baby: null,
      pet: null,
    );

    if (mounted && !_isAnalysisCancelled) {
      // Analytics: 영양 분석 완료 이벤트
      // 경고와 이점 카운트 계산
      int warningCount = 0;
      int benefitCount = 0;
      
      if (result['warnings'] != null && result['warnings'] is List) {
        warningCount = (result['warnings'] as List).length;
      }
      if (result['benefits'] != null && result['benefits'] is List) {
        benefitCount = (result['benefits'] as List).length;
      }
      
      await AnalyticsService.logNutritionAnalysisCompleted(
        category: widget.category,
        preferenceType: _selectedPreference,
        warningCount: warningCount,
        benefitCount: benefitCount,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionResultScreen(
            nutritionResult: result,
            category: widget.category,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.crop_image,
            style: const TextStyle(
              color: AppTheme.blackColor,
              fontSize: AppTheme.appBarTitleFontSize,
              fontWeight: AppTheme.appBarTitleFontWeight,
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _containerSize =
                          Size(constraints.maxWidth, constraints.maxHeight);

                      // 크롭 박스가 아직 초기화되지 않았다면 초기화
                      if (_cropRect == Rect.zero) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _initializeCropRect();
                        });
                      }

                      return Stack(
                        children: [
                          // 이미지
                          Positioned.fill(
                            child: Container(
                              key: _imageKey,
                              decoration: BoxDecoration(
                                color: AppTheme.gray100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.cardBorderColor,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: InteractiveViewer(
                                  transformationController:
                                      _transformationController,
                                  minScale: 0.5,
                                  maxScale: 5.0,
                                  panEnabled: true,
                                  scaleEnabled: true,
                                  child: Transform.rotate(
                                    angle: _rotationAngle *
                                        (3.141592653589793 / 180),
                                    child: Image.file(
                                      File(widget.imagePath),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 오버레이 (크롭 영역 외부를 어둡게)
                          if (_cropRect != Rect.zero)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: CropOverlayPainter(
                                    cropRect: _cropRect,
                                    containerSize: _containerSize!,
                                  ),
                                ),
                              ),
                            ),

                          // 크롭 박스와 핸들
                          if (_cropRect != Rect.zero) ...[
                            // 크롭 박스 테두리만 표시 (내부는 터치 통과)
                            Positioned(
                              left: _cropRect.left,
                              top: _cropRect.top,
                              width: _cropRect.width,
                              height: _cropRect.height,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 크롭 박스 테두리에만 터치 영역 추가
                            // 상단 테두리
                            Positioned(
                              left: _cropRect.left,
                              top: _cropRect.top - 10,
                              width: _cropRect.width,
                              height: 20,
                              child: GestureDetector(
                                onPanStart: (details) =>
                                    _onPanStart(details, 'move'),
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: Container(color: Colors.transparent),
                              ),
                            ),
                            // 하단 테두리
                            Positioned(
                              left: _cropRect.left,
                              top: _cropRect.bottom - 10,
                              width: _cropRect.width,
                              height: 20,
                              child: GestureDetector(
                                onPanStart: (details) =>
                                    _onPanStart(details, 'move'),
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: Container(color: Colors.transparent),
                              ),
                            ),
                            // 좌측 테두리
                            Positioned(
                              left: _cropRect.left - 10,
                              top: _cropRect.top,
                              width: 20,
                              height: _cropRect.height,
                              child: GestureDetector(
                                onPanStart: (details) =>
                                    _onPanStart(details, 'move'),
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: Container(color: Colors.transparent),
                              ),
                            ),
                            // 우측 테두리
                            Positioned(
                              left: _cropRect.right - 10,
                              top: _cropRect.top,
                              width: 20,
                              height: _cropRect.height,
                              child: GestureDetector(
                                onPanStart: (details) =>
                                    _onPanStart(details, 'move'),
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: Container(color: Colors.transparent),
                              ),
                            ),

                            // 리사이즈 핸들들
                            // Top-left
                            Positioned(
                              left: _cropRect.left - _handleSize / 2,
                              top: _cropRect.top - _handleSize / 2,
                              child: _buildHandle('tl'),
                            ),
                            // Top-right
                            Positioned(
                              left: _cropRect.right - _handleSize / 2,
                              top: _cropRect.top - _handleSize / 2,
                              child: _buildHandle('tr'),
                            ),
                            // Bottom-left
                            Positioned(
                              left: _cropRect.left - _handleSize / 2,
                              top: _cropRect.bottom - _handleSize / 2,
                              child: _buildHandle('bl'),
                            ),
                            // Bottom-right
                            Positioned(
                              left: _cropRect.right - _handleSize / 2,
                              top: _cropRect.bottom - _handleSize / 2,
                              child: _buildHandle('br'),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),

              // 회전 슬라이더
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.rotate,
                          style: TextStyle(
                            color: AppTheme.blackColor,
                            fontSize: AppTheme.adjustFontSizeForPlatform(14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_rotationAngle.round()}°',
                          style: TextStyle(
                            color: AppTheme.gray600,
                            fontSize: AppTheme.adjustFontSizeForPlatform(14),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.blackColor,
                        inactiveTrackColor: AppTheme.gray300,
                        thumbColor: AppTheme.blackColor,
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _rotationAngle,
                        min: -45,
                        max: 45,
                        divisions: 90,
                        onChanged: (value) {
                          setState(() {
                            _rotationAngle = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 안내 메시지
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.cardBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!
                            .nutrition_crop_instruction,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      top: -10,
                      right: -5,
                      child: Transform.rotate(
                        angle:
                            0.2617993877991494, // 15도를 라디안으로 변환 (15 * π / 180)
                        child: Image.asset(
                          'assets/images/alert.webp',
                          width: 38,
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 확인 버튼
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: AppTheme.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_isProcessing) {
                        _cropAndSave();
                      }
                    },
                    style: AppTheme.getButtonStyle('action'),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppTheme.whiteColor,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.done,
                            style: AppTheme.getButtonTextStyle(),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 크롭 오버레이 페인터
class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Size containerSize;

  CropOverlayPainter({
    required this.cropRect,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // 둥근 모서리 클리핑 적용
    final containerRect =
        Rect.fromLTWH(0, 0, containerSize.width, containerSize.height);
    final containerPath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(containerRect, const Radius.circular(16)));

    canvas.clipPath(containerPath);

    // 전체 영역에서 크롭 영역을 제외한 부분을 그리기
    final path = Path()
      ..addRect(containerRect)
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return cropRect != oldDelegate.cropRect;
  }
}
