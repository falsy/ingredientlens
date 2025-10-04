import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';
import '../models/saved_result.dart';

class SaveResultBottomSheet extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final String resultType; // 'analysis', 'comparison', 'nutrition'
  final String category;

  const SaveResultBottomSheet({
    super.key,
    required this.resultData,
    required this.resultType,
    required this.category,
  });

  @override
  State<SaveResultBottomSheet> createState() => _SaveResultBottomSheetState();
}

class _SaveResultBottomSheetState extends State<SaveResultBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveResult() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.enter_result_name;
      });
      return;
    }

    // 오류 메시지 초기화
    setState(() {
      _errorMessage = null;
    });

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final savedResult = SavedResult(
        name: name,
        resultType: widget.resultType,
        responseData: jsonEncode(widget.resultData),
        category: widget.category,
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseService().saveResult(savedResult);

      // Analytics: 결과 저장 이벤트
      await AnalyticsService.logResultSaved(
        resultType: widget.resultType,
        category: widget.category,
      );

      if (mounted) {
        Navigator.pop(context, true); // 성공했음을 알림
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.result_saved),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.save_failed_simple as String),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
              AppLocalizations.of(context)!.save_result,
              style: TextStyle(
                color: AppTheme.blackColor,
                fontSize: AppTheme.bottomSheetTitleFontSize,
                fontWeight: AppTheme.bottomSheetTitleFontWeight,
                height: AppTheme.bottomSheetTitleLineHeight,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              AppLocalizations.of(context)!.enter_result_name,
              style: TextStyle(
                color: AppTheme.gray500,
                fontSize: AppTheme.bottomSheetSubtitleFontSize,
                fontWeight: AppTheme.bottomSheetSubtitleFontWeight,
                height: AppTheme.bottomSheetSubtitleLineHeight,
              ),
            ),
            const SizedBox(height: 18),

            // 이름 입력 필드
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.cardBorderColor,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enter_result_name,
                  hintStyle: TextStyle(
                    color: AppTheme.gray500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  color: AppTheme.blackColor,
                  fontSize: 14,
                ),
                enabled: !_isSaving,
              ),
            ),
            const SizedBox(height: 8),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.negativeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.negativeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppTheme.negativeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ] else ...[
              const SizedBox(height: 14),
            ],

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: AppTheme.getButtonStyle('cancel'),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: AppTheme.getButtonTextStyle(
                        color: AppTheme.buttonColors['cancel']!['text'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _errorMessage = null;
                            });
                            _saveResult();
                          },
                    style: AppTheme.getButtonStyle('action'),
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppTheme.whiteColor,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.save,
                            style: AppTheme.getButtonTextStyle(),
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
    );
  }
}
