import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/recent_result.dart';
import '../models/category.dart';
import '../services/localization_service.dart';
import '../utils/theme.dart';

class RecentResultsSectionWidget extends StatelessWidget {
  final List<RecentResult> recentResults;
  final String Function(DateTime) formatDateTime;
  final Function(RecentResult) onResultTap;
  final Function(RecentResult) onDeleteTap;

  const RecentResultsSectionWidget({
    super.key,
    required this.recentResults,
    required this.formatDateTime,
    required this.onResultTap,
    required this.onDeleteTap,
  });

  String _getCategoryDisplayName(BuildContext context, String category) {
    // Check if it's a predefined category
    final predefinedCategory = categories.firstWhere(
      (cat) => cat.id == category,
      orElse: () => const Category(id: '', nameKey: '', iconPath: ''),
    );

    if (predefinedCategory.id.isNotEmpty) {
      // It's a predefined category, return translated name
      return AppLocalizations.of(context)!
          .translate(predefinedCategory.nameKey);
    } else {
      // It's a custom category, return as is
      return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          AppLocalizations.of(context)!.translate('recent_results_title'),
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
          AppLocalizations.of(context)!.translate('recent_results_subtitle'),
          style: const TextStyle(
            color: AppTheme.sectionSubtitleColor,
            fontSize: AppTheme.sectionSubtitleFontSize,
            fontWeight: AppTheme.sectionSubtitleFontWeight,
            height: AppTheme.sectionSubtitleLineHeight,
          ),
        ),
        const SizedBox(height: 20),

        // Recent Results Content
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          child: recentResults.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('no_recent_results'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.gray500,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: recentResults.map((result) {
                    return GestureDetector(
                      onTap: () => onResultTap(result),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.cardBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon
                            SvgPicture.asset(
                              result.type == 'analysis'
                                  ? 'assets/icons/analytics.svg'
                                  : 'assets/icons/compare.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppTheme.blackColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 18),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category name (translated)
                                  Text(
                                    _getCategoryDisplayName(
                                        context, result.category),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.blackColor,
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // Overall review
                                  Text(
                                    result.overallReview,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.gray700,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

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
