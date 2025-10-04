import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../models/user_preference.dart';
import '../services/user_preference_service.dart';
import '../utils/theme.dart';
import '../utils/preference_translation_util.dart';
import '../utils/legacy_data_migration_util.dart';
import '../widgets/custom_preference_bottom_sheet.dart';
import 'physical_info_screen.dart';

class UserPreferenceDetailScreen extends StatefulWidget {
  final String category;
  final String categoryTitle;

  const UserPreferenceDetailScreen({
    super.key,
    required this.category,
    required this.categoryTitle,
  });

  @override
  State<UserPreferenceDetailScreen> createState() =>
      _UserPreferenceDetailScreenState();
}

class _UserPreferenceDetailScreenState
    extends State<UserPreferenceDetailScreen> {
  final UserPreferenceService _preferenceService = UserPreferenceService();

  List<UserPreference> _userPreferences = [];
  List<String> _presetOptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // physical_info 카테고리는 별도 화면으로 처리
    if (widget.category == 'physical_info') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PhysicalInfoScreen(),
          ),
        );
      });
      return;
    }

    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _presetOptions = PreferencePresets.getPresets(widget.category);
    _userPreferences =
        await _preferenceService.getPreferencesByCategory(widget.category);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addPreference(String value, bool isCustom) async {
    final now = DateTime.now();
    final preference = UserPreference(
      category: widget.category,
      value: value,
      isCustom: isCustom,
      createdAt: now,
      updatedAt: now,
    );

    final result = await _preferenceService.addPreference(preference);
    if (result > 0) {
      await _loadData();
      // 성공 스낵바 제거 - 바로 적용되어 시각적으로 확인 가능
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.value_already_exists),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  Future<void> _removePreference(UserPreference preference) async {
    await _preferenceService.deletePreference(preference.id!);
    await _loadData();
    // 성공 스낵바 제거 - 바로 적용되어 시각적으로 확인 가능
  }

  bool _isPreferenceSelected(String value) {
    // 영어 텍스트를 다국어 키로 변환해서 비교
    final keyValue =
        LegacyDataMigrationUtil.convertLegacyToKey(widget.category, value);
    return _userPreferences.any((pref) => pref.value == keyValue);
  }

  void _showCustomBottomSheet() {
    final customCount = _userPreferences.where((pref) => pref.isCustom).length;

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
        onSave: (value) => _addPreference(value, true),
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
          widget.categoryTitle,
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
                          ..._presetOptions.map((option) => _buildOptionItem(
                                title: _getTranslatedPresetOption(option),
                                originalValue: option,
                                isSelected: _isPreferenceSelected(option),
                                onTap: () {
                                  if (_isPreferenceSelected(option)) {
                                    final keyValue = LegacyDataMigrationUtil
                                        .convertLegacyToKey(
                                            widget.category, option);
                                    final preference =
                                        _userPreferences.firstWhere(
                                            (pref) => pref.value == keyValue);
                                    _removePreference(preference);
                                  } else {
                                    // 영어 텍스트를 다국어 키로 변환해서 저장
                                    final keyValue = LegacyDataMigrationUtil
                                        .convertLegacyToKey(
                                            widget.category, option);
                                    _addPreference(keyValue, false);
                                  }
                                },
                              )),

                          // Custom options
                          ..._userPreferences
                              .where((pref) => pref.isCustom)
                              .map((preference) => _buildOptionItem(
                                    title: preference.value,
                                    originalValue: preference.value,
                                    isSelected: true,
                                    isCustom: true,
                                    onTap: () => _removePreference(preference),
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

  String _getTranslatedPresetOption(String option) {
    return PreferenceTranslationUtil.getTranslatedOption(context, option);
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
    final customCount = _userPreferences.where((pref) => pref.isCustom).length;
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
