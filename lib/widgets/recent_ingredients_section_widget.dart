import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/recent_ingredient.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../screens/ingredient_detail_screen.dart';
import '../utils/theme.dart';

class RecentIngredientsSectionWidget extends StatefulWidget {
  const RecentIngredientsSectionWidget({super.key});

  @override
  State<RecentIngredientsSectionWidget> createState() => _RecentIngredientsSectionWidgetState();
}

class _RecentIngredientsSectionWidgetState extends State<RecentIngredientsSectionWidget> {
  List<RecentIngredient> _recentIngredients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
            content: Text(AppLocalizations.of(context)!.translate('delete_success')),
            backgroundColor: AppTheme.positiveColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('delete_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.blackColor,
          ),
        ),
      );
    }

    if (_recentIngredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.cardBorderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppTheme.gray300,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.translate('no_recent_ingredients'),
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.gray500,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentIngredients.map((ingredient) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onIngredientTap(ingredient),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.cardBorderColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ingredient.ingredientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.blackColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _deleteIngredient(ingredient),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppTheme.gray500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ingredient.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.gray100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.translate(ingredient.category),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.gray500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(ingredient.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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