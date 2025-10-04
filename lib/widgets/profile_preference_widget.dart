import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../screens/profile_screen.dart';
import '../screens/baby_info_screen.dart';
import '../screens/pet_info_screen.dart';

class ProfilePreferenceWidget extends StatefulWidget {
  final bool applyProfile;
  final Function(bool) onProfileToggled;
  final String? category;

  const ProfilePreferenceWidget({
    super.key,
    required this.applyProfile,
    required this.onProfileToggled,
    this.category,
  });

  @override
  State<ProfilePreferenceWidget> createState() =>
      _ProfilePreferenceWidgetState();
}

class _ProfilePreferenceWidgetState extends State<ProfilePreferenceWidget> {
  void _openProfileSettings() {
    Widget screen;

    if (widget.category != null) {
      if (_isBabyCategory(widget.category!)) {
        screen = const BabyInfoScreen();
      } else if (_isPetCategory(widget.category!)) {
        screen = const PetInfoScreen();
      } else {
        screen = const ProfileScreen();
      }
    } else {
      screen = const ProfileScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  String _getDisplayText() {
    if (widget.category != null && _isBabyCategory(widget.category!)) {
      return AppLocalizations.of(context)!.apply_baby_info;
    } else if (widget.category != null && _isPetCategory(widget.category!)) {
      return AppLocalizations.of(context)!.apply_pet_info;
    } else {
      return AppLocalizations.of(context)!.apply_user_info;
    }
  }

  bool _isBabyCategory(String category) {
    return category == 'baby_products' || category.startsWith('baby_');
  }

  bool _isPetCategory(String category) {
    return category == 'pet_products' || category.startsWith('pet_');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(top: 2, bottom: 2, left: 16, right: 12),
      decoration: BoxDecoration(
        color: widget.applyProfile
            ? AppTheme.primaryTextColor.withOpacity(0.08)
            : AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.applyProfile
              ? AppTheme.primaryTextColor
              : AppTheme.cardBorderColor,
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => widget.onProfileToggled(!widget.applyProfile),
        child: Row(
          children: [
            // 텍스트 (전체 영역이 선택 가능)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _getDisplayText(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: widget.applyProfile
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: widget.applyProfile
                                ? AppTheme.primaryTextColor
                                : AppTheme.gray500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 설정 버튼 (오른쪽 화살표) - 화면 이동만 담당
            GestureDetector(
              onTap: _openProfileSettings,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  widget.applyProfile ? AppTheme.primaryTextColor : AppTheme.gray400,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/icons/right-arrow.webp',
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
