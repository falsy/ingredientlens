import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../services/usage_limit_service.dart';
import '../screens/ingredient_detail_screen.dart';
import '../widgets/interstitial_ad_widget.dart';

class IngredientSearchBottomSheet extends StatefulWidget {
  final String ingredientName;
  final String category;
  final VoidCallback? onSearchRequested;

  const IngredientSearchBottomSheet({
    super.key,
    required this.ingredientName,
    required this.category,
    this.onSearchRequested,
  });

  @override
  State<IngredientSearchBottomSheet> createState() =>
      _IngredientSearchBottomSheetState();
}

class _IngredientSearchBottomSheetState
    extends State<IngredientSearchBottomSheet> {
  bool _isSearchCancelled = false;

  @override
  void initState() {
    super.initState();
  }

  void _startSearch() async {
    if (kDebugMode) print('🔍 성분 검색 시작!');

    // 사용량 제한 확인
    final usageLimitService = UsageLimitService();
    final canMakeRequest = await usageLimitService.canMakeRequest();

    if (!canMakeRequest) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.daily_limit_reached),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    _isSearchCancelled = false;

    // 사용량 증가
    await usageLimitService.incrementUsage();

    // 바텀시트 닫기
    Navigator.pop(context);

    // API 호출 Future 저장
    final searchResult = _performSearchWithErrorHandling();

    // 전면 광고 표시
    if (kDebugMode) print('📱 성분 검색 광고 화면 표시 시도...');

    // 약간의 딜레이 후 광고 화면 표시
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted && !_isSearchCancelled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            if (kDebugMode) print('✅ 성분 검색 광고 화면 빌드됨');
            return InterstitialAdWidget(
              onAdDismissed: () async {
                if (kDebugMode) print('📺 성분 검색 광고 종료, API 완료 대기 중...');
                // 광고 종료 후 API 완료까지 기다림
                final errorMsg = await searchResult;
                if (errorMsg != null && mounted) {
                  // API 에러가 있으면 광고 화면 닫고 에러 표시
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: AppTheme.negativeColor,
                        ),
                      );
                    }
                  });
                }
                // API 성공 시에는 _performSearch에서 이미 화면 이동이 처리됨
              },
              onAnalysisCancelled: () {
                if (kDebugMode) print('❌ 성분 검색 취소됨');
                _isSearchCancelled = true;
                Navigator.pop(context); // 광고 화면 닫기
              },
            );
          },
        ),
      );
    }
  }

  Future<String?> _performSearchWithErrorHandling() async {
    try {
      await _performSearch();
      return null; // 성공한 경우 에러 메시지 없음
    } catch (e) {
      if (kDebugMode) print('💥 성분 검색 에러: $e');
      return AppLocalizations.of(context)!.analysis_failed;
    }
  }

  Future<void> _performSearch() async {
    final langCode = Localizations.localeOf(context).languageCode;

    if (kDebugMode) {
      print('🔄 성분 검색 API 시작...');
      print(
          '📍 성분: ${widget.ingredientName}, 카테고리: ${widget.category}, 언어: $langCode');
    }

    final result = await ApiService.getIngredientDetail(
      ingredient: widget.ingredientName,
      category: widget.category,
      langCode: langCode,
    );

    if (kDebugMode) print('✅ 성분 검색 API 완료!');

    if (mounted && !_isSearchCancelled) {
      if (kDebugMode) print('📄 성분 상세 화면으로 이동...');
      // 모든 중간 화면을 제거하고 결과 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => IngredientDetailScreen(
            ingredientDetail: result,
            ingredientName: widget.ingredientName,
            category: widget.category,
          ),
        ),
        (route) => route.isFirst, // 홈 화면만 남김
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              AppLocalizations.of(context)!.ingredient_search,
              style: TextStyle(
                color: AppTheme.blackColor,
                fontSize: AppTheme.adjustFontSizeForPlatform(18),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              AppLocalizations.of(context)!
                  .ingredient_search_message(widget.ingredientName),
              style: TextStyle(
                color: AppTheme.gray500,
                fontSize: AppTheme.adjustFontSizeForPlatform(16),
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppTheme.getButtonStyle('cancel'),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: AppTheme.getButtonTextStyle(
                          color: AppTheme.buttonColors['cancel']!['text']),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 바텀시트 닫기
                      if (widget.onSearchRequested != null) {
                        widget.onSearchRequested!();
                      } else {
                        _startSearch();
                      }
                    },
                    style: AppTheme.getButtonStyle('action'),
                    child: Text(
                      AppLocalizations.of(context)!.search,
                      style: AppTheme.getButtonTextStyle(),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}
