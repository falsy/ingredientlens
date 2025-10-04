import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/calorie_service.dart';
import '../models/calorie_entry.dart';
import '../models/calorie_analysis_result.dart';
import '../screens/calorie_result_screen.dart';
import '../l10n/app_localizations.dart';

class TodayCaloriesSectionWidget extends StatefulWidget {
  const TodayCaloriesSectionWidget({super.key});

  @override
  State<TodayCaloriesSectionWidget> createState() =>
      _TodayCaloriesSectionWidgetState();
}

class _TodayCaloriesSectionWidgetState
    extends State<TodayCaloriesSectionWidget> {
  List<CalorieEntry> _todayEntries = [];
  double _totalCalories = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayCalories();
  }

  @override
  void didUpdateWidget(TodayCaloriesSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 강제로 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayCalories();
    });
  }

  Future<void> _loadTodayCalories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await CalorieService.instance.getTodayCalorieEntries();
      final total = await CalorieService.instance.getTodayTotalCalories();

      setState(() {
        _todayEntries = entries;
        _totalCalories = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getMealTypeDisplayName(String mealType) {
    final l10n = AppLocalizations.of(context)!;
    switch (mealType) {
      case 'main_meal':
        return l10n.meal_type_main_meal;
      case 'snack':
        return l10n.meal_type_snack;
      case 'late_night':
        return l10n.meal_type_late_night;
      default:
        return mealType;
    }
  }

  void _navigateToEditScreen(CalorieEntry entry) {
    // 선택된 엔트리를 분석 결과로 변환
    final analysisResult = _convertEntryToAnalysisResult(entry);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalorieResultScreen(
          analysisResult: analysisResult,
          isEditMode: true,
          existingEntries: [entry], // 선택된 엔트리만 전달
          onEntriesUpdated: _loadTodayCalories,
        ),
      ),
    );
  }

  CalorieAnalysisResult _convertEntryToAnalysisResult(CalorieEntry entry) {
    List<CalorieFood> foods = [];

    for (CalorieFoodItem foodItem in entry.foods) {
      foods.add(CalorieFood(
        name: foodItem.name,
        estimatedAmount: foodItem.estimatedAmount,
        calories: foodItem.calories,
        nutrition: Nutrition(
          protein: foodItem.nutrition.protein,
          fat: foodItem.nutrition.fat,
          carbohydrate: foodItem.nutrition.carbohydrate,
          sodium: foodItem.nutrition.sodium,
          sugar: foodItem.nutrition.sugar,
          transFat: foodItem.nutrition.transFat,
          saturatedFat: foodItem.nutrition.saturatedFat,
          cholesterol: foodItem.nutrition.cholesterol,
        ),
      ));
    }

    return CalorieAnalysisResult(foods: foods);
  }

  Widget _buildCalorieEntryItem(CalorieEntry entry, {bool isLast = false}) {
    return GestureDetector(
      onTap: () => _navigateToEditScreen(entry),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.cardBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 음식 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getMealTypeDisplayName(entry.mealType),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.mainFoodName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 칼로리 정보
            Row(
              children: [
                Text(
                  '${entry.totalCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.gray600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
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
          AppLocalizations.of(context)!.no_calories_today,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.gray600,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .today_calories_section_title,
                      style: const TextStyle(
                        color: AppTheme.sectionTitleColor,
                        fontSize: AppTheme.sectionTitleFontSize,
                        fontWeight: AppTheme.sectionTitleFontWeight,
                        height: AppTheme.sectionTitleLineHeight,
                      ),
                    ),
                    if (!_isLoading && _todayEntries.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${AppLocalizations.of(context)!.total_calories} ${_totalCalories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // Section Subtitle
                Text(
                  AppLocalizations.of(context)!.today_calories_section_subtitle,
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

          // 콘텐츠
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardBoxShadow,
            ),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : _todayEntries.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          ..._todayEntries
                              .take(5)
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final calorie = entry.value;
                            final isLast =
                                index == (_todayEntries.take(5).length - 1) &&
                                    _todayEntries.length <= 5;
                            return _buildCalorieEntryItem(calorie,
                                isLast: isLast);
                          }),
                          if (_todayEntries.length > 5)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Text(
                                AppLocalizations.of(context)!.more_items_count(
                                    (_todayEntries.length - 5).toString()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.gray600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
