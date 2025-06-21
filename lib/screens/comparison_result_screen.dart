import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../widgets/ad_banner_widget.dart';

class ComparisonResultScreen extends StatefulWidget {
  final Map<String, dynamic> comparisonResult;

  const ComparisonResultScreen({
    super.key,
    required this.comparisonResult,
  });

  @override
  State<ComparisonResultScreen> createState() => _ComparisonResultScreenState();
}

class _ComparisonResultScreenState extends State<ComparisonResultScreen> {
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
        hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.translate('storage_permission_needed')),
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
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ingredient_comparison_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(pngBytes);

      // gal 패키지를 사용해서 갤러리에 저장
      await Gal.putImage(tempFile.path);
      
      // 임시 파일 삭제
      await tempFile.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('screenshot_saved')),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('screenshot_failed')),
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
          AppLocalizations.of(context)!.translate('compare_ingredients').toUpperCase(),
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
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Container(
                color: AppTheme.backgroundColor,
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: _buildSectionsWithSpacing(context),
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

  Widget _buildSection({
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
        ...items.map((item) => _buildIngredientCard(item, color)),
      ],
    );
  }

  Widget _buildIngredientCard(dynamic item, Color accentColor) {
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
    
    // Product A 성분
    final productASection = _buildSection(
      title: AppLocalizations.of(context)!.translate('product_a'),
      items: widget.comparisonResult['product_a_ingredients'] ?? [],
      color: AppTheme.primaryGreen,
      icon: Icons.label_outline,
    );
    if (productASection is! SizedBox) {
      sections.add(productASection);
    }
    
    // Product B 성분
    final productBSection = _buildSection(
      title: AppLocalizations.of(context)!.translate('product_b'),
      items: widget.comparisonResult['product_b_ingredients'] ?? [],
      color: AppTheme.primaryGreen,
      icon: Icons.label_outline,
    );
    if (productBSection is! SizedBox) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(productBSection);
    }
    
    // 종합 비교 분석
    final overallSection = _buildOverallComparison(context);
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

  Widget _buildOverallComparison(BuildContext context) {
    final overallReview = widget.comparisonResult['overall_comparative_review'];
    if (overallReview == null || overallReview.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.compare_arrows, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.translate('overall_comparison'),
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