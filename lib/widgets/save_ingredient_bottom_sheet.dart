import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/localization_service.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('enter_name'),
          ),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
      return;
    }

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
              AppLocalizations.of(context)!.translate('save_complete'),
            ),
            backgroundColor: AppTheme.positiveColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('save_failed'),
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
              AppLocalizations.of(context)!.translate('save_ingredient'),
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
              AppLocalizations.of(context)!.translate('enter_save_name'),
              style: const TextStyle(
                color: AppTheme.bottomSheetSubtitleColor,
                fontSize: AppTheme.bottomSheetSubtitleFontSize,
                fontWeight: AppTheme.bottomSheetSubtitleFontWeight,
                height: AppTheme.bottomSheetSubtitleLineHeight,
              ),
            ),
            const SizedBox(height: 24),

            // Name input field
            TextField(
              controller: _nameController,
              enabled: !_isSaving,
              maxLength: 50,
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)!.translate('save_name_hint'),
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
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.blackColor,
              ),
            ),
            const SizedBox(height: 24),

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
                          color: AppTheme.blackColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveIngredient,
                    style: AppTheme.getButtonStyle('action'),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}
