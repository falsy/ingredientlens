import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../models/recent_ingredient.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../screens/ingredient_detail_screen.dart';
import '../screens/home_screen.dart';
import '../utils/theme.dart';

class RecentIngredientsSectionWidget extends StatefulWidget {
  const RecentIngredientsSectionWidget({super.key});

  @override
  State<RecentIngredientsSectionWidget> createState() =>
      _RecentIngredientsSectionWidgetState();
}

class _RecentIngredientsSectionWidgetState
    extends State<RecentIngredientsSectionWidget> with RouteAware {
  List<RecentIngredient> _recentIngredients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentIngredients();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // HomeScreen에서 이미 RouteObserver를 사용하고 있으므로 동일한 observer 사용
      HomeScreen.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    HomeScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때 갱신
    _loadRecentIngredients();
  }

  Future<void> _loadRecentIngredients() async {
    try {
      final ingredients = await DatabaseService().getRecentIngredients();
      if (mounted) {
        setState(() {
          _recentIngredients = ingredients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onIngredientTap(RecentIngredient ingredient) {
    try {
      final resultData = jsonDecode(ingredient.resultData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IngredientDetailScreen(
            ingredientDetail: resultData,
            ingredientName: ingredient.ingredientName,
            category: ingredient.category,
            isNewSearch: false,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('analysis_failed'),
          ),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    }
  }

  void _deleteIngredient(RecentIngredient ingredient) async {
    try {
      await DatabaseService().deleteRecentIngredient(ingredient.id!);
      _loadRecentIngredients(); // 목록 새로고침
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.translate('delete_success')),
            backgroundColor: AppTheme.positiveColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.translate('delete_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          AppLocalizations.of(context)!.translate('recent_ingredients_title'),
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
              .translate('recent_ingredients_subtitle'),
          style: const TextStyle(
            color: AppTheme.sectionSubtitleColor,
            fontSize: AppTheme.sectionSubtitleFontSize,
            fontWeight: AppTheme.sectionSubtitleFontWeight,
            height: AppTheme.sectionSubtitleLineHeight,
          ),
        ),
        const SizedBox(height: 20),

        // Recent Ingredients Content
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.blackColor,
                  ),
                )
              : _recentIngredients.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate('no_recent_ingredients'),
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
                      children: _recentIngredients.map((ingredient) {
                        return GestureDetector(
                          onTap: () => _onIngredientTap(ingredient),
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
                                  'assets/icons/bolt.svg',
                                  width: 26,
                                  height: 26,
                                  colorFilter: const ColorFilter.mode(
                                    AppTheme.blackColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 18),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Ingredient name
                                      Text(
                                        ingredient.ingredientName,
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
                                        _formatDate(ingredient.createdAt),
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
                                  onTap: () => _deleteIngredient(ingredient),
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

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return AppLocalizations.of(context)!.translate('time_days_ago', {
        'days': difference.inDays.toString(),
      });
    } else if (difference.inHours > 0) {
      return AppLocalizations.of(context)!.translate('time_hours_ago', {
        'hours': difference.inHours.toString(),
      });
    } else if (difference.inMinutes > 0) {
      return AppLocalizations.of(context)!.translate('time_minutes_ago', {
        'minutes': difference.inMinutes.toString(),
      });
    } else {
      return AppLocalizations.of(context)!.translate('time_just_now');
    }
  }
}
