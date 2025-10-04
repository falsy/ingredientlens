import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/user_preference_service.dart';
import '../widgets/custom_preference_bottom_sheet.dart';
import '../models/user_preference.dart';

class PetPreferenceDetailScreen extends StatefulWidget {
  final String category;
  final String title;

  const PetPreferenceDetailScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<PetPreferenceDetailScreen> createState() =>
      _PetPreferenceDetailScreenState();
}

class _PetPreferenceDetailScreenState extends State<PetPreferenceDetailScreen> {
  final UserPreferenceService _preferenceService = UserPreferenceService();
  List<UserPreference> _selectedPreferences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences =
          await _preferenceService.getPreferencesByCategory(widget.category);
      setState(() {
        _selectedPreferences = preferences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _getPresetOptionKeys() {
    switch (widget.category) {
      case 'pet_type':
        return [
          'dog',
          'cat',
          'bird',
          'rabbit',
          'hamster',
        ];
      case 'pet_breed':
        // 품종은 직접 추가만 가능
        return [];
      case 'pet_age':
        return [
          'pet_age_0_1_year',
          'pet_age_1_3_years',
          'pet_age_3_5_years',
          'pet_age_5_7_years',
          'pet_age_7_10_years',
          'pet_age_10_plus_years',
        ];
      case 'pet_weight':
        return [
          'pet_weight_under_1kg',
          'pet_weight_1_3kg',
          'pet_weight_3_5kg',
          'pet_weight_5_10kg',
          'pet_weight_10_20kg',
          'pet_weight_over_20kg',
        ];
      case 'pet_allergy':
        return [
          'pet_allergy_grains',
          'pet_allergy_chicken',
          'pet_allergy_beef',
          'fish',
          'eggs',
          'dairy',
          'soy',
          'nuts',
        ];
      case 'pet_health':
        return [
          'pet_health_healthy',
          'pet_health_arthritis',
          'pet_health_heart_disease',
          'pet_health_kidney_disease',
          'pet_health_liver_disease',
          'pet_health_diabetes',
          'pet_health_skin_disease',
          'pet_health_digestive_disease',
        ];
      case 'pet_neutered':
        return [
          'neutered_yes',
          'neutered_no',
        ];
      default:
        return [];
    }
  }

  String _getTranslatedText(String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      // Pet types
      case 'dog':
        return localizations.dog;
      case 'cat':
        return localizations.cat;
      case 'bird':
        return localizations.bird;
      case 'rabbit':
        return localizations.rabbit;
      case 'hamster':
        return localizations.hamster;
      // Pet age
      case 'pet_age_0_1_year':
        return localizations.pet_age_0_1_year;
      case 'pet_age_1_3_years':
        return localizations.pet_age_1_3_years;
      case 'pet_age_3_5_years':
        return localizations.pet_age_3_5_years;
      case 'pet_age_5_7_years':
        return localizations.pet_age_5_7_years;
      case 'pet_age_7_10_years':
        return localizations.pet_age_7_10_years;
      case 'pet_age_10_plus_years':
        return localizations.pet_age_10_plus_years;
      // Pet weight
      case 'pet_weight_under_1kg':
        return localizations.pet_weight_under_1kg;
      case 'pet_weight_1_3kg':
        return localizations.pet_weight_1_3kg;
      case 'pet_weight_3_5kg':
        return localizations.pet_weight_3_5kg;
      case 'pet_weight_5_10kg':
        return localizations.pet_weight_5_10kg;
      case 'pet_weight_10_20kg':
        return localizations.pet_weight_10_20kg;
      case 'pet_weight_over_20kg':
        return localizations.pet_weight_over_20kg;
      // Pet allergies
      case 'pet_allergy_grains':
        return localizations.pet_allergy_grains;
      case 'pet_allergy_chicken':
        return localizations.pet_allergy_chicken;
      case 'pet_allergy_beef':
        return localizations.pet_allergy_beef;
      case 'fish':
        return localizations.fish;
      case 'eggs':
        return localizations.eggs;
      case 'dairy':
        return localizations.dairy;
      case 'soy':
        return localizations.soy;
      case 'nuts':
        return localizations.nuts;
      // Pet health
      case 'pet_health_healthy':
        return localizations.pet_health_healthy;
      case 'pet_health_arthritis':
        return localizations.pet_health_arthritis;
      case 'pet_health_heart_disease':
        return localizations.pet_health_heart_disease;
      case 'pet_health_kidney_disease':
        return localizations.pet_health_kidney_disease;
      case 'pet_health_liver_disease':
        return localizations.pet_health_liver_disease;
      case 'pet_health_diabetes':
        return localizations.pet_health_diabetes;
      case 'pet_health_skin_disease':
        return localizations.pet_health_skin_disease;
      case 'pet_health_digestive_disease':
        return localizations.pet_health_digestive_disease;
      // Pet neutered
      case 'neutered_yes':
        return localizations.neutered_yes;
      case 'neutered_no':
        return localizations.neutered_no;
      default:
        return key; // 키를 찾을 수 없으면 키 자체를 반환
    }
  }

  Future<void> _togglePreference(String key, bool isCustom) async {
    try {
      final existingIndex =
          _selectedPreferences.indexWhere((pref) => pref.value == key);

      if (existingIndex >= 0) {
        // 이미 선택된 경우 - 제거
        await _preferenceService.deletePreferenceByValue(widget.category, key);
        setState(() {
          _selectedPreferences.removeAt(existingIndex);
        });
      } else {
        // 단일 선택만 허용하는 카테고리들 (펫 타입, 펫 중성화)
        if (widget.category == 'pet_type' ||
            widget.category == 'pet_neutered') {
          // 기존 선택된 항목이 있으면 모두 제거
          final existingPrefs = _selectedPreferences
              .where((pref) => pref.category == widget.category)
              .toList();
          for (final pref in existingPrefs) {
            await _preferenceService.deletePreferenceByValue(
                widget.category, pref.value);
          }
          setState(() {
            _selectedPreferences
                .removeWhere((pref) => pref.category == widget.category);
          });
        }

        // 새로운 선택 추가 (키로 저장)
        final now = DateTime.now();
        final preference = UserPreference(
          category: widget.category,
          value: key,
          isCustom: isCustom,
          createdAt: now,
          updatedAt: now,
        );

        final result = await _preferenceService.addPreference(preference);
        if (result > 0) {
          await _loadPreferences();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.value_already_exists),
                backgroundColor: AppTheme.negativeColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  bool _isSelected(String key) {
    return _selectedPreferences.any((pref) => pref.value == key);
  }

  void _showCustomBottomSheet() {
    final customCount =
        _selectedPreferences.where((pref) => pref.isCustom).length;

    // 최대 3개 제한 체크
    if (customCount >= 3) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.custom_limit_reached),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => CustomPreferenceBottomSheet(
        onSave: (value) => _togglePreference(value, true),
        currentCustomCount: customCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.blackColor))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          // Preset options
                          ..._getPresetOptionKeys()
                              .map((key) => _buildOptionItem(
                                    title: _getTranslatedText(key),
                                    originalValue: key,
                                    isSelected: _isSelected(key),
                                    onTap: () => _togglePreference(key, false),
                                  )),

                          // Custom options
                          ..._selectedPreferences
                              .where((pref) => pref.isCustom)
                              .map((preference) => _buildOptionItem(
                                    title: preference.value,
                                    originalValue: preference.value,
                                    isSelected: true,
                                    isCustom: true,
                                    onTap: () => _togglePreference(
                                        preference.value, true),
                                  )),

                          // Add custom button
                          _buildAddCustomButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOptionItem({
    required String title,
    String? originalValue,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCustom = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryTextColor.withOpacity(0.08)
                  : AppTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryTextColor
                    : AppTheme.cardBorderColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryTextColor
                          : const Color.fromARGB(160, 0, 0, 0),
                      height: 1.3,
                    ),
                  ),
                ),
                if (isCustom)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color.fromARGB(255, 5, 155, 135),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Custom',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.whiteColor,
                        shadows: [
                          Shadow(
                            color: Color.fromARGB(15, 0, 0, 0),
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
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

  Widget _buildAddCustomButton() {
    final customCount =
        _selectedPreferences.where((pref) => pref.isCustom).length;
    final isDisabled = customCount >= 3;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : _showCustomBottomSheet,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color:
                  isDisabled ? AppTheme.gray200 : AppTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDisabled ? AppTheme.gray200 : AppTheme.cardBorderColor,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDisabled ? AppTheme.gray300 : AppTheme.gray200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: isDisabled ? AppTheme.gray600 : AppTheme.blackColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isDisabled
                        ? '${AppLocalizations.of(context)!.add_custom} (3/3)'
                        : AppLocalizations.of(context)!.add_custom,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDisabled ? AppTheme.gray500 : AppTheme.gray700,
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
