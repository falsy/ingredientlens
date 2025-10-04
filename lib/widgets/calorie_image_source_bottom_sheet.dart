import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';

class CalorieImageSourceBottomSheet extends StatefulWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const CalorieImageSourceBottomSheet({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
  });

  @override
  State<CalorieImageSourceBottomSheet> createState() =>
      _CalorieImageSourceBottomSheetState();
}

class _CalorieImageSourceBottomSheetState
    extends State<CalorieImageSourceBottomSheet> {
  String _getTitleTranslation(BuildContext context, String titleKey) {
    switch (titleKey) {
      case 'gallery':
        return AppLocalizations.of(context)!.gallery;
      case 'camera':
        return AppLocalizations.of(context)!.camera;
      default:
        return titleKey;
    }
  }

  Widget _buildSourceButton({
    required BuildContext context,
    required String iconPath,
    required String titleKey,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.gray100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Image.asset(
                iconPath,
                width: 46,
                height: 46,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 6),
              // Title
              Text(
                _getTitleTranslation(context, titleKey),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(160, 0, 0, 0),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.whiteColor,
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
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Text(
              AppLocalizations.of(context)!.calorie_analysis,
              style: const TextStyle(
                color: AppTheme.blackColor,
                fontSize: AppTheme.bottomSheetTitleFontSize,
                fontWeight: AppTheme.bottomSheetTitleFontWeight,
                height: AppTheme.bottomSheetTitleLineHeight,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // SubTitle
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Text(
              AppLocalizations.of(context)!.calorie_analysis_photo_subtitle,
              style: const TextStyle(
                color: AppTheme.bottomSheetSubtitleColor,
                fontSize: AppTheme.bottomSheetSubtitleFontSize,
                fontWeight: AppTheme.bottomSheetSubtitleFontWeight,
                height: AppTheme.bottomSheetSubtitleLineHeight,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Source selection buttons
          Row(
            children: [
              // Gallery button
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0, // 정사각형
                  child: _buildSourceButton(
                    context: context,
                    iconPath: 'assets/images/gallery.webp',
                    titleKey: 'gallery',
                    onTap: widget.onGalleryTap,
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Camera button
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0, // 정사각형
                  child: _buildSourceButton(
                    context: context,
                    iconPath: 'assets/images/camera.webp',
                    titleKey: 'camera',
                    onTap: widget.onCameraTap,
                  ),
                ),
              ),
            ],
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
