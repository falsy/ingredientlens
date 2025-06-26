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
          content: Text(AppLocalizations.of(context)!.translate('enter_result_name')),
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
            content: Text(AppLocalizations.of(context)!.translate('result_saved')),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('save_failed')),
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
          // 제목
          Text(
            AppLocalizations.of(context)!.translate('save_result'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          
          // 이름 라벨
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.translate('result_name'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.blackColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // 이름 입력 필드
          Container(
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate('enter_result_name'),
                hintStyle: TextStyle(
                  color: AppTheme.primaryGreen.withOpacity(0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 14,
              ),
              enabled: !_isSaving,
            ),
          ),
          const SizedBox(height: 24),
          
          // 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                  onPressed: _isSaving ? null : _saveResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.whiteColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
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
                          style: const TextStyle(
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
    );
  }
}