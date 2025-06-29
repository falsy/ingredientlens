import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../utils/theme.dart';

class CategoryActionBottomSheet extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final bool isCustomCategory;
  final Function(String?) onCustomCategoryChanged;
  final Function(String) onAnalyze; // Changed to pass category
  final VoidCallback onCompare;

  const CategoryActionBottomSheet({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.isCustomCategory,
    required this.onCustomCategoryChanged,
    required this.onAnalyze,
    required this.onCompare,
  });

  @override
  State<CategoryActionBottomSheet> createState() =>
      _CategoryActionBottomSheetState();
}

class _CategoryActionBottomSheetState extends State<CategoryActionBottomSheet> {
  final TextEditingController _customCategoryController =
      TextEditingController();
  String? _customCategory;
  String? _errorMessage;

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  void _handleAnalyze() {
    String? categoryToAnalyze;

    if (widget.isCustomCategory) {
      final customText = _customCategory?.trim();
      if (customText == null || customText.isEmpty) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)!.translate('enter_custom_category');
        });
        return;
      }
      categoryToAnalyze = customText;
    } else {
      categoryToAnalyze = widget.categoryId;
    }

    Navigator.pop(context);
    widget.onAnalyze(categoryToAnalyze);
  }

  void _handleCompare() {
    if (widget.isCustomCategory) {
      final customText = _customCategory?.trim();
      if (customText == null || customText.isEmpty) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)!.translate('enter_custom_category');
        });
        return;
      }
    }
    Navigator.pop(context);
    widget.onCompare();
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
              widget.categoryName,
              style: const TextStyle(
                color: AppTheme.blackColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              AppLocalizations.of(context)!.translate('select_action'),
              style: const TextStyle(
                color: AppTheme.gray500,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 18),

            // Custom category input (only for custom category)
            if (widget.isCustomCategory) ...[
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
                  controller: _customCategoryController,
                  onChanged: (value) {
                    setState(() {
                      _customCategory = value;
                      _errorMessage = null; // Clear error when user types
                    });
                    widget.onCustomCategoryChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!
                        .translate('enter_custom_category'),
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.negativeColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppTheme.negativeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ] else ...[
                const SizedBox(height: 18),
              ],
            ],

            // Action buttons
            Row(
              children: [
                // Analyze button
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _handleAnalyze,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.whiteColor,
                        foregroundColor: AppTheme.blackColor,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: AppTheme.blackColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('analyze'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Compare button
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _handleCompare,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.whiteColor,
                        foregroundColor: AppTheme.blackColor,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: AppTheme.blackColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('compare'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
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
