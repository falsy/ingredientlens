import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../models/category.dart';
import '../utils/theme.dart';

class CategorySectionWidget extends StatelessWidget {
  final Function(String categoryId, String categoryName, bool isCustom)
      onCategoryTap;

  const CategorySectionWidget({
    super.key,
    required this.onCategoryTap,
  });

  String _getCategoryNameTranslation(BuildContext context, String nameKey) {
    switch (nameKey) {
      case 'food':
        return AppLocalizations.of(context)!.food;
      case 'cosmetics':
        return AppLocalizations.of(context)!.cosmetics;
      case 'baby_products':
        return AppLocalizations.of(context)!.baby_products;
      case 'pet_products':
        return AppLocalizations.of(context)!.pet_products;
      case 'medicine':
        return AppLocalizations.of(context)!.medicine;
      case 'household_products':
        return AppLocalizations.of(context)!.household_products;
      case 'cleaning_products':
        return AppLocalizations.of(context)!.cleaning_products;
      case 'vegan_products':
        return AppLocalizations.of(context)!.vegan_products;
      case 'other':
        return AppLocalizations.of(context)!.other;
      default:
        return nameKey;
    }
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => onCategoryTap(
        category.id,
        _getCategoryNameTranslation(context, category.nameKey),
        false,
      ),
      child: Container(
        // color: Colors.green.withOpacity(0.1),
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 아이콘 영역
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppTheme.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  category.iconPath,
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // 텍스트 영역
            SizedBox(
              height: 28,
              child: Text(
                _getCategoryNameTranslation(context, category.nameKey),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(190, 0, 0, 0),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOtherCard(BuildContext context) {
    return GestureDetector(
      onTap: () => onCategoryTap(
        'other',
        AppLocalizations.of(context)!.other,
        true,
      ),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppTheme.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/other.webp',
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 28, // 2줄 텍스트 기준 고정 높이
              child: Text(
                AppLocalizations.of(context)!.other,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(190, 0, 0, 0),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 4컬럼으로 변경
    const crossAxisCount = 4;
    const childAspectRatio = 0.7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.category_section_title,
                style: const TextStyle(
                  color: AppTheme.sectionTitleColor,
                  fontSize: AppTheme.sectionTitleFontSize,
                  fontWeight: AppTheme.sectionTitleFontWeight,
                  height: AppTheme.sectionTitleLineHeight,
                ),
              ),
              const SizedBox(height: 6),
              // Section Subtitle
              Text(
                AppLocalizations.of(context)!.category_section_subtitle,
                style: const TextStyle(
                  color: AppTheme.sectionSubtitleColor,
                  fontSize: AppTheme.sectionSubtitleFontSize,
                  fontWeight: AppTheme.sectionSubtitleFontWeight,
                  height: AppTheme.sectionSubtitleLineHeight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 0,
            childAspectRatio: childAspectRatio,
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
