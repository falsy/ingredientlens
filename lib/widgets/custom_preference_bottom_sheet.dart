import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';

class CustomPreferenceBottomSheet extends StatefulWidget {
  final Function(String) onSave;
  final int currentCustomCount;
  final TextInputType? keyboardType;
  final String? suffixText;

  const CustomPreferenceBottomSheet({
    super.key,
    required this.onSave,
    required this.currentCustomCount,
    this.keyboardType,
    this.suffixText,
  });

  @override
  State<CustomPreferenceBottomSheet> createState() =>
      _CustomPreferenceBottomSheetState();
}

class _CustomPreferenceBottomSheetState
    extends State<CustomPreferenceBottomSheet> {
  final TextEditingController _customController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool _hasSpecialCharacters(String text) {
    // 한글, 영문, 숫자, 공백만 허용
    final regex = RegExp(r'^[a-zA-Z0-9\s\u3131-\u318E\u3200-\u321E\u3260-\u327E\uAC00-\uD7A3]*$');
    return !regex.hasMatch(text);
  }

  void _handleSave() {
    final value = _customController.text.trim();
    final localizations = AppLocalizations.of(context)!;
    
    // 빈 값 체크
    if (value.isEmpty) {
      setState(() {
        _errorMessage = localizations.enter_custom_value;
      });
      return;
    }

    // 최대 개수 체크
    if (widget.currentCustomCount >= 3) {
      setState(() {
        _errorMessage = localizations.custom_limit_reached;
      });
      return;
    }

    // 글자 수 체크
    if (value.length > 20) {
      setState(() {
        _errorMessage = localizations.text_too_long;
      });
      return;
    }

    // 특수문자 체크
    if (_hasSpecialCharacters(value)) {
      setState(() {
        _errorMessage = localizations.invalid_characters;
      });
      return;
    }

    Navigator.pop(context);
    widget.onSave(value);
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
              AppLocalizations.of(context)!.add_custom,
              style: TextStyle(
                color: AppTheme.blackColor,
                fontSize: AppTheme.bottomSheetTitleFontSize,
                fontWeight: AppTheme.bottomSheetTitleFontWeight,
                height: AppTheme.bottomSheetTitleLineHeight,
              ),
            ),
            // const SizedBox(height: 8),

            // // Subtitle
            // Text(
            //   AppLocalizations.of(context)!.enter_custom_value,
            //   style: TextStyle(
            //     color: AppTheme.bottomSheetSubtitleColor,
            //     fontSize: AppTheme.bottomSheetSubtitleFontSize,
            //     fontWeight: AppTheme.bottomSheetSubtitleFontWeight,
            //     height: AppTheme.bottomSheetSubtitleLineHeight,
            //   ),
            // ),
            const SizedBox(height: 18),

            // Custom value input
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
                controller: _customController,
                keyboardType: widget.keyboardType ?? TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null; // Clear error when user types
                    
                    // 실시간 검증
                    final trimmedValue = value.trim();
                    final localizations = AppLocalizations.of(context)!;
                    
                    if (trimmedValue.length > 20) {
                      _errorMessage = localizations.text_too_long;
                    } else if (trimmedValue.isNotEmpty && _hasSpecialCharacters(trimmedValue)) {
                      _errorMessage = localizations.invalid_characters;
                    }
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixText: widget.suffixText,
                  suffixStyle: TextStyle(
                    color: AppTheme.gray600,
                    fontSize: 15,
                  ),
                ),
                style: TextStyle(
                  color: AppTheme.blackColor,
                  fontSize: 15,
                ),
                autofocus: true, // 바텀시트가 열리면 자동으로 키보드 포커스
              ),
            ),
            const SizedBox(height: 12),

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
                  style: TextStyle(
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

            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: SizedBox(
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: AppTheme.getButtonStyle('cancel'),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: AppTheme.getButtonTextStyle(
                            color: AppTheme.blackColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Save button
                Expanded(
                  child: SizedBox(
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: AppTheme.getButtonStyle('action'),
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: AppTheme.getButtonTextStyle(),
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
