import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../models/recent_nutrition_result.dart';
import '../utils/theme.dart';
import '../utils/category_mapping_util.dart';

class RecentNutritionResultsSectionWidget extends StatelessWidget {
  final List<RecentNutritionResult> recentNutritionResults;
  final String Function(DateTime) formatDateTime;
  final Function(RecentNutritionResult) onResultTap;
  final Function(RecentNutritionResult) onDeleteTap;

  const RecentNutritionResultsSectionWidget({
    super.key,
    required this.recentNutritionResults,
    required this.formatDateTime,
    required this.onResultTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
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
                AppLocalizations.of(context)!.ingredient_recent_title,
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
                AppLocalizations.of(context)!.ingredient_recent_subtitle,
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

        const SizedBox(height: 12),
        // Recent Nutrition Results Content
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          child: recentNutritionResults.isEmpty
              ? Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardBoxShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.6,
                        child: Image.asset(
                          'assets/images/empty.webp',
                          width: 80,
                          height: 80,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .no_recent_nutrition_results,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.gray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                )
              : Column(
                  children: recentNutritionResults.map((result) {
                    return GestureDetector(
                      onTap: () => onResultTap(result),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: AppTheme.cardBoxShadow,
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Image.asset(
                              CategoryMappingUtil.getCategoryIconPath(
                                  result.category),
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 18),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Overall review
                                  Text(
                                    result.overallReview,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.blackColor,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // Date time
                                  Text(
                                    formatDateTime(result.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.gray500,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Delete button
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onDeleteTap(result),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppTheme.gray400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
