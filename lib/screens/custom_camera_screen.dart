import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import 'image_crop_screen.dart';

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

  @override
  void initState() {
    super.initState();
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
        
        // 자동 포커스 모드 설정
        try {
          await _controller!.setFocusMode(FocusMode.auto);
          if (kDebugMode) print('Auto focus mode set');
        } catch (e) {
          if (kDebugMode) print('Error setting focus mode: $e');
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

      // 포커스 포인트 설정
      await _controller!.setFocusPoint(normalizedPoint);
      await _controller!.setExposurePoint(normalizedPoint);

      // 터치 위치 표시를 위해 상태 업데이트
      setState(() {
        _focusPoint = details.localPosition;
      });

      // 2초 후 포커스 인디케이터 숨기기
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _focusPoint = null;
          });
        }
      });

      if (kDebugMode) {
        print('Focus set to: ${normalizedPoint.dx}, ${normalizedPoint.dy}');
      }
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
    // 바로 크롭 화면으로 이동
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
    return;
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
                    onTapDown: (details) => _onTapToFocus(details, constraints.biggest),
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
                          AppLocalizations.of(context)!
                              .translate('take_photo')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
            Positioned(
              bottom: 140,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: AppLocalizations.of(context)!
                        .translate('photo_instruction'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3, // 줄 간격
                    ),
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuidelinePainter extends CustomPainter {
  final bool isHorizontal;

  const GuidelinePainter({required this.isHorizontal});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);

    // 가이드라인 영역 계산
    final double guideWidth, guideHeight;

    if (isHorizontal) {
      // 가로 가이드: 너비 80%, 높이는 너비의 70%
      guideWidth = size.width * 0.8;
      guideHeight = guideWidth * 0.7;
    } else {
      // 세로 가이드: 너비 60%, 높이는 너비의 140%
      guideWidth = size.width * 0.6;
      guideHeight = guideWidth * 1.4;
    }

    final double startX = (size.width - guideWidth) / 2;
    final double startY = (size.height - guideHeight) / 2;

    final Rect guideRect =
        Rect.fromLTWH(startX, startY, guideWidth, guideHeight);

    // 가이드라인 외부 영역을 어둡게
    final Path outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path innerPath = Path()..addRect(guideRect);
    final Path overlayPath =
        Path.combine(PathOperation.difference, outerPath, innerPath);

    canvas.drawPath(overlayPath, overlayPaint);

    // 가이드라인 사각형 그리기
    canvas.drawRect(guideRect, paint);

    // 모서리 표시 (더 명확한 가이드를 위해)
    final double cornerLength = 20;
    final Paint cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // 좌상단
    canvas.drawLine(Offset(startX, startY),
        Offset(startX + cornerLength, startY), cornerPaint);
    canvas.drawLine(Offset(startX, startY),
        Offset(startX, startY + cornerLength), cornerPaint);

    // 우상단
    canvas.drawLine(Offset(startX + guideWidth, startY),
        Offset(startX + guideWidth - cornerLength, startY), cornerPaint);
    canvas.drawLine(Offset(startX + guideWidth, startY),
        Offset(startX + guideWidth, startY + cornerLength), cornerPaint);

    // 좌하단
    canvas.drawLine(Offset(startX, startY + guideHeight),
        Offset(startX + cornerLength, startY + guideHeight), cornerPaint);
    canvas.drawLine(Offset(startX, startY + guideHeight),
        Offset(startX, startY + guideHeight - cornerLength), cornerPaint);

    // 우하단
    canvas.drawLine(
        Offset(startX + guideWidth, startY + guideHeight),
        Offset(startX + guideWidth - cornerLength, startY + guideHeight),
        cornerPaint);
    canvas.drawLine(
        Offset(startX + guideWidth, startY + guideHeight),
        Offset(startX + guideWidth, startY + guideHeight - cornerLength),
        cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
