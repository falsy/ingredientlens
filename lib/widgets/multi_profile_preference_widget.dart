import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../screens/profile_screen.dart';
import '../screens/baby_info_screen.dart';
import '../screens/pet_info_screen.dart';

class MultiProfilePreferenceWidget extends StatefulWidget {
  final String selectedPreference; // 'none', 'user', 'baby', 'pet'
  final Function(String) onPreferenceChanged;

  const MultiProfilePreferenceWidget({
    super.key,
    required this.selectedPreference,
    required this.onPreferenceChanged,
  });

  @override
  State<MultiProfilePreferenceWidget> createState() =>
      _MultiProfilePreferenceWidgetState();
}

class _MultiProfilePreferenceWidgetState
    extends State<MultiProfilePreferenceWidget> {
  void _openProfileSettings(String type) {
    Widget screen;

    switch (type) {
      case 'baby':
        screen = const BabyInfoScreen();
        break;
      case 'pet':
        screen = const PetInfoScreen();
        break;
      default:
        screen = const ProfileScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  Widget _buildPreferenceOption({
    required String type,
    required String text,
    required bool isSelected,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(top: 2, bottom: 2, left: 16, right: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryTextColor.withOpacity(0.08)
            : AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected ? AppTheme.primaryTextColor : AppTheme.cardBorderColor,
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (widget.selectedPreference == type) {
            widget.onPreferenceChanged('none'); // 다시 선택하면 해제
          } else {
            widget.onPreferenceChanged(type);
          }
        },
        child: Row(
          children: [
            // 체크 아이콘과 텍스트 (전체 영역이 선택 가능)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
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
              onTap: () => _openProfileSettings(type),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isSelected ? AppTheme.primaryTextColor : AppTheme.gray400,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPreferenceOption(
          type: 'user',
          text: AppLocalizations.of(context)!.apply_user_info,
          isSelected: widget.selectedPreference == 'user',
        ),
        _buildPreferenceOption(
          type: 'baby',
          text: AppLocalizations.of(context)!.apply_baby_info,
          isSelected: widget.selectedPreference == 'baby',
        ),
        _buildPreferenceOption(
          type: 'pet',
          text: AppLocalizations.of(context)!.apply_pet_info,
          isSelected: widget.selectedPreference == 'pet',
        ),
      ],
    );
  }
}
