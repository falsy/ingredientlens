import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/api_service.dart';
import '../widgets/interstitial_ad_widget.dart';
import 'analysis_result_screen.dart';

class TransparentOverlayScreen extends StatefulWidget {
  final File imageFile;
  final String category;

  const TransparentOverlayScreen({
    super.key,
    required this.imageFile,
    required this.category,
  });

  @override
  State<TransparentOverlayScreen> createState() => _TransparentOverlayScreenState();
}

class _TransparentOverlayScreenState extends State<TransparentOverlayScreen> {
  bool _isAnalysisCancelled = false;
  bool _isAnalysisStarted = false;

  @override
  void initState() {
    super.initState();
    // 페이지가 로드되자마자 상태바를 검정색으로 설정하고 바텀시트 열기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPreviewBottomSheet();
    });
  }

  void _startAnalysis(File imageFile) {
    if (kDebugMode) print('🚀 분석 시작!');
    // 분석 시작 시 취소 플래그 초기화
    _isAnalysisCancelled = false;
    
    // API 호출을 먼저 시작
    _performAnalysis(imageFile);
    
    if (kDebugMode) print('📱 광고 화면 표시 시도...');
    // 전면 광고 표시 (API는 이미 시작됨)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (kDebugMode) print('✅ 광고 화면 빌드됨');
          return InterstitialAdWidget(
            onAdDismissed: () {
              // 광고가 끝났을 때는 아무것도 하지 않음 (API는 이미 진행 중)
              if (kDebugMode) print('📺 광고 종료, API 진행 중...');
            },
            onAnalysisCancelled: () {
              // 분석 취소 플래그 설정
              if (kDebugMode) print('❌ 분석 취소됨');
              _isAnalysisCancelled = true;
              // 분석 취소 시 광고 화면과 투명 페이지 닫기
              Navigator.pop(context); // 광고 화면 닫기
              Navigator.pop(context); // 투명 페이지 닫기
            },
          );
        },
      ),
    ).then((_) {
      if (kDebugMode) print('🔙 광고 화면에서 돌아옴');
    });
  }

  void _performAnalysis(File imageFile) async {
    try {
      // 현재 로케일에서 언어 코드 가져오기
      final langCode = Localizations.localeOf(context).languageCode;
      
      if (kDebugMode) {
        print('🔄 API 분석 시작...');
        print('📍 언어: $langCode, 카테고리: ${widget.category}');
      }
      
      // 실제 API 호출
      final result = await ApiService.analyzeIngredients(
        imageFile: imageFile,
        category: widget.category,
        langCode: langCode,
      );
      
      if (kDebugMode) print('✅ API 분석 완료!');
      
      // 취소되지 않았을 때만 결과 화면으로 이동
      if (mounted && !_isAnalysisCancelled) {
        if (kDebugMode) print('📄 결과 화면으로 이동...');
        // 모든 화면을 닫고 결과 화면으로 이동
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(analysisResult: result),
          ),
        );
      } else {
        if (kDebugMode) print('❌ 분석이 취소되었거나 위젯이 dispose됨');
      }
    } catch (e) {
      // 에러 처리 (취소되지 않았을 때만)
      if (kDebugMode) print('💥 분석 에러: $e');
      if (mounted && !_isAnalysisCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('analysis_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
        Navigator.pop(context); // 광고 화면 닫기
        Navigator.pop(context); // 투명 페이지 닫기
      }
    }
  }

  void _showPreviewBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.translate('photo_taken'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                      widget.imageFile,
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // 취소 플래그 설정
                        _isAnalysisCancelled = true;
                        // 바텀시트만 닫기 (투명 페이지는 .then에서 닫힘)
                        Navigator.pop(context); // 바텀시트 닫기
                      },
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
                      onPressed: () {
                        // 분석 시작 플래그 설정
                        _isAnalysisStarted = true;
                        // 바텀시트 닫기
                        Navigator.pop(context); 
                        // 즉시 분석 시작
                        _startAnalysis(widget.imageFile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: AppTheme.whiteColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
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
              // 하단 SafeArea 확보
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    ).then((_) {
      // 바텀시트가 닫히면 투명 페이지도 닫기 (분석이 시작되지 않은 경우에만)
      if (mounted && !_isAnalysisStarted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // 완전 투명한 배경
        body: Container(), // 빈 컨테이너
      ),
    );
  }
}