import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:ingredient_lens/l10n/app_localizations.dart';
import 'dart:io';
import 'dart:async';
import '../utils/theme.dart';
import 'image_crop_screen.dart';
import 'nutrition_image_crop_screen.dart';

class CustomCameraScreen extends StatefulWidget {
  final String category;
  final bool isCompareMode;
  final Function(File)? onImageSelected;

  const CustomCameraScreen({
    super.key,
    required this.category,
    this.isCompareMode = false,
    this.onImageSelected,
  });

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  Offset? _focusPoint;
  Timer? _focusResetTimer;
  Timer? _focusIndicatorTimer;

  @override
  void initState() {
    super.initState();
    // 가로모드 허용
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (kDebugMode) print('Available cameras: ${_cameras?.length}');

      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();

        // 카메라 포커스 및 노출 설정
        try {
          await _controller!.setFocusMode(FocusMode.auto);
          await _controller!.setExposureMode(ExposureMode.auto);

          if (kDebugMode) {
            print('Auto focus mode set');
            print('Auto exposure mode set');
          }
        } catch (e) {
          if (kDebugMode) print('Error setting focus/exposure mode: $e');
        }

        if (kDebugMode) print('Camera initialized successfully');

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        if (kDebugMode) print('No cameras available');
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('No cameras available on this device (iOS Simulator)'),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera initialization failed: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // 세로모드로 되돌리기
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _focusResetTimer?.cancel();
    _focusIndicatorTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile picture = await _controller!.takePicture();

      // 촬영된 이미지를 가이드라인 영역으로 크롭
      final File croppedImage = await _cropImageToGuide(File(picture.path));

      if (mounted) {
        _showPreviewDialog(croppedImage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사진 촬영 중 오류가 발생했습니다: $e'),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _onTapToFocus(TapDownDetails details, Size size) async {
    if (_controller?.value.isInitialized != true) return;

    try {
      // 화면 좌표를 카메라 좌표계로 변환 (0.0 ~ 1.0)
      final Offset normalizedPoint = Offset(
        details.localPosition.dx / size.width,
        details.localPosition.dy / size.height,
      );

      if (kDebugMode) {
        print(
            'Touch position: ${details.localPosition.dx}, ${details.localPosition.dy}');
        print('Screen size: ${size.width} x ${size.height}');
        print('Normalized point: ${normalizedPoint.dx}, ${normalizedPoint.dy}');
      }

      // 터치 위치 표시를 위해 상태 업데이트 (먼저 표시)
      setState(() {
        _focusPoint = details.localPosition;
      });

      // 방법 3: 포커스 모드를 locked로 설정하고 유지
      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setExposureMode(ExposureMode.locked);
      await Future.delayed(const Duration(milliseconds: 50));

      // 포커스 포인트 설정
      await _controller!.setFocusPoint(normalizedPoint);
      await _controller!.setExposurePoint(normalizedPoint);

      if (kDebugMode) {
        print('Focus locked at: ${normalizedPoint.dx}, ${normalizedPoint.dy}');
      }

      // 기존 타이머들 취소
      _focusResetTimer?.cancel();
      _focusIndicatorTimer?.cancel();

      // 1초 후 포커스 인디케이터 숨기기
      _focusIndicatorTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _focusPoint = null;
          });
        }
      });

      // 10초 후 자동 포커스 모드로 복원
      _focusResetTimer = Timer(const Duration(seconds: 10), () async {
        if (mounted && _controller?.value.isInitialized == true) {
          try {
            await _controller!.setFocusMode(FocusMode.auto);
            await _controller!.setExposureMode(ExposureMode.auto);
            if (kDebugMode) {
              print('Focus mode reset to auto');
            }
          } catch (e) {
            if (kDebugMode) print('Error resetting focus mode: $e');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) print('Error setting focus: $e');
    }
  }

  Future<File> _cropImageToGuide(File imageFile) async {
    // 이미지 로드
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      return imageFile;
    }

    // 화면 크기와 가이드라인 비율 계산
    // 원본 이미지 사용 (크롭 화면에서 편집할 예정)
    if (kDebugMode) print('Original image captured, moving to crop screen');

    return imageFile;
  }

  void _showPreviewDialog(File imageFile) {
    // 칼로리 카테고리인 경우 바로 콜백 호출
    if (widget.category == 'calorie') {
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(imageFile);
      }
      return;
    }

    // 영양 분석인 경우 영양 크롭 화면으로 이동
    const nutritionCategoryIds = ['processed_food', 'dessert', 'beverages'];
    if (nutritionCategoryIds.contains(widget.category)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionImageCropScreen(
            imagePath: imageFile.path,
            category: widget.category,
          ),
        ),
      );
      return;
    }

    // 다른 카테고리는 성분 분석 크롭 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropScreen(
          imagePath: imageFile.path,
          category: widget.category,
          isCompareMode: widget.isCompareMode,
          onImageSelected: widget.onImageSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 카메라 프리뷰
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTapDown: (details) =>
                        _onTapToFocus(details, constraints.biggest),
                    child: CameraPreview(_controller!),
                  );
                },
              ),
            ),

            // 포커스 인디케이터
            if (_focusPoint != null)
              Positioned(
                left: _focusPoint!.dx - 40,
                top: _focusPoint!.dy - 40,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 1.2, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.yellow,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.center_focus_strong,
                          color: Colors.yellow,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // 상단 툴바
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    children: [
                      // 가운데 정렬된 타이틀
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.take_photo,
                          style: const TextStyle(
                            color: AppTheme.whiteColor,
                            fontSize: AppTheme.appBarTitleFontSize,
                            fontWeight: AppTheme.appBarTitleFontWeight,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      // 오른쪽에 배치된 X 버튼
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 촬영 버튼
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _isCapturing ? null : _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isCapturing ? Colors.grey : Colors.white,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: _isCapturing
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 3,
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 32,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 가이드 텍스트
            // Positioned(
            //   bottom: 140,
            //   left: 20,
            //   right: 20,
            //   child: Container(
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.6),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: RichText(
            //       textAlign: TextAlign.center,
            //       text: TextSpan(
            //         text: AppLocalizations.of(context)!.photo_instruction,
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 14,
            //           fontWeight: FontWeight.w500,
            //           height: 1.3, // 줄 간격
            //         ),
            //       ),
            //       softWrap: true,
            //       overflow: TextOverflow.visible,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
