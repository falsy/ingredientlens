import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/recent_result.dart';
import '../services/localization_service.dart';
import '../utils/theme.dart';

class RecentResultsSectionWidget extends StatelessWidget {
  final List<RecentResult> recentResults;
  final String Function(DateTime) formatDateTime;
  final Function(RecentResult) onResultTap;

  const RecentResultsSectionWidget({
    super.key,
    required this.recentResults,
    required this.formatDateTime,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          AppLocalizations.of(context)!.translate('recent_results_title'),
          style: TextStyle(
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
          AppLocalizations.of(context)!.translate('recent_results_subtitle'),
          style: TextStyle(
            color: AppTheme.gray500,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),

        // Recent Results Content
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          child: recentResults.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('no_recent_results'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.gray500,
                        height: 1.2,
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
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
                            colorFilter: ColorFilter.mode(
                              AppTheme.blackColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category name
                                Text(
                                  result.category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
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
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.gray500,
                                    height: 1.1,
                                  ),
                                ),
                              ],
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
