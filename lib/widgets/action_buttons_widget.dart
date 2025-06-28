import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../utils/theme.dart';

class ActionButtonsWidget extends StatelessWidget {
  final String? selectedCategory;
  final String? customCategory;
  final bool showCustomInput;
  final TextEditingController customCategoryController;
  final VoidCallback onAnalyzePressed;
  final VoidCallback onComparePressed;
  final Function(String) onCustomCategoryChanged;

  const ActionButtonsWidget({
    super.key,
    required this.selectedCategory,
    required this.customCategory,
    required this.showCustomInput,
    required this.customCategoryController,
    required this.onAnalyzePressed,
    required this.onComparePressed,
    required this.onCustomCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom category input (like search bar)
        if (showCustomInput) ...[
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppTheme.cardBorderColor,
                width: 1,
              ),
            ),
            child: TextField(
              controller: customCategoryController,
              onChanged: onCustomCategoryChanged,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!
                    .translate('enter_custom_category'),
                hintStyle: TextStyle(
                  color: AppTheme.gray500,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              style: TextStyle(
                color: AppTheme.blackColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Analyze button
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onAnalyzePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
            child: Text(
              AppLocalizations.of(context)!.translate('analyze'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Compare button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: onComparePressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryGreen, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.translate('compare'),
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}