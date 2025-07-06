import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/database_service.dart';
import '../models/saved_result.dart';
import '../models/saved_ingredient.dart';

class DeleteConfirmBottomSheet extends StatefulWidget {
  final dynamic itemToDelete;
  final VoidCallback onDeleted;

  const DeleteConfirmBottomSheet({
    super.key,
    required this.itemToDelete,
    required this.onDeleted,
  });

  @override
  State<DeleteConfirmBottomSheet> createState() =>
      _DeleteConfirmBottomSheetState();
}

class _DeleteConfirmBottomSheetState extends State<DeleteConfirmBottomSheet> {
  bool _isDeleting = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _performDelete() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      if (widget.itemToDelete is SavedResult) {
        await DatabaseService().deleteResult(widget.itemToDelete.id!);
      } else if (widget.itemToDelete is SavedIngredient) {
        await DatabaseService().deleteIngredient(widget.itemToDelete.id!);
      }

      if (mounted) {
        Navigator.pop(context, true); // 성공했음을 알림
        widget.onDeleted(); // 삭제 완료 콜백 호출
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.translate('delete_success')),
            backgroundColor: AppTheme.blackColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.translate('delete_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
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
              AppLocalizations.of(context)!.translate('confirm_delete'),
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
              AppLocalizations.of(context)!.translate('confirm_delete_message'),
              style: const TextStyle(
                color: AppTheme.bottomSheetSubtitleColor,
                fontSize: AppTheme.bottomSheetSubtitleFontSize,
                fontWeight: AppTheme.bottomSheetSubtitleFontWeight,
                height: AppTheme.bottomSheetSubtitleLineHeight,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isDeleting ? null : () => Navigator.pop(context),
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

                // Delete button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isDeleting ? null : _performDelete,
                    style: AppTheme.getButtonStyle('action'),
                    child: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.translate('delete'),
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
