import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/calorie_service.dart';
import '../models/calorie_entry.dart';

class MonthlyCalorieReportScreen extends StatefulWidget {
  const MonthlyCalorieReportScreen({super.key});

  @override
  State<MonthlyCalorieReportScreen> createState() =>
      _MonthlyCalorieReportScreenState();
}

class _MonthlyCalorieReportScreenState
    extends State<MonthlyCalorieReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<int, double> _dailyCalories = {};
  bool _isLoading = true;
  double _maxCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 모든 칼로리 엔트리 가져오기
      final entries = await CalorieService.instance.getAllCalorieEntries();

      // 선택된 월의 데이터만 필터링하고 일별로 합산
      final monthlyData = <int, double>{};

      for (final entry in entries) {
        if (entry.date.year == _selectedMonth.year &&
            entry.date.month == _selectedMonth.month) {
          final day = entry.date.day;

          // 해당 날짜의 총 칼로리 계산
          double dailyTotal = 0;
          for (final food in entry.foods) {
            dailyTotal += food.calories * food.quantity;
          }

          monthlyData[day] = (monthlyData[day] ?? 0) + dailyTotal;
        }
      }

      // 최대값 계산
      double max = 0;
      for (final entry in monthlyData.entries) {
        if (entry.value > max) {
          max = entry.value;
        }
      }

      setState(() {
        _dailyCalories = monthlyData;
        _maxCalories = max;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int direction) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + direction,
      );
    });
    _loadMonthlyData();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    final lastDayToShow = isCurrentMonth ? now.day : daysInMonth;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.monthly_calorie_report,
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: AppTheme.appBarTitleFontSize,
            fontWeight: AppTheme.appBarTitleFontWeight,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 월 선택 네비게이션 - 상단에 붙어있고 좌우 여백 없음
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackgroundColor,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.dividerColor,
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: AppTheme.dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _changeMonth(-1),
                          ),
                          Text(
                            '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.blackColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _selectedMonth.year ==
                                        DateTime.now().year &&
                                    _selectedMonth.month == DateTime.now().month
                                ? null
                                : () => _changeMonth(1),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 일별 칼로리 섹션
                          const Padding(
                            padding: EdgeInsets.only(left: 1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "일일 칼로리",
                                  style: TextStyle(
                                    color: AppTheme.sectionTitleColor,
                                    fontSize: AppTheme.sectionTitleFontSize,
                                    fontWeight: AppTheme.sectionTitleFontWeight,
                                    height: AppTheme.sectionTitleLineHeight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 일별 칼로리 차트
                          Container(
                            height: 250,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppTheme.cardBoxShadow,
                            ),
                            child: _dailyCalories.isEmpty
                                ? const Center(
                                    child: Text(
                                      '이번 달 기록이 없습니다',
                                      style: TextStyle(
                                        color: AppTheme.gray600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: _maxCalories * 1.2,
                                      minY: 0,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipColor: (group) =>
                                              Colors.black.withOpacity(0.8),
                                          tooltipPadding:
                                              const EdgeInsets.all(8),
                                          tooltipMargin: 8,
                                          getTooltipItem: (group, groupIndex,
                                                  rod, rodIndex) =>
                                              BarTooltipItem(
                                            '${rod.toY.toStringAsFixed(0)} kcal',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: _maxCalories > 0
                                            ? _maxCalories * 0.4
                                            : 1000,
                                        getDrawingHorizontalLine: (value) {
                                          return const FlLine(
                                            color: AppTheme.gray200,
                                            strokeWidth: 1,
                                            dashArray: [5, 5],
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final day = value.toInt();
                                              // 3일 간격으로 표시 (1, 4, 7, 10, 13, 16, 19, 22, 25, 28...)
                                              // 마지막 날은 3일 간격에 해당할 때만 표시
                                              if (day == 1 || day % 3 == 1) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
                                                  child: Text(
                                                    day.toString(),
                                                    style: const TextStyle(
                                                      color: AppTheme.gray600,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                            reservedSize: 28,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 45,
                                            getTitlesWidget: (value, meta) {
                                              if (value == 0) {
                                                return const Text(
                                                  '0',
                                                  style: TextStyle(
                                                    color: AppTheme.gray600,
                                                    fontSize: 10,
                                                  ),
                                                );
                                              } else if (value ==
                                                  (_maxCalories * 1.2)
                                                      .round()) {
                                                return Text(
                                                  value.toInt().toString(),
                                                  style: const TextStyle(
                                                    color: AppTheme.gray600,
                                                    fontSize: 10,
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppTheme.blackColor
                                                .withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      barGroups:
                                          List.generate(lastDayToShow, (index) {
                                        final day = index + 1;
                                        final calories =
                                            _dailyCalories[day] ?? 0;
                                        return BarChartGroupData(
                                          x: day,
                                          barRods: [
                                            BarChartRodData(
                                              toY: calories,
                                              color: calories > 0
                                                  ? AppTheme.primaryColor
                                                  : Colors.transparent,
                                              width: 8,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                topRight: Radius.circular(4),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 36),

                          // 일평균 칼로리 섹션
                          const Padding(
                            padding: EdgeInsets.only(left: 1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "일평균 칼로리",
                                  style: TextStyle(
                                    color: AppTheme.sectionTitleColor,
                                    fontSize: AppTheme.sectionTitleFontSize,
                                    fontWeight: AppTheme.sectionTitleFontWeight,
                                    height: AppTheme.sectionTitleLineHeight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 일평균 칼로리 카드
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppTheme.cardBoxShadow,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '일평균 섭취 칼로리',
                                      style: TextStyle(
                                        color: AppTheme.gray600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  _dailyCalories.isEmpty
                                      ? '0 kcal'
                                      : '${(_dailyCalories.values.where((cal) => cal > 0).fold(0.0, (sum, cal) => sum + cal) / _dailyCalories.values.where((cal) => cal > 0).length).toStringAsFixed(0)} kcal',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          const Padding(
                            padding: EdgeInsets.only(left: 1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "일별 칼로리",
                                  style: TextStyle(
                                    color: AppTheme.sectionTitleColor,
                                    fontSize: AppTheme.sectionTitleFontSize,
                                    fontWeight: AppTheme.sectionTitleFontWeight,
                                    height: AppTheme.sectionTitleLineHeight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppTheme.cardBoxShadow,
                            ),
                            child: _dailyCalories.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Text(
                                        '기록된 데이터가 없습니다',
                                        style: TextStyle(
                                          color: AppTheme.gray600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _dailyCalories.entries
                                        .toList()
                                        .reversed
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((mapEntry) {
                                      final index = mapEntry.key;
                                      final entry = mapEntry.value;
                                      final isLast =
                                          index == _dailyCalories.length - 1;
                                      return _buildDayListItem(
                                          entry.key, entry.value, isLast);
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // 하단 여백 추가
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDayListItem(int day, double calories, bool isLast) {
    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                weekday,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray600,
                ),
              ),
            ],
          ),
          Text(
            '${calories.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
