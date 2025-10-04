import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/calorie_service.dart';
import '../screens/daily_calories_detail_screen.dart';

class WeeklyCaloriesSectionWidget extends StatefulWidget {
  const WeeklyCaloriesSectionWidget({super.key});

  @override
  State<WeeklyCaloriesSectionWidget> createState() =>
      _WeeklyCaloriesSectionWidgetState();
}

class _WeeklyCaloriesSectionWidgetState
    extends State<WeeklyCaloriesSectionWidget> {
  Map<String, double> _weeklyCalories = {};
  Map<String, bool> _hasEntries = {}; // 각 날짜에 엔트리가 있는지 확인
  double _averageDailyCalories = 0.0;
  bool _isLoading = true;
  DateTime _currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setCurrentWeekStart();
    _loadWeeklyCalories();
  }

  void _setCurrentWeekStart() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    // 시간을 00:00:00으로 정규화
    _currentWeekStart =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
  }

  @override
  void didUpdateWidget(WeeklyCaloriesSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 강제로 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeeklyCalories();
    });
  }

  Future<void> _loadWeeklyCalories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dailyCalories =
          await CalorieService.instance.getWeekDailyCalories(_currentWeekStart);
      dailyCalories.values.fold(0.0, (sum, calories) => sum + calories);

      // 각 날짜의 엔트리 존재 여부 확인
      final hasEntries = <String, bool>{};
      for (int i = 0; i < 7; i++) {
        final date = _currentWeekStart.add(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final entries = await CalorieService.instance.getDayCalorieEntries(date);
        hasEntries[dateStr] = entries.isNotEmpty;
      }

      // 일평균 칼로리 계산
      final averageDaily = _calculateAverageDailyCalories(dailyCalories);

      setState(() {
        _weeklyCalories = dailyCalories;
        _hasEntries = hasEntries;
        _averageDailyCalories = averageDaily;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateAverageDailyCalories(Map<String, double> dailyCalories) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = DateTime(
        _currentWeekStart.year, _currentWeekStart.month, _currentWeekStart.day);
    final weekEnd = weekStart.add(const Duration(days: 6));

    // 현재 주인지 확인
    final isCurrentWeek =
        today.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            today.isBefore(weekEnd.add(const Duration(days: 1)));

    if (isCurrentWeek) {
      // 현재 주인 경우: 월요일부터 오늘까지
      double totalCalories = 0.0;
      int dayCount = 0;

      for (int i = 0; i <= today.difference(weekStart).inDays; i++) {
        final date = weekStart.add(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final calories = dailyCalories[dateStr] ?? 0.0;
        if (calories > 0) {
          totalCalories += calories;
          dayCount++;
        }
      }

      return dayCount > 0 ? totalCalories / dayCount : 0.0;
    } else {
      // 과거 주인 경우: 전체 7일 평균
      double totalCalories = 0.0;
      int dayCount = 0;

      for (final calories in dailyCalories.values) {
        if (calories > 0) {
          totalCalories += calories;
          dayCount++;
        }
      }

      return dayCount > 0 ? totalCalories / dayCount : 0.0;
    }
  }

  void _navigateToPreviousWeek() {
    setState(() {
      final prevWeek = _currentWeekStart.subtract(const Duration(days: 7));
      _currentWeekStart = DateTime(prevWeek.year, prevWeek.month, prevWeek.day);
    });
    _loadWeeklyCalories();
  }

  void _navigateToNextWeek() {
    setState(() {
      final nextWeek = _currentWeekStart.add(const Duration(days: 7));
      _currentWeekStart = DateTime(nextWeek.year, nextWeek.month, nextWeek.day);
    });
    _loadWeeklyCalories();
  }

  List<String> _getWeekDays() {
    return List.generate(7, (index) {
      final date = _currentWeekStart.add(Duration(days: index));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });
  }

  String _getWeekDateRange() {
    final endOfWeek = _currentWeekStart.add(const Duration(days: 6));
    final startMonth = _currentWeekStart.month;
    final endMonth = endOfWeek.month;

    if (startMonth == endMonth) {
      return '${_currentWeekStart.month}/${_currentWeekStart.day} - ${endOfWeek.day}';
    } else {
      return '${_currentWeekStart.month}/${_currentWeekStart.day} - ${endOfWeek.month}/${endOfWeek.day}';
    }
  }

  String _getDayLabel(String dateStr) {
    final date = DateTime.parse(dateStr);
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
    return weekdays[date.weekday - 1];
  }

  Widget _buildDayCaloriesItem(String dateStr, double calories) {
    final dayLabel = _getDayLabel(dateStr);
    final maxCalories = _weeklyCalories.values.isNotEmpty
        ? _weeklyCalories.values.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final progress = maxCalories > 0 ? calories / maxCalories : 0.0;
    final date = DateTime.parse(dateStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // 요일 라벨
          SizedBox(
            width: 40,
            child: Text(
              dayLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.gray700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 프로그레스 바 (클릭 가능 - 내역이 있을 때만)
          Expanded(
            child: GestureDetector(
              onTap: (_hasEntries[dateStr] == true)
                  ? () {
                      // 해당 날짜의 상세 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DailyCaloriesDetailScreen(
                            date: date,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    if (progress > 0)
                      SizedBox(
                        width: double.infinity,
                        height: 20,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4ECDC4), // 옥색
                                  Color(0xFF7FD18C), // 연두색
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        calories > 0
                            ? '${calories.toStringAsFixed(0)} kcal'
                            : '0 kcal',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.gray700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getWeekDays();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.weekly_calories_section_title,
                    style: const TextStyle(
                      color: AppTheme.sectionTitleColor,
                      fontSize: AppTheme.sectionTitleFontSize,
                      fontWeight: AppTheme.sectionTitleFontWeight,
                      height: AppTheme.sectionTitleLineHeight,
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      // 지난주 버튼
                      GestureDetector(
                        onTap: _navigateToPreviousWeek,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: const Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ),
                      // 다음주 버튼
                      GestureDetector(
                        onTap: _navigateToNextWeek,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.weekly_calories_section_subtitle,
                style: const TextStyle(
                  color: AppTheme.sectionSubtitleColor,
                  fontSize: AppTheme.sectionSubtitleFontSize,
                  fontWeight: AppTheme.sectionSubtitleFontWeight,
                  height: AppTheme.sectionSubtitleLineHeight,
                ),
              ),
            ]),
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
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 범위 표시와 일평균 칼로리
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getWeekDateRange(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.gray600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!_isLoading && _averageDailyCalories > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .daily_average_calories(
                                        _averageDailyCalories
                                            .toStringAsFixed(0)),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 주간 칼로리 차트
                      ..._getWeekDays().map((dateStr) {
                        final calories = _weeklyCalories[dateStr] ?? 0.0;
                        return _buildDayCaloriesItem(dateStr, calories);
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
