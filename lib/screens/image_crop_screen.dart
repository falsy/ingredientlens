import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:image/image.dart' as img;
import '../utils/theme.dart';
import '../services/localization_service.dart';
import 'transparent_overlay_screen.dart';

class ImageCropScreen extends StatefulWidget {
  final String imagePath;
  final String category;
  final bool isCompareMode;
  final Function(File)? onImageSelected;

  const ImageCropScreen({
    super.key,
    required this.imagePath,
    required this.category,
    this.isCompareMode = false,
    this.onImageSelected,
  });

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final GlobalKey _imageKey = GlobalKey();
  Offset _startPoint = const Offset(0, 0);
  Offset _endPoint = const Offset(1, 1);
  bool _isDragging = false;
  Size? _imageSize;
  bool _isProcessing = false;
  Rect? _imageRect;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final File imageFile = File(widget.imagePath);
    final bytes = await imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);
    setState(() {
      _imageSize = Size(image.width.toDouble(), image.height.toDouble());
      // 처음에는 크롭 영역을 보이지 않게 설정
      _startPoint = const Offset(0, 0);
      _endPoint = const Offset(0, 0);
    });
  }

  Rect get _cropRect {
    final minX = _startPoint.dx < _endPoint.dx ? _startPoint.dx : _endPoint.dx;
    final minY = _startPoint.dy < _endPoint.dy ? _startPoint.dy : _endPoint.dy;
    final maxX = _startPoint.dx > _endPoint.dx ? _startPoint.dx : _endPoint.dx;
    final maxY = _startPoint.dy > _endPoint.dy ? _startPoint.dy : _endPoint.dy;
    
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    final RenderBox renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      _isDragging = true;
      _startPoint = _clampToImageBounds(Offset(
        localPosition.dx / renderBox.size.width,
        localPosition.dy / renderBox.size.height,
      ), renderBox.size);
      _endPoint = _startPoint;
    });
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final RenderBox renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      _endPoint = _clampToImageBounds(Offset(
        localPosition.dx / renderBox.size.width,
        localPosition.dy / renderBox.size.height,
      ), renderBox.size);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  Offset _clamp(Offset offset) {
    return Offset(
      offset.dx.clamp(0.0, 1.0),
      offset.dy.clamp(0.0, 1.0),
    );
  }

  Offset _clampToImageBounds(Offset offset, Size containerSize) {
    if (_imageSize == null) {
      return _clamp(offset);
    }

    // 컨테이너 내에서 이미지가 실제로 차지하는 영역 계산 (fit: BoxFit.contain)
    final containerAspectRatio = containerSize.width / containerSize.height;
    final imageAspectRatio = _imageSize!.width / _imageSize!.height;
    
    late double imageLeft, imageTop, imageRight, imageBottom;
    
    if (imageAspectRatio > containerAspectRatio) {
      // 이미지가 더 가로로 길면, 좌우 꽉 채우고 상하에 여백
      imageLeft = 0.0;
      imageRight = 1.0;
      final imageHeight = containerSize.width / imageAspectRatio;
      final topPadding = (containerSize.height - imageHeight) / 2;
      imageTop = topPadding / containerSize.height;
      imageBottom = 1.0 - imageTop;
    } else {
      // 이미지가 더 세로로 길면, 상하 꽉 채우고 좌우에 여백
      imageTop = 0.0;
      imageBottom = 1.0;
      final imageWidth = containerSize.height * imageAspectRatio;
      final leftPadding = (containerSize.width - imageWidth) / 2;
      imageLeft = leftPadding / containerSize.width;
      imageRight = 1.0 - imageLeft;
    }
    
    return Offset(
      offset.dx.clamp(imageLeft, imageRight),
      offset.dy.clamp(imageTop, imageBottom),
    );
  }

  Future<void> _cropAndSave() async {
    if (_imageSize == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 이미지 파일 읽기
      final imageFile = File(widget.imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image != null) {
        // 화면에서의 크롭 영역을 실제 이미지 좌표로 변환
        final rect = _cropRect;
        final renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
        final containerSize = renderBox.size;
        
        // 컨테이너 내에서 이미지가 실제로 차지하는 영역 계산
        final containerAspectRatio = containerSize.width / containerSize.height;
        final imageAspectRatio = _imageSize!.width / _imageSize!.height;
        
        late double imageLeft, imageTop, imageWidth, imageHeight;
        
        if (imageAspectRatio > containerAspectRatio) {
          // 이미지가 더 가로로 길면, 좌우 꽉 채우고 상하에 여백
          imageLeft = 0;
          imageWidth = containerSize.width;
          imageHeight = containerSize.width / imageAspectRatio;
          imageTop = (containerSize.height - imageHeight) / 2;
        } else {
          // 이미지가 더 세로로 길면, 상하 꽉 채우고 좌우에 여백
          imageTop = 0;
          imageHeight = containerSize.height;
          imageWidth = containerSize.height * imageAspectRatio;
          imageLeft = (containerSize.width - imageWidth) / 2;
        }
        
        // 화면 좌표를 이미지 내 비율로 변환
        final cropLeftRatio = (rect.left * containerSize.width - imageLeft) / imageWidth;
        final cropTopRatio = (rect.top * containerSize.height - imageTop) / imageHeight;
        final cropWidthRatio = (rect.width * containerSize.width) / imageWidth;
        final cropHeightRatio = (rect.height * containerSize.height) / imageHeight;
        
        // 실제 이미지 픽셀 좌표로 변환
        final cropX = (cropLeftRatio * image.width).round().clamp(0, image.width);
        final cropY = (cropTopRatio * image.height).round().clamp(0, image.height);
        final cropWidth = (cropWidthRatio * image.width).round().clamp(1, image.width - cropX);
        final cropHeight = (cropHeightRatio * image.height).round().clamp(1, image.height - cropY);
        
        // 이미지 크롭
        final croppedImage = img.copyCrop(
          image,
          x: cropX,
          y: cropY,
          width: cropWidth,
          height: cropHeight,
        );
        
        // 임시 파일로 저장
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 85));
        
        // 미리보기 다이얼로그 표시
        if (mounted) {
          _showPreviewDialog(tempFile);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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
    if (widget.isCompareMode && widget.onImageSelected != null) {
      // 비교 모드일 때는 이미지를 선택하고 화면들을 닫음
      widget.onImageSelected!(imageFile);
      // 현재 화면부터 ImageSourceScreen까지 모두 닫기
      Navigator.of(context).popUntil((route) {
        return route.settings.name == '/compare' || route.isFirst;
      });
    } else {
      // 일반 모드일 때는 기존대로 투명한 오버레이 페이지를 열어서 분석 진행
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TransparentOverlayScreen(
            imageFile: imageFile,
            category: widget.category,
          ),
          transitionDuration: Duration.zero, // 즉시 전환
          reverseTransitionDuration: Duration.zero, // 즉시 전환
          opaque: false, // 투명한 페이지
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('crop_image').toUpperCase(),
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanStart: (details) => _onPanStart(details, constraints),
                      onPanUpdate: (details) => _onPanUpdate(details, constraints),
                      onPanEnd: _onPanEnd,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(widget.imagePath),
                            key: _imageKey,
                            fit: BoxFit.contain,
                          ),
                          if (_imageSize != null)
                            CustomPaint(
                              painter: CropOverlayPainter(
                                cropRect: _cropRect,
                                isDragging: _isDragging,
                                imageSize: _imageSize,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // 안내 텍스트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              AppLocalizations.of(context)!.translate('crop_instruction'),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: AppTheme.gray500, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('cancel'),
                      style: TextStyle(
                        color: AppTheme.gray700,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _cropAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.whiteColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.translate('confirm'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final bool isDragging;
  final Size? imageSize;

  CropOverlayPainter({
    required this.cropRect,
    required this.isDragging,
    this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // 이미지 영역 계산
    Rect imageRect = Rect.fromLTWH(0, 0, size.width, size.height);
    if (imageSize != null) {
      final containerAspectRatio = size.width / size.height;
      final imageAspectRatio = imageSize!.width / imageSize!.height;
      
      if (imageAspectRatio > containerAspectRatio) {
        // 이미지가 더 가로로 길면, 좌우 꽉 채우고 상하에 여백
        final imageHeight = size.width / imageAspectRatio;
        final topPadding = (size.height - imageHeight) / 2;
        imageRect = Rect.fromLTWH(0, topPadding, size.width, imageHeight);
      } else {
        // 이미지가 더 세로로 길면, 상하 꽉 채우고 좌우에 여백
        final imageWidth = size.height * imageAspectRatio;
        final leftPadding = (size.width - imageWidth) / 2;
        imageRect = Rect.fromLTWH(leftPadding, 0, imageWidth, size.height);
      }
    }

    // 이미지 영역에만 반투명 오버레이
    final overlayPath = Path()..addRect(imageRect);

    // 크롭 영역 제외
    final cropPath = Path()
      ..addRect(Rect.fromLTRB(
        cropRect.left * size.width,
        cropRect.top * size.height,
        cropRect.right * size.width,
        cropRect.bottom * size.height,
      ));

    final path = Path.combine(PathOperation.difference, overlayPath, cropPath);
    canvas.drawPath(path, paint);

    // 크롭 영역 테두리
    final borderPaint = Paint()
      ..color = AppTheme.gray500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTRB(
        cropRect.left * size.width,
        cropRect.top * size.height,
        cropRect.right * size.width,
        cropRect.bottom * size.height,
      ),
      borderPaint,
    );

    // 가이드라인
    if (isDragging) {
      final guidePaint = Paint()
        ..color = AppTheme.gray500.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final cropWidth = (cropRect.right - cropRect.left) * size.width;
      final cropHeight = (cropRect.bottom - cropRect.top) * size.height;
      final left = cropRect.left * size.width;
      final top = cropRect.top * size.height;

      // 가로 가이드라인
      canvas.drawLine(
        Offset(left, top + cropHeight / 3),
        Offset(left + cropWidth, top + cropHeight / 3),
        guidePaint,
      );
      canvas.drawLine(
        Offset(left, top + cropHeight * 2 / 3),
        Offset(left + cropWidth, top + cropHeight * 2 / 3),
        guidePaint,
      );

      // 세로 가이드라인
      canvas.drawLine(
        Offset(left + cropWidth / 3, top),
        Offset(left + cropWidth / 3, top + cropHeight),
        guidePaint,
      );
      canvas.drawLine(
        Offset(left + cropWidth * 2 / 3, top),
        Offset(left + cropWidth * 2 / 3, top + cropHeight),
        guidePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return cropRect != oldDelegate.cropRect || 
           isDragging != oldDelegate.isDragging ||
           imageSize != oldDelegate.imageSize;
  }
}