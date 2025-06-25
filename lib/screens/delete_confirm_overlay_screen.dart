import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/database_service.dart';
import '../models/saved_result.dart';

class DeleteConfirmOverlayScreen extends StatefulWidget {
  final SavedResult savedResult;
  final VoidCallback onDeleted;

  const DeleteConfirmOverlayScreen({
    super.key,
    required this.savedResult,
    required this.onDeleted,
  });

  @override
  State<DeleteConfirmOverlayScreen> createState() => _DeleteConfirmOverlayScreenState();
}

class _DeleteConfirmOverlayScreenState extends State<DeleteConfirmOverlayScreen> {
  bool _isConfirmPressed = false;

  @override
  void initState() {
    super.initState();
    // 페이지가 로드되자마자 상태바를 검정색으로 설정하고 바텀시트 열기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDeleteBottomSheet();
    });
  }

  void _showDeleteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Container(
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
            
            // 제목
            Text(
              AppLocalizations.of(context)!.translate('confirm_delete'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // 내용
            Text(
              AppLocalizations.of(context)!.translate('confirm_delete_message'),
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.blackColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 바텀시트만 닫기 (투명 페이지는 .then에서 닫힘)
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.gray500, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(double.infinity, 50),
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
                    onPressed: () async {
                      // 확인 플래그 설정
                      _isConfirmPressed = true;
                      // 바텀시트 닫기
                      Navigator.pop(context);
                      // 삭제 실행
                      await _performDelete();
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
                      AppLocalizations.of(context)!.translate('delete'),
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
      ),
    ).then((_) {
      // 바텀시트가 닫히면 투명 페이지도 닫기 (확인이 눌리지 않은 경우에만)
      if (mounted && !_isConfirmPressed) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _performDelete() async {
    try {
      await DatabaseService().deleteResult(widget.savedResult.id!);
      // 투명 페이지 닫기
      Navigator.pop(context);
      // 삭제 완료 콜백 호출
      widget.onDeleted();
      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('delete_success')),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      // 투명 페이지 닫기
      Navigator.pop(context);
      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('delete_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
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