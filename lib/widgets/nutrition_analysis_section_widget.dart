import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../models/category.dart';
import '../utils/category_translation_util.dart';

class NutritionAnalysisSectionWidget extends StatelessWidget {
  final Function(String categoryId, String categoryName) onCategoryTap;

  const NutritionAnalysisSectionWidget({
    super.key,
    required this.onCategoryTap,
  });

  Widget _buildNutritionCategoryCard(
    BuildContext context,
    Category category,
  ) {
    final categoryName =
        CategoryTranslationUtil.getCategoryName(context, category.nameKey);

    return GestureDetector(
      onTap: () => onCategoryTap(category.id, categoryName),
      child: Container(
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
            // 텍스트 영역 (고정 높이로 일관성 유지)
            SizedBox(
              height: 28, // 2줄 텍스트 기준 고정 높이
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(160, 0, 0, 0),
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
                AppLocalizations.of(context)!.nutrition_analysis_subtitle,
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

        // Nutrition Category Grid
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
          itemCount: nutritionCategories.length,
          itemBuilder: (context, index) {
            final category = nutritionCategories[index];
            return _buildNutritionCategoryCard(
              context,
              category,
            );
          },
        ),
      ],
    );
  }
}
