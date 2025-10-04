import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';

class PopularCategoriesSectionWidget extends StatelessWidget {
  final Function(String categoryId, String categoryName, bool isCustom)
      onCategoryTap;

  const PopularCategoriesSectionWidget({
    super.key,
    required this.onCategoryTap,
  });

  // 파스텔 색상들
  static const List<Color> pastelColors = [
    Color.fromARGB(170, 255, 229, 229), // 연한 핑크
    Color.fromARGB(170, 229, 243, 255), // 연한 파랑
    Color.fromARGB(170, 229, 255, 229), // 연한 초록
    Color.fromARGB(170, 255, 245, 229), // 연한 주황
    Color.fromARGB(170, 245, 229, 255), // 연한 보라
    Color.fromARGB(170, 255, 255, 229), // 연한 노랑
    Color.fromARGB(170, 229, 255, 255), // 연한 시안
  ];

  String _getCategoryTranslation(BuildContext context, String category) {
    switch (category) {
      case 'cosmetics_haircare':
        return AppLocalizations.of(context)!.cosmetics_haircare;
      case 'cosmetics_skincare':
        return AppLocalizations.of(context)!.cosmetics_skincare;
      case 'cosmetics_handcare':
        return AppLocalizations.of(context)!.cosmetics_handcare;
      case 'food_health_food':
        return AppLocalizations.of(context)!.food_health_food;
      case 'cosmetics_cleansing':
        return AppLocalizations.of(context)!.cosmetics_cleansing;
      case 'cosmetics_mask':
        return AppLocalizations.of(context)!.cosmetics_mask;
      case 'food_diet_food':
        return AppLocalizations.of(context)!.food_diet_food;
      default:
        return category;
    }
  }

  Widget _buildTagBox(BuildContext context, String category, int index) {
    return GestureDetector(
      onTap: () => onCategoryTap(
        category,
        _getCategoryTranslation(context, category),
        false,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: pastelColors[index % pastelColors.length],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getCategoryTranslation(context, category),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'cosmetics_haircare',
      'cosmetics_skincare',
      'cosmetics_handcare',
      'food_health_food',
      'cosmetics_cleansing',
      'cosmetics_mask',
      'food_diet_food',
    ];

    return SizedBox(
      width: double.infinity, // 전체 너비 사용
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.popular_category_section_title,
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
                  AppLocalizations.of(context)!
                      .popular_category_section_subtitle,
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
          const SizedBox(height: 16),
          // Tag boxes in white background container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardBoxShadow,
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                categories.length,
                (index) => _buildTagBox(context, categories[index], index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
