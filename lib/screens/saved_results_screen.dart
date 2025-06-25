import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../models/saved_result.dart';
import 'analysis_result_screen.dart';
import 'comparison_result_screen.dart';
import 'delete_confirm_overlay_screen.dart';

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
          SnackBar(
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
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DeleteConfirmOverlayScreen(
          savedResult: savedResult,
          onDeleted: _loadSavedResults,
        ),
        transitionDuration: Duration.zero, // 즉시 전환
        reverseTransitionDuration: Duration.zero, // 즉시 전환
        opaque: false, // 투명한 페이지
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!
                .translate('saved_results')
                .toUpperCase(),
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: AppTheme.backgroundColor,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: AppTheme.backgroundColor,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                Icon(Icons.arrow_back, color: AppTheme.primaryGreen, size: 28),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    )
                  : _savedResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_outline,
                                size: 64,
                                color: AppTheme.primaryGreen.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!
                                    .translate('no_saved_results'),
                                style: TextStyle(
                                  color: AppTheme.primaryGreen.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppTheme.primaryGreen,
                          onRefresh: _loadSavedResults,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _savedResults.length,
                            itemBuilder: (context, index) {
                              final savedResult = _savedResults[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.whiteColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen
                                          .withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () => _viewResult(savedResult),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16,
                                        top: 16,
                                        bottom: 16,
                                        right: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryGreen
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            savedResult.resultType == 'analysis'
                                                ? Icons.analytics_outlined
                                                : Icons.compare_outlined,
                                            color: AppTheme.primaryGreen,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                savedResult.name,
                                                style: TextStyle(
                                                  color: AppTheme.blackColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(savedResult
                                                            .category),
                                                    style: TextStyle(
                                                      color:
                                                          AppTheme.primaryGreen,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    ' • ',
                                                    style: TextStyle(
                                                      color: AppTheme
                                                          .primaryGreen
                                                          .withOpacity(0.5),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate(savedResult
                                                                    .resultType ==
                                                                'analysis'
                                                            ? 'analysis'
                                                            : 'comparison'),
                                                    style: TextStyle(
                                                      color: AppTheme
                                                          .primaryGreen
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _formatDate(
                                                    savedResult.createdAt),
                                                style: TextStyle(
                                                  color: AppTheme.primaryGreen
                                                      .withOpacity(0.5),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 0),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () =>
                                                  _deleteResult(savedResult),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child: Icon(
                                                  Icons.close,
                                                  color: AppTheme.gray400,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
