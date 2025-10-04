import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/user_preference_service.dart';
import '../widgets/custom_preference_bottom_sheet.dart';
import '../models/user_preference.dart';
import 'baby_weight_screen.dart';

class BabyPreferenceDetailScreen extends StatefulWidget {
  final String category;
  final String title;

  const BabyPreferenceDetailScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<BabyPreferenceDetailScreen> createState() =>
      _BabyPreferenceDetailScreenState();
}

class _BabyPreferenceDetailScreenState
    extends State<BabyPreferenceDetailScreen> {
  final UserPreferenceService _preferenceService = UserPreferenceService();
  List<UserPreference> _selectedPreferences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // baby_weight 카테고리는 별도 화면으로 처리
    if (widget.category == 'baby_weight') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BabyWeightScreen(),
          ),
        );
      });
      return;
    }

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
      case 'baby_age':
        return [
          'baby_age_0_6_months',
          'baby_age_6_12_months',
          'baby_age_1_2_years',
          'baby_age_2_3_years',
          'baby_age_3_5_years',
          'baby_age_5_plus_years',
        ];
      case 'baby_skin':
        return [
          'normal',
          'dry',
          'oily',
          'combination',
          'sensitive',
          'atopic',
        ];
      case 'baby_allergy':
        return [
          'nuts',
          'dairy',
          'eggs',
          'shellfish',
          'fish',
          'soy',
          'gluten',
          'sesame',
        ];
      case 'baby_health':
        return [
          'baby_health_healthy',
          'baby_health_asthma',
          'baby_health_digestive_sensitivity',
          'baby_health_constipation',
          'baby_health_diarrhea',
        ];
      default:
        return [];
    }
  }

  String _getTranslatedText(String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      // Baby age
      case 'baby_age_0_6_months':
        return localizations.baby_age_0_6_months;
      case 'baby_age_6_12_months':
        return localizations.baby_age_6_12_months;
      case 'baby_age_1_2_years':
        return localizations.baby_age_1_2_years;
      case 'baby_age_2_3_years':
        return localizations.baby_age_2_3_years;
      case 'baby_age_3_5_years':
        return localizations.baby_age_3_5_years;
      case 'baby_age_5_plus_years':
        return localizations.baby_age_5_plus_years;
      // Skin types
      case 'normal':
        return localizations.normal;
      case 'dry':
        return localizations.dry;
      case 'oily':
        return localizations.oily;
      case 'combination':
        return localizations.combination;
      case 'sensitive':
        return localizations.sensitive;
      case 'atopic':
        return localizations.atopic;
      // Allergies
      case 'nuts':
        return localizations.nuts;
      case 'dairy':
        return localizations.dairy;
      case 'eggs':
        return localizations.eggs;
      case 'shellfish':
        return localizations.shellfish;
      case 'fish':
        return localizations.fish;
      case 'soy':
        return localizations.soy;
      case 'gluten':
        return localizations.gluten;
      case 'sesame':
        return localizations.sesame;
      // Baby health
      case 'baby_health_healthy':
        return localizations.baby_health_healthy;
      case 'baby_health_asthma':
        return localizations.baby_health_asthma;
      case 'baby_health_digestive_sensitivity':
        return localizations.baby_health_digestive_sensitivity;
      case 'baby_health_constipation':
        return localizations.baby_health_constipation;
      case 'baby_health_diarrhea':
        return localizations.baby_health_diarrhea;
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
        // 아기 나이는 단일 선택만 허용
        if (widget.category == 'baby_age') {
          // 기존 선택된 나이가 있으면 모두 제거
          final existingAgePrefs = _selectedPreferences
              .where((pref) => pref.category == 'baby_age')
              .toList();
          for (final pref in existingAgePrefs) {
            await _preferenceService.deletePreferenceByValue(
                widget.category, pref.value);
          }
          setState(() {
            _selectedPreferences
                .removeWhere((pref) => pref.category == 'baby_age');
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

                          // Add custom button (아기 나이는 제외)
                          if (widget.category != 'baby_age')
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
