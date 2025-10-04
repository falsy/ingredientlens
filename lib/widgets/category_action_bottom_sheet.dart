import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/analytics_service.dart';
import '../models/category_data.dart';
import 'subcategory_selection_bottom_sheet.dart';

class CategoryActionBottomSheet extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final bool isCustomCategory;
  final Function(String?) onCustomCategoryChanged;
  final Function(String, String) onAnalyze; // category ID, category name
  final Function(String) onCompare; // category key (including subcategory)

  const CategoryActionBottomSheet({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.isCustomCategory,
    required this.onCustomCategoryChanged,
    required this.onAnalyze,
    required this.onCompare,
  });

  @override
  State<CategoryActionBottomSheet> createState() =>
      _CategoryActionBottomSheetState();
}

class _CategoryActionBottomSheetState extends State<CategoryActionBottomSheet> {
  final TextEditingController _customCategoryController =
      TextEditingController();
  String? _customCategory;
  String? _selectedSubcategory;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  String _getLocalizedSubcategoryName(String subcategoryId) {
    final localizations = AppLocalizations.of(context)!;

    switch (subcategoryId) {
      // Food subcategories
      case 'food_health_food':
        return localizations.food_health_food;
      case 'food_diet_food':
        return localizations.food_diet_food;
      case 'food_dairy':
        return localizations.food_dairy;
      case 'food_processed':
        return localizations.food_processed;
      case 'food_instant':
        return localizations.food_instant;
      case 'food_beverages':
        return localizations.food_beverages;
      case 'food_snacks':
        return localizations.food_snacks;
      case 'food_bakery':
        return localizations.food_bakery;
      case 'food_seasoning':
        return localizations.food_seasoning;

      // Cosmetics subcategories
      case 'cosmetics_skincare':
        return localizations.cosmetics_skincare;
      case 'cosmetics_cleansing':
        return localizations.cosmetics_cleansing;
      case 'cosmetics_suncare':
        return localizations.cosmetics_suncare;
      case 'cosmetics_mask':
        return localizations.cosmetics_mask;
      case 'cosmetics_makeup':
        return localizations.cosmetics_makeup;
      case 'cosmetics_bodycare':
        return localizations.cosmetics_bodycare;
      case 'cosmetics_haircare':
        return localizations.cosmetics_haircare;
      case 'cosmetics_handcare':
        return localizations.cosmetics_handcare;
      case 'cosmetics_footcare':
        return localizations.cosmetics_footcare;
      case 'cosmetics_mens':
        return localizations.cosmetics_mens;

      // Medicine subcategories
      case 'medicine_skin_treatment':
        return localizations.medicine_skin_treatment;
      case 'medicine_allergy':
        return localizations.medicine_allergy;
      case 'medicine_womens':
        return localizations.medicine_womens;
      case 'medicine_general':
        return localizations.medicine_general;
      case 'medicine_supplements':
        return localizations.medicine_supplements;

      // Baby products subcategories
      case 'baby_skincare':
        return localizations.baby_skincare;
      case 'baby_cleansers':
        return localizations.baby_cleansers;
      case 'baby_medicine':
        return localizations.baby_medicine;
      case 'baby_food':
        return localizations.baby_food;
      case 'baby_formula':
        return localizations.baby_formula;
      case 'baby_sanitizers':
        return localizations.baby_sanitizers;
      case 'baby_detergent':
        return localizations.baby_detergent;
      case 'baby_toys':
        return localizations.baby_toys;

      // Pet products subcategories
      case 'pet_supplements':
        return localizations.pet_supplements;
      case 'pet_medicine':
        return localizations.pet_medicine;
      case 'pet_shampoo':
        return localizations.pet_shampoo;
      case 'pet_special_food':
        return localizations.pet_special_food;
      case 'pet_food':
        return localizations.pet_food;
      case 'pet_treats':
        return localizations.pet_treats;
      case 'pet_waste':
        return localizations.pet_waste;
      case 'pet_toys':
        return localizations.pet_toys;

      // Household products subcategories
      case 'household_products_dishwashing':
        return localizations.household_products_dishwashing;
      case 'household_products_air_freshener':
        return localizations.household_products_air_freshener;
      case 'household_products_cleaner':
        return localizations.household_products_cleaner;
      case 'household_products_deodorizer':
        return localizations.household_products_deodorizer;

      default:
        return subcategoryId;
    }
  }

  void _handleAnalyze() {
    String categoryToAnalyze;
    String categoryName;

    if (widget.isCustomCategory) {
      final customText = _customCategory?.trim();
      if (customText == null || customText.isEmpty) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.enter_custom_category;
        });
        return;
      }
      categoryToAnalyze = customText;
      categoryName = customText;
    } else {
      // 세부 카테고리가 선택된 경우 이를 포함
      if (_selectedSubcategory != null) {
        categoryToAnalyze = _selectedSubcategory!;
        categoryName = _getLocalizedSubcategoryName(_selectedSubcategory!);
      } else {
        categoryToAnalyze = widget.categoryId;
        categoryName = widget.categoryName;
      }
    }

    // Analytics: 카테고리 선택 이벤트
    AnalyticsService.logCategorySelected(
      category: categoryToAnalyze,
      action: 'analyze',
    );

    Navigator.pop(context);
    widget.onAnalyze(categoryToAnalyze, categoryName);
  }

  void _handleCompare() {
    String categoryToCompare;

    if (widget.isCustomCategory) {
      final customText = _customCategory?.trim();
      if (customText == null || customText.isEmpty) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.enter_custom_category;
        });
        return;
      }
      categoryToCompare = customText;
    } else {
      // 세부 카테고리가 선택된 경우 이를 포함 (분석과 동일하게 키 값 사용)
      if (_selectedSubcategory != null) {
        categoryToCompare = _selectedSubcategory!;
      } else {
        categoryToCompare = widget.categoryId;
      }
    }

    // Analytics: 카테고리 선택 이벤트
    final categoryForAnalytics = widget.isCustomCategory
        ? categoryToCompare
        : (_selectedSubcategory ?? widget.categoryId);

    AnalyticsService.logCategorySelected(
      category: categoryForAnalytics,
      action: 'compare',
    );

    Navigator.pop(context);
    widget.onCompare(categoryToCompare);
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
            Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Text(
                widget.categoryName,
                style: const TextStyle(
                  color: AppTheme.blackColor,
                  fontSize: AppTheme.bottomSheetTitleFontSize,
                  fontWeight: AppTheme.bottomSheetTitleFontWeight,
                  height: AppTheme.bottomSheetTitleLineHeight,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Custom category input (only for custom category)
            if (widget.isCustomCategory) ...[
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
                  controller: _customCategoryController,
                  onChanged: (value) {
                    setState(() {
                      _customCategory = value;
                      _errorMessage = null; // Clear error when user types
                    });
                    widget.onCustomCategoryChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.enter_custom_category,
                    hintStyle: const TextStyle(
                      color: AppTheme.gray500,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppTheme.blackColor,
                    fontSize: 15,
                  ),
                  autofocus: true,
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
                    style: TextStyle(
                      color: AppTheme.negativeColor,
                      fontSize: AppTheme.adjustFontSizeForPlatform(13),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ] else ...[
                const SizedBox(height: 14),
              ],
            ],

            // Subcategory selection button (only for categories with subcategories)
            if (!widget.isCustomCategory &&
                CategoryData.hasSubcategories(widget.categoryId)) ...[
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Text(
                  AppLocalizations.of(context)!.subcategories,
                  style: const TextStyle(
                    color: AppTheme.blackColor,
                    fontSize: AppTheme.bottomSheetSubtitleFontSize,
                    fontWeight: AppTheme.bottomSheetSubtitleFontWeight,
                    height: AppTheme.bottomSheetSubtitleLineHeight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SubcategorySelectionBottomSheet(
                      categoryId: widget.categoryId,
                      categoryName: widget.categoryName,
                      selectedSubcategory: _selectedSubcategory,
                      onSubcategorySelected: (subcategory) {
                        setState(() {
                          _selectedSubcategory = subcategory;
                        });
                      },
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.cardBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedSubcategory != null
                              ? _getLocalizedSubcategoryName(
                                  _selectedSubcategory!)
                              : AppLocalizations.of(context)!.select_none,
                          style: TextStyle(
                            color: _selectedSubcategory != null
                                ? AppTheme.blackColor
                                : AppTheme.gray500,
                            fontSize: AppTheme.adjustFontSizeForPlatform(15),
                          ),
                        ),
                      ),
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          AppTheme.gray500,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/images/icons/right-arrow.webp',
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action buttons
            Row(
              children: [
                // Analyze button
                Expanded(
                  child: SizedBox(
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _handleAnalyze,
                      style: AppTheme.getButtonStyle('action'),
                      child: Text(
                        AppLocalizations.of(context)!.analyze,
                        style: AppTheme.getButtonTextStyle(type: 'action'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Compare button
                Expanded(
                  child: SizedBox(
                    height: AppTheme.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _handleCompare,
                      style: AppTheme.getButtonStyle('action2'),
                      child: Text(
                        AppLocalizations.of(context)!.compare,
                        style: AppTheme.getButtonTextStyle(type: 'action2'),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}
