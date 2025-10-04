import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../utils/category_mapping_util.dart';
import '../services/database_service.dart';
import '../models/saved_result.dart';
import '../models/saved_ingredient.dart';
import 'analysis_result_screen.dart';
import 'comparison_result_screen.dart';
import 'nutrition_result_screen.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
      } else if (savedResult.resultType == 'nutrition') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NutritionResultScreen(
              nutritionResult: jsonData,
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
            content: Text(AppLocalizations.of(context)!.analysis_failed),
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
          content: Text(AppLocalizations.of(context)!.analysis_failed),
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
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.saved_analysis,
              style: const TextStyle(
                color: AppTheme.blackColor,
                fontSize: AppTheme.appBarTitleFontSize,
                fontWeight: AppTheme.appBarTitleFontWeight,
                letterSpacing: 0.4,
              ),
            ),
            backgroundColor: Colors.transparent,
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
              icon: Transform.rotate(
                angle: 3.141592653589793, // 180도 회전 (π 라디안)
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
          body: Column(
            children: [
              // Tab Bar
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.gray200,
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.blackColor,
                  unselectedLabelColor: AppTheme.gray500,
                  indicatorColor: AppTheme.blackColor,
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontSize: AppTheme.adjustFontSizeForPlatform(16),
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: AppTheme.adjustFontSizeForPlatform(16),
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.analysis),
                    Tab(text: AppLocalizations.of(context)!.nutrition_short),
                    Tab(text: AppLocalizations.of(context)!.ingredients),
                  ],
                ),
              ),
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 성분 분석/비교 결과 탭 (analysis, comparison)
                    _buildResultsList(['analysis', 'comparison']),
                    // 영양 분석 결과 탭 (nutrition)
                    _buildResultsList(['nutrition']),
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
                                    SvgPicture.asset(
                                      'assets/icons/bookmark.svg',
                                      width: 32,
                                      height: 32,
                                      colorFilter: const ColorFilter.mode(
                                        AppTheme.gray500,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .no_saved_ingredients,
                                      style: TextStyle(
                                        color: AppTheme.gray500,
                                        fontSize:
                                            AppTheme.adjustFontSizeForPlatform(
                                                14),
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
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 12, 6, 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: AppTheme.cardBoxShadow,
                                        ),
                                        child: Row(
                                          children: [
                                            // Icon
                                            Image.asset(
                                              'assets/images/ingredient.webp',
                                              width: 28,
                                              height: 28,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(width: 18),

                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Save Name
                                                  Text(
                                                    savedIngredient.name,
                                                    style: TextStyle(
                                                      fontSize: AppTheme
                                                          .adjustFontSizeForPlatform(
                                                              14),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppTheme.blackColor,
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),

                                                  // Date time
                                                  Text(
                                                    _formatDate(savedIngredient
                                                        .createdAt),
                                                    style: TextStyle(
                                                      fontSize: AppTheme
                                                          .adjustFontSizeForPlatform(
                                                              12),
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                                padding:
                                                    const EdgeInsets.all(12),
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
      ),
    );
  }

  Widget _buildResultsList(List<String> resultTypes) {
    final filteredResults = _savedResults
        .where((result) => resultTypes.contains(result.resultType))
        .toList();

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppTheme.blackColor,
            ),
          )
        : filteredResults.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/bookmark.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.gray500,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.no_saved_results,
                      style: TextStyle(
                        color: AppTheme.gray500,
                        fontSize: AppTheme.adjustFontSizeForPlatform(14),
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
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final savedResult = filteredResults[index];
                    return GestureDetector(
                      onTap: () => _viewResult(savedResult),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: AppTheme.cardBoxShadow,
                        ),
                        child: Row(
                          children: [
                            // Icon - CategoryMappingUtil이 영양 카테고리도 처리
                            Image.asset(
                              CategoryMappingUtil.getCategoryIconPath(
                                  savedResult.category),
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 18),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  Text(
                                    savedResult.name,
                                    style: TextStyle(
                                      fontSize: AppTheme
                                          .adjustFontSizeForPlatform(14),
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.blackColor,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // Date time
                                  Text(
                                    _formatDate(savedResult.createdAt),
                                    style: TextStyle(
                                      fontSize: AppTheme
                                          .adjustFontSizeForPlatform(12),
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
                              onTap: () => _deleteResult(savedResult),
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
              );
  }
}
