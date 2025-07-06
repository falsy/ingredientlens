import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/localization_service.dart';
import '../utils/theme.dart';

class HomeHeaderWidget extends StatelessWidget {
  final VoidCallback onSavedResultsTap;

  const HomeHeaderWidget({
    super.key,
    required this.onSavedResultsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Saved results button
            GestureDetector(
              onTap: onSavedResultsTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.cardBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.cardBorderColor,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/bookmark.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.blackColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // App Title
        Text(
          AppLocalizations.of(context)!.translate('main_title'),
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}
