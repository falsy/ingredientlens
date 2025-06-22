import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/api_service.dart';
import '../widgets/interstitial_ad_widget.dart';
import 'image_crop_screen.dart';
import '../screens/analysis_result_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    // 카메라 화면에서는 상태바와 네비게이션 바를 검정색으로 설정 (지연 실행으로 확실히 적용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    });
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
              content: Text('No cameras available on this device (iOS Simulator)'),
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
    // 카메라 화면을 나갈 때 상태바와 네비게이션 바를 원래대로 복원
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
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
    
    // 다이얼로그 표시 전에 상태바와 네비게이션 바를 검정으로 변경
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // 다이얼로그가 닫힐 때 카메라 화면 색상으로 복원
            SystemChrome.setSystemUIOverlayStyle(
              const SystemUiOverlayStyle(
                statusBarColor: Colors.black,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.black,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
            );
            return true;
          },
          child: AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          title: Text(
            AppLocalizations.of(context)!.translate('photo_taken'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.gray300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.gray100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.gray300),
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('confirm_analysis_notice'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 카메라 화면 색상으로 복원 후 다이얼로그 닫기
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                    statusBarColor: Colors.black,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.black,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                );
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text(
                AppLocalizations.of(context)!.translate('cancel'),
                style: TextStyle(
                  color: AppTheme.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // 카메라 화면 색상으로 복원 후 다이얼로그 닫기
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                    statusBarColor: Colors.black,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.black,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                );
                Navigator.pop(context); // 다이얼로그 닫기
                
                if (widget.isCompareMode) {
                  // 비교 모드에서는 이미지 크롭 화면으로 이동
                  Navigator.push(
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
                } else {
                  // 일반 모드에서는 기존대로 분석 시작
                  _startAnalysis(imageFile);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.translate('confirm'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          ),
        );
      },
    );
  }

  void _startAnalysis(File imageFile) {
    // 분석 시작 시 취소 플래그 초기화
    _isAnalysisCancelled = false;
    
    // API 호출을 먼저 시작
    _performAnalysis(imageFile);
    
    // 전면 광고 표시 (API는 이미 시작됨)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterstitialAdWidget(
          onAdDismissed: () {
            // 광고가 끝났을 때는 아무것도 하지 않음 (API는 이미 진행 중)
            if (kDebugMode) print('Ad finished, API should already be running');
          },
          onAnalysisCancelled: () {
            // 분석 취소 플래그 설정
            _isAnalysisCancelled = true;
            // 분석 취소 시 이전 화면으로 돌아가기
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  bool _isAnalysisCancelled = false;

  void _performAnalysis(File imageFile) async {
    try {
      // 현재 로케일에서 언어 코드 가져오기
      final langCode = Localizations.localeOf(context).languageCode;
      
      if (kDebugMode) print('Starting API analysis...');
      if (kDebugMode) print('Language: $langCode, Category: ${widget.category}');
      
      // 실제 API 호출
      final result = await ApiService.analyzeIngredients(
        imageFile: imageFile,
        category: widget.category,
        langCode: langCode,
      );
      
      // 취소되지 않았을 때만 결과 화면으로 이동
      if (mounted && !_isAnalysisCancelled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(analysisResult: result),
          ),
        );
      }
    } catch (e) {
      // 에러 처리 (취소되지 않았을 때만)
      if (kDebugMode) print('Analysis error: $e');
      if (mounted && !_isAnalysisCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('analysis_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
        Navigator.pop(context); // 광고 화면 닫기
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 카메라 프리뷰
          Positioned.fill(
            child: CameraPreview(_controller!),
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
                        AppLocalizations.of(context)!.translate('take_photo').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: AppLocalizations.of(context)!.translate('photo_instruction'),
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

    final Paint overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);

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

    final Rect guideRect = Rect.fromLTWH(startX, startY, guideWidth, guideHeight);

    // 가이드라인 외부 영역을 어둡게
    final Path outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path innerPath = Path()..addRect(guideRect);
    final Path overlayPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    
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
    canvas.drawLine(Offset(startX, startY), Offset(startX + cornerLength, startY), cornerPaint);
    canvas.drawLine(Offset(startX, startY), Offset(startX, startY + cornerLength), cornerPaint);

    // 우상단
    canvas.drawLine(Offset(startX + guideWidth, startY), Offset(startX + guideWidth - cornerLength, startY), cornerPaint);
    canvas.drawLine(Offset(startX + guideWidth, startY), Offset(startX + guideWidth, startY + cornerLength), cornerPaint);

    // 좌하단
    canvas.drawLine(Offset(startX, startY + guideHeight), Offset(startX + cornerLength, startY + guideHeight), cornerPaint);
    canvas.drawLine(Offset(startX, startY + guideHeight), Offset(startX, startY + guideHeight - cornerLength), cornerPaint);

    // 우하단
    canvas.drawLine(Offset(startX + guideWidth, startY + guideHeight), Offset(startX + guideWidth - cornerLength, startY + guideHeight), cornerPaint);
    canvas.drawLine(Offset(startX + guideWidth, startY + guideHeight), Offset(startX + guideWidth, startY + guideHeight - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}