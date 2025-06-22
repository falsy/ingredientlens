import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../widgets/ad_banner_widget.dart';

class AnalysisResultScreen extends StatefulWidget {
  final Map<String, dynamic> analysisResult;

  const AnalysisResultScreen({
    super.key,
    required this.analysisResult,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSavingScreenshot = false;

  Future<void> _saveScreenshot() async {
    if (_isSavingScreenshot) return;

    setState(() {
      _isSavingScreenshot = true;
    });

    try {
      // 권한 확인 및 요청
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        // 권한 요청
        hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .translate('storage_permission_needed')),
                backgroundColor: AppTheme.negativeColor,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      // RepaintBoundary에서 이미지 캡처
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // 이미지를 바이트 배열로 변환
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/ingredient_analysis_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(pngBytes);

      // gal 패키지를 사용해서 갤러리에 저장
      await Gal.putImage(tempFile.path);

      // 임시 파일 삭제
      await tempFile.delete();

      if (mounted) {
        // 기존 스낵바 제거
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.translate('screenshot_saved')),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Screenshot error: $e');
      if (kDebugMode) print('Screenshot error type: ${e.runtimeType}');
      if (mounted) {
        // 기존 스낵바 제거
        ScaffoldMessenger.of(context).clearSnackBars();

        // 권한 오류인지 확인
        String errorMessage =
            AppLocalizations.of(context)!.translate('screenshot_failed');
        String errorDetail = e.toString();

        if (errorDetail.contains('permission') ||
            errorDetail.contains('Permission') ||
            errorDetail.contains('access') ||
            errorDetail.contains('denied')) {
          errorMessage = AppLocalizations.of(context)!
              .translate('storage_permission_needed');
        }

        // 디버깅용 상세 에러 메시지 (개발 중에만)
        if (kDebugMode) print('Error details: $errorDetail');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage\n디버그: ${e.toString()}'),
            backgroundColor: AppTheme.negativeColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingScreenshot = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 결과 화면에서도 상태바와 네비게이션 바를 배경색으로 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F5F5),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF5F5F5),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!
              .translate('analysis_results')
              .toUpperCase(),
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
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.zero,
              child: RepaintBoundary(
                key: _repaintBoundaryKey,
                child: Container(
                  color: AppTheme.backgroundColor,
                  padding: const EdgeInsets.all(20), // 화면과 스크린샷 모두에 적용되는 여백
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildSectionsWithSpacing(context),
                  ),
                ),
              ),
            ),
          ),
          // 하단 광고 배너
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
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
        // ListView 대신 Column으로 최적화
        ...items.map((item) => _buildIngredientCard(context, item, color)),
      ],
    );
  }

  Widget _buildIngredientCard(
      BuildContext context, dynamic item, Color accentColor) {
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

    // 긍정적인 성분
    final positiveSection = _buildSection(
      context,
      title: AppLocalizations.of(context)!.translate('positive_ingredients'),
      items: widget.analysisResult['positive_ingredients'] ?? [],
      color: AppTheme.primaryGreen,
      icon: Icons.check,
    );
    if (positiveSection is! SizedBox) {
      sections.add(positiveSection);
    }

    // 부정적인 성분
    final negativeSection = _buildSection(
      context,
      title: AppLocalizations.of(context)!.translate('negative_ingredients'),
      items: widget.analysisResult['negative_ingredients'] ?? [],
      color: AppTheme.negativeColor,
      icon: Icons.not_interested,
    );
    if (negativeSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(negativeSection);
    }

    // 기타 성분
    final otherSection = _buildSection(
      context,
      title: AppLocalizations.of(context)!.translate('other_ingredients'),
      items: widget.analysisResult['other_ingredients'] ?? [],
      color: AppTheme.gray700,
      icon: Icons.local_offer_outlined,
    );
    if (otherSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(otherSection);
    }

    // 총평
    final overallSection = _buildOverallReview(context);
    if (overallSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(overallSection);
    }

    // 스크린샷 저장 버튼 추가
    if (sections.isNotEmpty) {
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
              fontSize: 12,
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
        onPressed: _isSavingScreenshot ? null : _saveScreenshot,
        icon: _isSavingScreenshot
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_alt, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.translate('save_screenshot'),
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

  Widget _buildOverallReview(BuildContext context) {
    final overallReview = widget.analysisResult['overall_review'];
    if (overallReview == null || overallReview.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline,
                color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.translate('overall_review'),
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
          child: Text(
            overallReview.toString(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.blackColor,
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }
}
