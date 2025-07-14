import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ShareService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  static ScreenshotController get screenshotController => _screenshotController;

  /// 화면을 캡처하고 공유하는 메서드
  static Future<void> captureAndShare({
    required GlobalKey repaintBoundaryKey,
    String? fileName,
    String? shareText,
  }) async {
    ui.Image? image;
    ByteData? byteData;
    File? imageFile;

    try {
      // 프레임이 완전히 렌더링될 때까지 대기 (실제 기기에서는 더 오래 대기)
      await Future.delayed(const Duration(milliseconds: 300));

      // RepaintBoundary를 사용하여 화면 캡처
      final context = repaintBoundaryKey.currentContext;
      if (context == null) {
        throw Exception('RepaintBoundary context is null');
      }

      final boundary = context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RenderRepaintBoundary not found');
      }

      // Release 모드에서는 debugNeedsPaint가 항상 false이므로
      // 단순히 충분한 시간을 대기하는 방식으로 변경
      if (kDebugMode) {
        // 디버그 모드에서만 debugNeedsPaint 체크
        int retryCount = 0;
        const maxRetries = 5;

        while (boundary.debugNeedsPaint && retryCount < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 100));
          retryCount++;
        }

        if (boundary.debugNeedsPaint) {
          throw Exception(
              'Widget is still painting after $maxRetries retries, cannot capture');
        }
      } else {
        // 릴리스 모드에서는 추가로 더 대기
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 고화질로 캡처 (픽셀 비율 2.0으로 낮춤)
      image = await boundary.toImage(pixelRatio: 2.0);
      if (image == null) {
        throw Exception('Failed to capture image - image is null');
      }

      byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();
      if (pngBytes.isEmpty) {
        throw Exception('Failed to convert image to bytes - empty data');
      }

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath =
          '${directory.path}/${fileName ?? 'ingredient_analysis_$timestamp'}.png';

      imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // 파일이 실제로 생성되었고 크기가 0이 아닌지 확인
      if (!await imageFile.exists()) {
        throw Exception('Failed to save image file');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      // 공유하기
      final result = await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText ?? 'IngredientLens - AI component analysis results',
      );

      if (kDebugMode) {
        print(
            'Screenshot captured and shared successfully. File size: $fileSize bytes');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error capturing and sharing screenshot: $e');
      }
      rethrow;
    } finally {
      // 리소스 정리
      image?.dispose();

      // 임시 파일 정리 (선택사항)
      try {
        if (imageFile != null && await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (e) {
        // 파일 삭제 실패는 무시
        if (kDebugMode) {
          print('Failed to delete temporary file: $e');
        }
      }
    }
  }

  /// Screenshot 패키지를 사용하여 위젯을 캡처하고 공유하는 메서드
  static Future<void> captureWidgetAndShare({
    required Widget widget,
    String? fileName,
    String? shareText,
  }) async {
    try {
      // 위젯을 이미지로 캡처
      final imageBytes = await _screenshotController.captureFromWidget(
        widget,
        pixelRatio: 3.0,
      );

      if (imageBytes.isEmpty) {
        throw Exception('Failed to capture widget - empty image data');
      }

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath =
          '${directory.path}/${fileName ?? 'ingredient_analysis_$timestamp'}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // 파일이 실제로 생성되었는지 확인
      if (!await imageFile.exists()) {
        throw Exception('Failed to save image file');
      }

      // 공유하기
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText ?? 'IngredientLens - AI 성분 분석 결과',
      );

      if (kDebugMode) {
        print('Widget captured and shared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error capturing and sharing widget: $e');
      }
      rethrow;
    }
  }

  /// 단순 텍스트 공유 메서드
  static Future<void> shareText(String text) async {
    try {
      await Share.share(text);
      if (kDebugMode) {
        print('Text shared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing text: $e');
      }
      rethrow;
    }
  }
}
