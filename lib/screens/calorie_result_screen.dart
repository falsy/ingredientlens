import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../models/calorie_analysis_result.dart';
import '../models/calorie_entry.dart';
import '../services/calorie_service.dart';
import '../services/analytics_service.dart';
import '../utils/theme.dart';

class CalorieResultScreen extends StatefulWidget {
  final CalorieAnalysisResult analysisResult;
  final bool isEditMode;
  final List<CalorieEntry>? existingEntries;
  final VoidCallback? onEntriesUpdated;

  const CalorieResultScreen({
    super.key,
    required this.analysisResult,
    this.isEditMode = false,
    this.existingEntries,
    this.onEntriesUpdated,
  });

  @override
  State<CalorieResultScreen> createState() => _CalorieResultScreenState();
}

class _CalorieResultScreenState extends State<CalorieResultScreen> {
  bool _isSaving = false;
  String _selectedMealType = 'main_meal';
  late List<EditableFood> _editableFoods;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();

    // 수정 모드인 경우 기존 엔트리의 데이터 사용
    if (widget.isEditMode &&
        widget.existingEntries != null &&
        widget.existingEntries!.isNotEmpty) {
      final existingEntry = widget.existingEntries!.first;
      _selectedDateTime = existingEntry.date;
      _selectedMealType = existingEntry.mealType;

      // 기존 엔트리의 음식 데이터를 EditableFood로 변환
      _editableFoods = existingEntry.foods
          .map((food) => EditableFood(
                name: food.name,
                estimatedAmount: food.estimatedAmount,
                quantity: food.quantity,
                unitCalories: food.calories,
                nutrition: food.nutrition,
              ))
          .toList();
    } else {
      // 새로운 엔트리인 경우 API 결과 데이터 사용
      _editableFoods = widget.analysisResult.foods
          .map((food) => EditableFood(
                name: food.name,
                estimatedAmount: food.estimatedAmount,
                quantity: 1.0,
                unitCalories: food.calories,
                nutrition: NutritionItem(
                  protein: food.nutrition.protein,
                  fat: food.nutrition.fat,
                  carbohydrate: food.nutrition.carbohydrate,
                  sodium: food.nutrition.sodium,
                  sugar: food.nutrition.sugar,
                  transFat: food.nutrition.transFat,
                  saturatedFat: food.nutrition.saturatedFat,
                  cholesterol: food.nutrition.cholesterol,
                ),
              ))
          .toList();
      _selectedDateTime = DateTime.now();
    }
  }

  double get _totalCalories {
    return _editableFoods.fold(
        0.0, (sum, food) => sum + (food.unitCalories * food.quantity));
  }

  // 총 영양성분 계산
  Map<String, double> get _totalNutrition {
    return _editableFoods.fold<Map<String, double>>({
      'protein': 0.0,
      'fat': 0.0,
      'carbohydrate': 0.0,
      'sodium': 0.0,
      'sugar': 0.0,
      'transFat': 0.0,
      'saturatedFat': 0.0,
      'cholesterol': 0.0,
    }, (totals, food) {
      final quantity = food.quantity;
      totals['protein'] =
          totals['protein']! + (food.nutrition.protein * quantity);
      totals['fat'] = totals['fat']! + (food.nutrition.fat * quantity);
      totals['carbohydrate'] =
          totals['carbohydrate']! + (food.nutrition.carbohydrate * quantity);
      totals['sodium'] = totals['sodium']! + (food.nutrition.sodium * quantity);
      totals['sugar'] = totals['sugar']! + (food.nutrition.sugar * quantity);
      totals['transFat'] =
          totals['transFat']! + (food.nutrition.transFat * quantity);
      totals['saturatedFat'] =
          totals['saturatedFat']! + (food.nutrition.saturatedFat * quantity);
      totals['cholesterol'] =
          totals['cholesterol']! + (food.nutrition.cholesterol * quantity);
      return totals;
    });
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

  Future<void> _saveCalorieEntry() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // 수정된 데이터로 CalorieFoodItem 배열 생성
      final foodItems = _editableFoods
          .map((food) => CalorieFoodItem(
                name: food.name,
                estimatedAmount: food.estimatedAmount,
                calories: food.unitCalories,
                quantity: food.quantity,
                nutrition: food.nutrition,
              ))
          .toList();

      final entry = CalorieEntry(
        analysisId: DateTime.now().millisecondsSinceEpoch.toString(),
        foods: foodItems,
        mealType: _selectedMealType,
        date: _selectedDateTime,
        createdAt: DateTime.now(),
      );

      final success = await CalorieService.instance.addCalorieEntry(entry);

      if (success && mounted) {
        // Analytics: 칼로리 저장 이벤트
        double totalCalories = 0;
        for (var food in _editableFoods) {
          totalCalories += food.unitCalories * food.quantity;
        }

        await AnalyticsService.logCalorieSaved(
          mealType: _selectedMealType,
          totalCalories: totalCalories,
          foodCount: _editableFoods.length,
        );

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.calorie_saved),
            backgroundColor: AppTheme.primaryColor,
          ),
        );

        // 수정 모드인 경우 기존 엔트리 삭제 후 새로 저장
        if (widget.isEditMode && widget.existingEntries != null) {
          // 기존 엔트리들 삭제
          for (CalorieEntry oldEntry in widget.existingEntries!) {
            if (oldEntry.id != null) {
              await CalorieService.instance.removeCalorieEntry(oldEntry.id!);
            }
          }
        }

        if (widget.isEditMode && widget.onEntriesUpdated != null) {
          widget.onEntriesUpdated!();
          Navigator.pop(context);
        } else {
          // 메인 화면으로 돌아가기
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .save_failed_with_error(e.toString())),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildFoodItem(EditableFood food, int index) {
    final totalCalories = food.unitCalories * food.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 음식 이름과 단위
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditFoodNameBottomSheet(food, index),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.blackColor,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                            size: 14,
                            color: AppTheme.gray500,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.per_unit(
                          food.estimatedAmount,
                          food.unitCalories.toStringAsFixed(0)),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 수량 조절과 칼로리 표시
          Row(
            children: [
              // 수량 감소 버튼
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: food.quantity > 0.5
                      ? () {
                          setState(() {
                            _editableFoods[index].quantity =
                                (food.quantity - 0.5).clamp(0.5, 10.0);
                          });
                        }
                      : null,
                  icon: const Icon(
                    Icons.remove,
                    size: 18,
                    color: AppTheme.blackColor,
                  ),
                ),
              ),

              // 수량 표시
              Container(
                width: 40,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Text(
                    food.quantity == food.quantity.roundToDouble()
                        ? '${food.quantity.round()}'
                        : food.quantity.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blackColor,
                    ),
                  ),
                ),
              ),

              // 수량 증가 버튼
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _editableFoods[index].quantity =
                          (food.quantity + 0.5).clamp(0.5, 10.0);
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: AppTheme.blackColor,
                  ),
                ),
              ),

              const Spacer(),

              // 칼로리 직접 입력 가능
              GestureDetector(
                onTap: () => _showCalorieEditDialog(index, totalCalories),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${totalCalories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.edit,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCalorieEditDialog(int index, double currentCalories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CalorieEditBottomSheet(
        foodName: _editableFoods[index].name,
        currentCalories: currentCalories,
        onSave: (newCalories) {
          _updateCalories(index, newCalories.toString());
        },
      ),
    );
  }

  void _showEditFoodNameBottomSheet(EditableFood food, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FoodNameEditBottomSheet(
        currentName: food.name,
        onSave: (newName) {
          _updateFoodName(index, newName);
        },
      ),
    );
  }

  void _updateCalories(int index, String value) {
    final newCalories = double.tryParse(value);
    if (newCalories != null && newCalories > 0) {
      setState(() {
        // 새로운 칼로리를 기준으로 단위당 칼로리 재계산
        _editableFoods[index].unitCalories =
            newCalories / _editableFoods[index].quantity;
      });
    }
  }

  void _updateFoodName(int index, String newName) {
    if (newName.trim().isNotEmpty) {
      setState(() {
        _editableFoods[index].name = newName.trim();
      });
    }
  }

  void _showDeleteConfirmDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteConfirmBottomSheet(
        onConfirm: () {
          Navigator.pop(context);
          _deleteAllTodayEntries();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _deleteAllTodayEntries() async {
    if (!widget.isEditMode || widget.existingEntries == null) return;

    try {
      for (CalorieEntry entry in widget.existingEntries!) {
        if (entry.id != null) {
          await CalorieService.instance.removeCalorieEntry(entry.id!);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('칼로리가 삭제되었습니다'),
        //     backgroundColor: AppTheme.primaryColor,
        //   ),
        // );

        // 콜백 호출 후 뒤로 가기
        if (widget.onEntriesUpdated != null) {
          widget.onEntriesUpdated!();
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.delete_error),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.calorie_analysis_result,
            style: const TextStyle(
              color: AppTheme.blackColor,
              fontSize: AppTheme.appBarTitleFontSize,
              fontWeight: AppTheme.appBarTitleFontWeight,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFF8F9FA), // 연한 회색
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 총 칼로리 표시
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4ECDC4), // 옥색
                        Color(0xFF7FD18C), // 연두색
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.total_calories,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_totalCalories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 식사 종류 선택
                Text(
                  AppLocalizations.of(context)!.meal_type,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.blackColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardBoxShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMealTypeButton('main_meal'),
                      ),
                      Expanded(
                        child: _buildMealTypeButton('snack'),
                      ),
                      Expanded(
                        child: _buildMealTypeButton('late_night'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 날짜 및 시간 선택
                Text(
                  AppLocalizations.of(context)!.date_and_time,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.blackColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDateTimeSelector(),
                const SizedBox(height: 24),

                // 음식 목록
                Text(
                  AppLocalizations.of(context)!.food_detail,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.blackColor,
                  ),
                ),
                const SizedBox(height: 12),
                ..._editableFoods
                    .asMap()
                    .entries
                    .map((entry) => _buildFoodItem(entry.value, entry.key)),

                const SizedBox(height: 24),

                // 영양성분 정보
                _buildNutritionSummary(),
                const SizedBox(height: 28),

                // 삭제 버튼 (수정 모드일 때만 표시, 여백도 함께)
                if (widget.isEditMode) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _showDeleteConfirmDialog,
                      child: Text(
                        AppLocalizations.of(context)!.delete_item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 140, 100, 5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ],
            ),
          ),
        ),

        // 하단 버튼들 - 닫기와 저장 버튼
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 닫기 버튼
                Expanded(
                  child: SizedBox(
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      style: AppTheme.getButtonStyle('cancel'),
                      child: Text(
                        AppLocalizations.of(context)!.close,
                        style: AppTheme.getButtonTextStyle(
                          color: AppTheme.buttonColors['cancel']!['text'],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 저장 버튼
                Expanded(
                  child: SizedBox(
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveCalorieEntry,
                      style: AppTheme.getButtonStyle('action'),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppTheme.whiteColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.save,
                              style: AppTheme.getButtonTextStyle(),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardBoxShadow,
      ),
      child: Column(
        children: [
          // 날짜 선택
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppTheme.gray600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 시간 선택
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _showTimePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppTheme.gray600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2040, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              contentTextStyle: TextStyle(fontSize: 16),
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            ),
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.blackColor,
              // 헤더 배경색과 텍스트 색상 (상단 날짜 선택 부분)
              surfaceVariant: AppTheme.primaryColor,
              onSurfaceVariant: Colors.white,
            ),
            // 날짜 선택기 헤더 스타일 직접 제어
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppTheme.primaryColor,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              headerHelpStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent, // 헤더 아래 구분선 제거
              confirmButtonStyle: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.fromLTRB(20, 12, 20, 20),
                ),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              cancelButtonStyle: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.fromLTRB(20, 12, 20, 20),
                ),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              contentTextStyle: TextStyle(fontSize: 16),
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            ),
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.blackColor,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: AppTheme.blackColor,
              hourMinuteColor: Colors.transparent,
              dialHandColor: AppTheme.primaryColor,
              dialBackgroundColor: Color(0xFFF5F5F5),
              dialTextColor: AppTheme.blackColor,
              entryModeIconColor: AppTheme.primaryColor,
              dayPeriodTextColor: AppTheme.blackColor,
              dayPeriodColor: AppTheme.primaryColor, // 선택된 오전/오후 배경을 옥색으로
              dayPeriodBorderSide: BorderSide.none, // 구분선 제거
              confirmButtonStyle: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.fromLTRB(20, 12, 20, 20),
                ),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              cancelButtonStyle: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.fromLTRB(20, 12, 20, 20),
                ),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Widget _buildMealTypeButton(String type) {
    final isSelected = _selectedMealType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMealType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            _getMealTypeDisplayName(type),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppTheme.primaryColor : AppTheme.gray600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSummary() {
    final nutrition = _totalNutrition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.nutrition_info,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.cardBoxShadow,
          ),
          child: Column(
            children: [
              _buildNutritionItem(AppLocalizations.of(context)!.protein,
                  nutrition['protein']!, 'g'),
              _buildNutritionItem(
                  AppLocalizations.of(context)!.fat, nutrition['fat']!, 'g'),
              _buildNutritionItem(AppLocalizations.of(context)!.carbohydrate,
                  nutrition['carbohydrate']!, 'g'),
              _buildNutritionItem(AppLocalizations.of(context)!.sodium,
                  nutrition['sodium']!, 'mg'),
              _buildNutritionItem(AppLocalizations.of(context)!.sugar,
                  nutrition['sugar']!, 'g'),
              _buildNutritionItem(AppLocalizations.of(context)!.trans_fat,
                  nutrition['transFat']!, 'g'),
              _buildNutritionItem(AppLocalizations.of(context)!.saturated_fat,
                  nutrition['saturatedFat']!, 'g'),
              _buildNutritionItem(AppLocalizations.of(context)!.cholesterol,
                  nutrition['cholesterol']!, 'mg',
                  isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionItem(String name, double value, String unit,
      {bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: AppTheme.dividerColor.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// 수정 가능한 음식 데이터 클래스
class EditableFood {
  String name; // final 제거하여 수정 가능하게 함
  final String estimatedAmount;
  double quantity;
  double unitCalories; // final 제거하여 수정 가능하게 함
  final NutritionItem nutrition;

  EditableFood({
    required this.name,
    required this.estimatedAmount,
    required this.quantity,
    required this.unitCalories,
    required this.nutrition,
  });
}

// 칼로리 수정 바텀시트
class _CalorieEditBottomSheet extends StatefulWidget {
  final String foodName;
  final double currentCalories;
  final Function(double) onSave;

  const _CalorieEditBottomSheet({
    required this.foodName,
    required this.currentCalories,
    required this.onSave,
  });

  @override
  State<_CalorieEditBottomSheet> createState() =>
      _CalorieEditBottomSheetState();
}

class _CalorieEditBottomSheetState extends State<_CalorieEditBottomSheet> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentCalories.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_controller.text);
    if (value == null || value < 0) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.valid_calorie_error;
      });
      return;
    }

    widget.onSave(value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title (음식 이름)
            Text(
              widget.foodName,
              style: const TextStyle(
                color: AppTheme.blackColor,
                fontSize: AppTheme.bottomSheetTitleFontSize,
                fontWeight: AppTheme.bottomSheetTitleFontWeight,
                height: AppTheme.bottomSheetTitleLineHeight,
              ),
            ),
            const SizedBox(height: 18),

            // 칼로리 입력 필드
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.cardBorderColor,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enter_calorie,
                  hintStyle: const TextStyle(
                    color: AppTheme.gray500,
                    fontSize: 14,
                  ),
                  suffixText: 'kcal',
                  suffixStyle: TextStyle(
                    color: AppTheme.gray600,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(
                  color: AppTheme.blackColor,
                  fontSize: 14,
                ),
                onSubmitted: (_) => _save(),
              ),
            ),
            const SizedBox(height: 8),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.negativeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.negativeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppTheme.negativeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ] else ...[
              const SizedBox(height: 14),
            ],

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppTheme.getButtonStyle('cancel'),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: AppTheme.getButtonTextStyle(
                        color: AppTheme.buttonColors['cancel']!['text'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: AppTheme.getButtonStyle('action'),
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: AppTheme.getButtonTextStyle(),
                    ),
                  ),
                ),
              ],
            ),

            // 하단 SafeArea 확보
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// 음식 이름 수정 바텀시트
class _FoodNameEditBottomSheet extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;

  const _FoodNameEditBottomSheet({
    required this.currentName,
    required this.onSave,
  });

  @override
  State<_FoodNameEditBottomSheet> createState() =>
      _FoodNameEditBottomSheetState();
}

class _FoodNameEditBottomSheetState extends State<_FoodNameEditBottomSheet> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
    // 전체 텍스트 선택
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.food_name_error;
      });
      return;
    }

    widget.onSave(value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              AppLocalizations.of(context)!.food_name_edit,
              style: const TextStyle(
                color: AppTheme.blackColor,
                fontSize: AppTheme.bottomSheetTitleFontSize,
                fontWeight: AppTheme.bottomSheetTitleFontWeight,
                height: AppTheme.bottomSheetTitleLineHeight,
              ),
            ),
            const SizedBox(height: 18),

            // 음식 이름 입력 필드
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.cardBorderColor,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enter_food_name,
                  hintStyle: const TextStyle(
                    color: AppTheme.gray500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(
                  color: AppTheme.blackColor,
                  fontSize: 14,
                ),
                onSubmitted: (_) => _save(),
              ),
            ),
            const SizedBox(height: 8),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.negativeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.negativeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppTheme.negativeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ] else ...[
              const SizedBox(height: 14),
            ],

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppTheme.getButtonStyle('cancel'),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: AppTheme.getButtonTextStyle(
                        color: AppTheme.buttonColors['cancel']!['text'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: AppTheme.getButtonStyle('action'),
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: AppTheme.getButtonTextStyle(),
                    ),
                  ),
                ),
              ],
            ),

            // 하단 SafeArea 확보
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// 삭제 확인 바텀시트
class _DeleteConfirmBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteConfirmBottomSheet({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Text(
                AppLocalizations.of(context)!.delete_calorie,
                style: const TextStyle(
                  color: AppTheme.blackColor,
                  fontSize: AppTheme.bottomSheetTitleFontSize,
                  fontWeight: AppTheme.bottomSheetTitleFontWeight,
                  height: AppTheme.bottomSheetTitleLineHeight,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style: AppTheme.getButtonStyle('cancel'),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: AppTheme.getButtonTextStyle(
                        color: AppTheme.buttonColors['cancel']!['text'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: AppTheme.getButtonStyle('action'),
                    child: Text(
                      AppLocalizations.of(context)!.delete,
                      style: AppTheme.getButtonTextStyle(type: 'action'),
                    ),
                  ),
                ),
              ],
            ),

            // 하단 SafeArea 확보
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
