import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/category.dart';
import '../services/localization_service.dart';
import '../utils/theme.dart';

class CategorySectionWidget extends StatelessWidget {
  final Function(String categoryId, String categoryName, bool isCustom)
      onCategoryTap;

  const CategorySectionWidget({
    super.key,
    required this.onCategoryTap,
  });

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => onCategoryTap(
        category.id,
        AppLocalizations.of(context)!.translate(category.nameKey),
        false,
      ),
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 중앙 아이콘
              SvgPicture.asset(
                category.iconPath,
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  AppTheme.blackColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 8),
              // 중앙 정렬 텍스트
              Text(
                AppLocalizations.of(context)!.translate(category.nameKey),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackColor,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherCard(BuildContext context) {
    return GestureDetector(
      onTap: () => onCategoryTap(
        'other',
        AppLocalizations.of(context)!.translate('other'),
        true,
      ),
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 중앙 아이콘
              SvgPicture.asset(
                'assets/icons/custom.svg',
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  AppTheme.blackColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 8),
              // 중앙 정렬 텍스트
              Text(
                AppLocalizations.of(context)!.translate('other'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackColor,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          AppLocalizations.of(context)!.translate('section_title'),
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        // Section Subtitle
        Text(
          AppLocalizations.of(context)!.translate('section_subtitle'),
          style: const TextStyle(
            color: AppTheme.gray500,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),

        // Category Grid (3 columns)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: categories.length + 1, // +1 for Other
          itemBuilder: (context, index) {
            if (index < categories.length) {
              return _buildCategoryCard(context, categories[index]);
            } else {
              return _buildOtherCard(context);
            }
          },
        ),
      ],
    );
  }
}
