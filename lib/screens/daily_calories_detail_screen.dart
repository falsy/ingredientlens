import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/calorie_service.dart';
import '../models/calorie_entry.dart';
import '../models/calorie_analysis_result.dart';
import '../screens/calorie_result_screen.dart';

class DailyCaloriesDetailScreen extends StatefulWidget {
  final DateTime date;

  const DailyCaloriesDetailScreen({
    super.key,
    required this.date,
  });

  @override
  State<DailyCaloriesDetailScreen> createState() =>
      _DailyCaloriesDetailScreenState();
}

class _DailyCaloriesDetailScreenState extends State<DailyCaloriesDetailScreen> {
  List<CalorieEntry> _calorieEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyCalories();
  }

  Future<void> _loadDailyCalories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries =
          await CalorieService.instance.getDayCalorieEntries(widget.date);
      setState(() {
        _calorieEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final weekdays = [
      l10n.weekday_mon,
      l10n.weekday_tue,
      l10n.weekday_wed,
      l10n.weekday_thu,
      l10n.weekday_fri,
      l10n.weekday_sat,
      l10n.weekday_sun,
    ];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ($weekday)';
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
          onEntriesUpdated: _loadDailyCalories, // 새로고침 콜백
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

  Widget _buildCalorieEntryItem(CalorieEntry entry) {
    return GestureDetector(
      onTap: () => _navigateToEditScreen(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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

  double _getTotalCalories() {
    return _calorieEntries.fold(0.0, (sum, entry) => sum + entry.totalCalories);
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _getTotalCalories();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _formatDate(widget.date),
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Transform.rotate(
            angle: 3.141592653589793,
            child: Image.asset(
              'assets/images/icons/right-arrow.webp',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : Column(
              children: [
                // 총 칼로리 헤더
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4ECDC4), // 옥색
                        Color(0xFF7FD18C), // 연두색
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.daily_total_calories,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            totalCalories.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 칼로리 목록
                Expanded(
                  child: _calorieEntries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: AppTheme.gray300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.no_calories_today,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.gray600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _calorieEntries.length,
                          itemBuilder: (context, index) {
                            return _buildCalorieEntryItem(
                                _calorieEntries[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
