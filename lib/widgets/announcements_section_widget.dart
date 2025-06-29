import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../utils/theme.dart';

class AnnouncementsSectionWidget extends StatelessWidget {
  const AnnouncementsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          AppLocalizations.of(context)!.translate('announcements_title'),
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        // Section Subtitle
        Text(
          AppLocalizations.of(context)!.translate('announcements_subtitle'),
          style: const TextStyle(
            color: AppTheme.gray500,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),

        // Announcements Content (placeholder)
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                AppLocalizations.of(context)!.translate('no_announcements'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.gray500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
