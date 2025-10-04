import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/database_service.dart';
import '../models/saved_ingredient.dart';

class SaveIngredientBottomSheet extends StatefulWidget {
  final Map<String, dynamic> ingredientDetail;
  final String ingredientName;

  const SaveIngredientBottomSheet({
    super.key,
    required this.ingredientDetail,
    required this.ingredientName,
  });

  @override
  State<SaveIngredientBottomSheet> createState() =>
      _SaveIngredientBottomSheetState();
}

class _SaveIngredientBottomSheetState extends State<SaveIngredientBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 기본 이름을 성분 이름으로 설정
    _nameController.text = widget.ingredientName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveIngredient() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.enter_name;
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
      final savedIngredient = SavedIngredient(
        name: _nameController.text.trim(),
        ingredientName: widget.ingredientName,
        category: widget.ingredientDetail['category'] ?? '',
        responseData: jsonEncode(widget.ingredientDetail),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await DatabaseService().saveIngredient(savedIngredient);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.save_complete,
            ),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.save_failed_simple as String,
            ),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
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
              AppLocalizations.of(context)!.save_ingredient,
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
              AppLocalizations.of(context)!.enter_save_name,
              style: TextStyle(
                color: AppTheme.gray500,
                fontSize: AppTheme.bottomSheetSubtitleFontSize,
                fontWeight: AppTheme.bottomSheetSubtitleFontWeight,
                height: AppTheme.bottomSheetSubtitleLineHeight,
              ),
            ),
            const SizedBox(height: 18),

            // Name input field
            TextField(
              controller: _nameController,
              enabled: !_isSaving,
              maxLength: 50,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.save_name_hint,
                counterText: '',
                filled: true,
                fillColor: AppTheme.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.blackColor,
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
                          color: AppTheme.buttonColors['cancel']!['text']),
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
                            _saveIngredient();
                          },
                    style: AppTheme.getButtonStyle('action'),
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.whiteColor),
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

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}
