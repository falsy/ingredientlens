import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../models/saved_result.dart';
import 'analysis_result_screen.dart';
import 'comparison_result_screen.dart';
import '../widgets/delete_confirm_bottom_sheet.dart';

class SavedResultsScreen extends StatefulWidget {
  const SavedResultsScreen({super.key});

  @override
  State<SavedResultsScreen> createState() => _SavedResultsScreenState();
}

class _SavedResultsScreenState extends State<SavedResultsScreen> {
  List<SavedResult> _savedResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  Future<void> _loadSavedResults() async {
    try {
      final results = await DatabaseService().getAllResults();
      setState(() {
        _savedResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('데이터 로드에 실패했습니다'),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
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
          const SnackBar(
            content: Text('결과를 불러오는데 실패했습니다'),
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
        savedResult: savedResult,
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
              fontSize: 18,
              fontWeight: FontWeight.w500,
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
            Expanded(
              child: _isLoading
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
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 12, 8, 12),
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
                                      Icon(
                                        savedResult.resultType == 'analysis'
                                            ? Icons.analytics_outlined
                                            : Icons.compare_outlined,
                                        color: AppTheme.blackColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 14),

                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Name
                                            Text(
                                              savedResult.name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.blackColor,
                                                height: 1.1,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),

                                            // Category
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      savedResult.category),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: AppTheme.gray700,
                                                height: 1.3,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),

                                            // Date time
                                            Text(
                                              _formatDate(
                                                  savedResult.createdAt),
                                              style: const TextStyle(
                                                fontSize: 11,
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
                        ),
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}
