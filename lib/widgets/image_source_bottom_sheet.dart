import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/localization_service.dart';
import '../utils/theme.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final String categoryName;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const ImageSourceBottomSheet({
    super.key,
    required this.categoryName,
    required this.onGalleryTap,
    required this.onCameraTap,
  });

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
          color: AppTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.cardBorderColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              SvgPicture.asset(
                iconPath,
                width: 34,
                height: 34,
                colorFilter: const ColorFilter.mode(
                  AppTheme.blackColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 6),
              // Title
              Text(
                AppLocalizations.of(context)!.translate(titleKey),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackColor,
                  height: 1.3,
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
            categoryName,
            style: const TextStyle(
              color: AppTheme.blackColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            AppLocalizations.of(context)!.translate(
                'take_photo_of_ingredients', {'category': categoryName}),
            style: const TextStyle(
              color: AppTheme.gray500,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
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
                    iconPath: 'assets/icons/gallery.svg',
                    titleKey: 'gallery',
                    onTap: onGalleryTap,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Camera button
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0, // 정사각형
                  child: _buildSourceButton(
                    context: context,
                    iconPath: 'assets/icons/camera.svg',
                    titleKey: 'camera',
                    onTap: onCameraTap,
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
