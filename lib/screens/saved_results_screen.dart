import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../models/saved_result.dart';
import '../models/saved_ingredient.dart';
import 'analysis_result_screen.dart';
import 'comparison_result_screen.dart';
import 'ingredient_detail_screen.dart';
import '../widgets/delete_confirm_bottom_sheet.dart';

class SavedResultsScreen extends StatefulWidget {
  const SavedResultsScreen({super.key});

  @override
  State<SavedResultsScreen> createState() => _SavedResultsScreenState();
}

class _SavedResultsScreenState extends State<SavedResultsScreen>
    with SingleTickerProviderStateMixin {
  List<SavedResult> _savedResults = [];
  List<SavedIngredient> _savedIngredients = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedResults();
    _loadSavedIngredients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedResults() async {
    final results = await DatabaseService().getAllResults();
    if (mounted) {
      setState(() {
        _savedResults = results;
      });
    }
  }

  Future<void> _loadSavedIngredients() async {
    final ingredients = await DatabaseService().getAllIngredients();
    if (mounted) {
      setState(() {
        _savedIngredients = ingredients;
        _isLoading = false;
      });
    }
  }

  Future<void> _viewResult(SavedResult savedResult) async {
    try {
      final jsonData = jsonDecode(savedResult.responseData);

      if (savedResult.resultType == 'analysis') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              analysisResult: jsonData,
              category: savedResult.category,
              fromSavedResults: true,
            ),
          ),
        );
      } else if (savedResult.resultType == 'comparison') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComparisonResultScreen(
              comparisonResult: jsonData,
              category: savedResult.category,
              fromSavedResults: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.translate('analysis_failed')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  void _deleteResult(SavedResult savedResult) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => DeleteConfirmBottomSheet(
        itemToDelete: savedResult,
        onDeleted: _loadSavedResults,
      ),
    ).then((result) {
      if (result == true && mounted) {
        // 삭제 성공 시 처리는 bottom sheet에서 이미 했으므로 추가 작업 없음
      }
    });
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _viewIngredient(SavedIngredient savedIngredient) async {
    try {
      final jsonData = jsonDecode(savedIngredient.responseData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IngredientDetailScreen(
            ingredientDetail: jsonData,
            ingredientName: savedIngredient.ingredientName,
            category: savedIngredient.category,
            fromSavedResults: true,
            isNewSearch: false,
          ),
        ),
      ).then((_) {
        // 돌아왔을 때 데이터 새로고침
        _loadSavedIngredients();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.translate('analysis_failed')),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
    }
  }

  void _deleteIngredient(SavedIngredient savedIngredient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => DeleteConfirmBottomSheet(
        itemToDelete: savedIngredient,
        onDeleted: _loadSavedIngredients,
      ),
    );
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
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!
                .translate('saved_results')
                .toUpperCase(),
            style: const TextStyle(
              color: AppTheme.blackColor,
              fontSize: AppTheme.appBarTitleFontSize,
              fontWeight: AppTheme.appBarTitleFontWeight,
              letterSpacing: 0.4,
            ),
          ),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back,
                color: AppTheme.blackColor, size: 24),
          ),
        ),
        body: Column(
          children: [
            // Tab Bar
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.cardBorderColor,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.blackColor,
                unselectedLabelColor: AppTheme.gray500,
                indicatorColor: AppTheme.blackColor,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(
                      text:
                          AppLocalizations.of(context)!.translate('analysis')),
                  Tab(
                      text: AppLocalizations.of(context)!
                          .translate('ingredients')),
                ],
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 분석/비교 결과 탭
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.blackColor,
                          ),
                        )
                      : _savedResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bookmark.svg',
                                    width: 38,
                                    height: 38,
                                    colorFilter: const ColorFilter.mode(
                                      AppTheme.gray500,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('no_saved_results'),
                                    style: const TextStyle(
                                      color: AppTheme.gray500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: AppTheme.blackColor,
                              onRefresh: _loadSavedResults,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _savedResults.length,
                                itemBuilder: (context, index) {
                                  final savedResult = _savedResults[index];
                                  return GestureDetector(
                                    onTap: () => _viewResult(savedResult),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 12, 6, 12),
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
                                            savedResult.resultType == 'analysis'
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Category
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .translate(
                                                          savedResult.category),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppTheme.blackColor,
                                                    height: 1.1,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),

                                                // Name
                                                Text(
                                                  savedResult.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.gray700,
                                                    height: 1.2,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),

                                                // Date time
                                                Text(
                                                  _formatDate(
                                                      savedResult.createdAt),
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
                                          const SizedBox(width: 14),
                                          // Delete button
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () =>
                                                _deleteResult(savedResult),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: AppTheme.gray500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                  // 성분 검색 결과 탭
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.blackColor,
                          ),
                        )
                      : _savedIngredients.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 38,
                                    color: AppTheme.gray500,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('no_saved_ingredients'),
                                    style: const TextStyle(
                                      color: AppTheme.gray500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: AppTheme.blackColor,
                              onRefresh: _loadSavedIngredients,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _savedIngredients.length,
                                itemBuilder: (context, index) {
                                  final savedIngredient =
                                      _savedIngredients[index];
                                  return GestureDetector(
                                    onTap: () =>
                                        _viewIngredient(savedIngredient),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 12, 6, 12),
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
                                                // Ingredient Name
                                                Text(
                                                  savedIngredient
                                                      .ingredientName,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppTheme.blackColor,
                                                    height: 1.1,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),

                                                // Save Name
                                                Text(
                                                  savedIngredient.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.gray700,
                                                    height: 1.2,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),

                                                // Date time
                                                Text(
                                                  _formatDate(savedIngredient
                                                      .createdAt),
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
                                          const SizedBox(width: 14),
                                          // Delete button
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => _deleteIngredient(
                                                savedIngredient),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: AppTheme.gray500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}
