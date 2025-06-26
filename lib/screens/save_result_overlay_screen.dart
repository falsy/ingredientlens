import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import '../widgets/save_result_bottom_sheet.dart';

class SaveResultOverlayScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final String resultType;
  final String category;

  const SaveResultOverlayScreen({
    super.key,
    required this.resultData,
    required this.resultType,
    required this.category,
  });

  @override
  State<SaveResultOverlayScreen> createState() => _SaveResultOverlayScreenState();
}

class _SaveResultOverlayScreenState extends State<SaveResultOverlayScreen> {
  @override
  void initState() {
    super.initState();
    // 페이지가 로드되자마자 바텀시트 열기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSaveBottomSheet();
    });
  }

  void _showSaveBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => SaveResultBottomSheet(
        resultData: widget.resultData,
        resultType: widget.resultType,
        category: widget.category,
      ),
    ).then((result) {
      // 바텀시트가 닫히면 결과와 함께 overlay screen도 닫기
      Navigator.pop(context, result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(),
      ),
    );
  }
}