import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/database_service.dart';
import '../models/saved_result.dart';

class DeleteConfirmBottomSheet extends StatefulWidget {
  final SavedResult savedResult;
  final VoidCallback onDeleted;

  const DeleteConfirmBottomSheet({
    super.key,
    required this.savedResult,
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
      await DatabaseService().deleteResult(widget.savedResult.id!);

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
                color: AppTheme.blackColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              AppLocalizations.of(context)!.translate('confirm_delete_message'),
              style: const TextStyle(
                color: AppTheme.gray500,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 18),

            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isDeleting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                      side: const BorderSide(color: AppTheme.gray500, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('cancel'),
                      style: const TextStyle(
                        color: AppTheme.gray700,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Delete button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isDeleting ? null : _performDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blackColor,
                      foregroundColor: AppTheme.whiteColor,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
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
