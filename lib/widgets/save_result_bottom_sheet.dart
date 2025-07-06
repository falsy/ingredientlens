import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/database_service.dart';
import '../models/saved_result.dart';

class SaveResultBottomSheet extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final String resultType; // 'analysis' 또는 'comparison'
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveResult() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate('enter_result_name')),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
      return;
    }

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

      if (mounted) {
        Navigator.pop(context, true); // 성공했음을 알림
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.translate('result_saved')),
            backgroundColor: AppTheme.positiveColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.translate('save_failed')),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
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
              AppLocalizations.of(context)!.translate('save_result'),
              style: const TextStyle(
                color: AppTheme.bottomSheetTitleColor,
                fontSize: AppTheme.bottomSheetTitleFontSize,
                fontWeight: AppTheme.bottomSheetTitleFontWeight,
                height: AppTheme.bottomSheetTitleLineHeight,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              AppLocalizations.of(context)!.translate('enter_result_name'),
              style: const TextStyle(
                color: AppTheme.bottomSheetSubtitleColor,
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
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!
                      .translate('enter_result_name'),
                  hintStyle: const TextStyle(
                    color: AppTheme.gray500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(
                  color: AppTheme.blackColor,
                  fontSize: 14,
                ),
                enabled: !_isSaving,
              ),
            ),
            const SizedBox(height: 20),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: AppTheme.getButtonStyle('cancel'),
                    child: Text(
                      AppLocalizations.of(context)!.translate('cancel'),
                      style: AppTheme.getButtonTextStyle(
                        color: AppTheme.buttonColors['cancel']!['text'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveResult,
                    style: AppTheme.getButtonStyle('action'),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.translate('save'),
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
