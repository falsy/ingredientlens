import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../models/category_data.dart';

class SubcategorySelectionBottomSheet extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? selectedSubcategory;
  final Function(String?) onSubcategorySelected;

  const SubcategorySelectionBottomSheet({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.selectedSubcategory,
    required this.onSubcategorySelected,
  });

  @override
  State<SubcategorySelectionBottomSheet> createState() =>
      _SubcategorySelectionBottomSheetState();
}

class _SubcategorySelectionBottomSheetState
    extends State<SubcategorySelectionBottomSheet> {
  String? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _selectedSubcategory = widget.selectedSubcategory;
  }

  String _getLocalizedSubcategoryName(String? subcategoryId) {
    if (subcategoryId == null) {
      return AppLocalizations.of(context)!.select_none;
    }

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

  @override
  Widget build(BuildContext context) {
    final subcategories = CategoryData.getSubcategories(widget.categoryId);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Text(
                      widget.categoryName,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: AppTheme.blackColor,
                        fontSize: AppTheme.bottomSheetTitleFontSize,
                        fontWeight: AppTheme.bottomSheetTitleFontWeight,
                        height: AppTheme.bottomSheetTitleLineHeight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Subcategory list
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                shrinkWrap: true,
                children: [
                  // "선택 안함" 옵션
                  _buildSubcategoryItem(null),

                  // 세부 카테고리 목록
                  ...subcategories.map(
                      (subcategoryId) => _buildSubcategoryItem(subcategoryId)),
                ],
              ),
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 12),
        ],
      ),
    );
  }

  Widget _buildSubcategoryItem(String? subcategoryId) {
    final isSelected = _selectedSubcategory == subcategoryId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedSubcategory = subcategoryId;
            });
            widget.onSubcategorySelected(subcategoryId);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryTextColor.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryTextColor
                    : AppTheme.cardBorderColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getLocalizedSubcategoryName(subcategoryId),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryTextColor
                          : AppTheme.gray700,
                      height: 1.3,
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
}
