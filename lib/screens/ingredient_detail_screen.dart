import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/database_service.dart';
import '../models/recent_ingredient.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/save_ingredient_bottom_sheet.dart';

class IngredientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ingredientDetail;
  final String ingredientName;
  final String category;
  final bool fromSavedResults;
  final bool isNewSearch;

  const IngredientDetailScreen({
    super.key,
    required this.ingredientDetail,
    required this.ingredientName,
    required this.category,
    this.fromSavedResults = false,
    this.isNewSearch = true,
  });

  @override
  State<IngredientDetailScreen> createState() => _IngredientDetailScreenState();
}

class _IngredientDetailScreenState extends State<IngredientDetailScreen> {
  @override
  void initState() {
    super.initState();
    _saveRecentIngredient();
  }

  void _saveRecentIngredient() async {
    // 새로운 검색이 아니거나 로딩 상태이면 저장하지 않음
    if (!widget.isNewSearch || widget.ingredientDetail['loading'] == true) return;

    try {
      final description = widget.ingredientDetail['description'] ?? '';
      
      if (description.toString().isNotEmpty) {
        final recentIngredient = RecentIngredient(
          ingredientName: widget.ingredientName,
          category: widget.category,
          description: description.toString(),
          resultData: jsonEncode(widget.ingredientDetail),
          createdAt: DateTime.now(),
        );

        await DatabaseService().saveRecentIngredient(recentIngredient);
      }
    } catch (e) {
      // Error saving recent ingredient - ignore silently
    }
  }

  void _showSaveBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => SaveIngredientBottomSheet(
        ingredientDetail: widget.ingredientDetail,
        ingredientName: widget.ingredientName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 로딩 상태인지 확인
    final isLoading = widget.ingredientDetail['loading'] == true;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isLoading ? AppLocalizations.of(context)!.translate('searching') : (widget.ingredientDetail['ingredient_name'] ?? widget.ingredientName),
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
          icon: const Icon(Icons.arrow_back,
              color: AppTheme.blackColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppTheme.blackColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.translate('searching_ingredient_info'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.gray500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSectionsWithSpacing(context),
              ),
            ),
      ),
    );
  }

  List<Widget> _buildSectionsWithSpacing(BuildContext context) {
    List<Widget> sections = [];
    final isLoading = widget.ingredientDetail['loading'] == true;

    // 성분 설명
    final descriptionSection = _buildDescriptionSection(context);
    if (descriptionSection != null) {
      sections.add(descriptionSection);
    }

    // 다른 이름들
    final alternativeNamesSection = _buildAlternativeNamesSection(context);
    if (alternativeNamesSection != null) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(alternativeNamesSection);
    }

    // 주요 기능
    final functionsSection = _buildListSection(
      context,
      title: AppLocalizations.of(context)!.translate('primary_functions'),
      items: widget.ingredientDetail['primary_functions'] ?? [],
    );
    if (functionsSection != null) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(functionsSection);
    }

    // 효능/이점
    final benefitsSection = _buildListSection(
      context,
      title: AppLocalizations.of(context)!.translate('benefits'),
      items: widget.ingredientDetail['benefits'] ?? [],
    );
    if (benefitsSection != null) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(benefitsSection);
    }

    // 주의사항/위험성
    final risksSection = _buildListSection(
      context,
      title: AppLocalizations.of(context)!.translate('precautions'),
      items: widget.ingredientDetail['potential_risks'] ?? [],
    );
    if (risksSection != null) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(risksSection);
    }


    // 추가 정보
    final additionalInfoSection = _buildAdditionalInfoSection(context);
    if (additionalInfoSection != null) {
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 32));
      sections.add(additionalInfoSection);
    }

    // 광고 섹션
    if (sections.isNotEmpty) {
      sections.add(const SizedBox(height: 24));
      sections.add(const AdBannerWidget());
    }

    // 저장 버튼 추가 (저장된 결과에서 온 경우가 아닐 때만)
    if (sections.isNotEmpty && !isLoading && !widget.fromSavedResults) {
      sections.add(const SizedBox(height: 32));
      sections.add(_buildSaveButton(context));
    }

    // AI 안내 메시지
    if (sections.isNotEmpty) {
      sections.add(const SizedBox(height: 32));
      sections.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cardBorderColor,
              width: 1,
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.translate('ai_disclaimer'),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showSaveBottomSheet,
        icon: const Icon(Icons.save_alt, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.translate('save_result'),
          style: AppTheme.getButtonTextStyle(color: Colors.white),
        ),
        style: AppTheme.getButtonStyle('action'),
      ),
    );
  }

  Widget? _buildDescriptionSection(BuildContext context) {
    final description = widget.ingredientDetail['description'];
    if (description == null || description.toString().trim().isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('description'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cardBorderColor,
              width: 1,
            ),
          ),
          child: Text(
            description.toString(),
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.gray700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildAlternativeNamesSection(BuildContext context) {
    final names = widget.ingredientDetail['alternative_names'];
    if (names == null || (names is List && names.isEmpty)) {
      return null;
    }

    final nameList = names is List ? names : [names];
    if (nameList.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('alternative_names'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cardBorderColor,
              width: 1,
            ),
          ),
          child: Text(
            nameList.join(', '),
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.gray700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildListSection(
    BuildContext context, {
    required String title,
    required List<dynamic> items,
  }) {
    if (items.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.cardBorderColor,
                  width: 1,
                ),
              ),
              child: Text(
                '• ${item.toString()}',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.gray700,
                  height: 1.5,
                ),
              ),
            )),
      ],
    );
  }

  Widget? _buildAdditionalInfoSection(BuildContext context) {
    final additionalInfo = widget.ingredientDetail['additional_info'];
    if (additionalInfo == null || additionalInfo.toString().trim().isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('additional_info'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cardBorderColor,
              width: 1,
            ),
          ),
          child: Text(
            additionalInfo.toString(),
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.gray700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}