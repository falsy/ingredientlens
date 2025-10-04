import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/preferences_service.dart';
import '../services/user_preference_service.dart';
import '../models/user_preference.dart';
import '../widgets/weight_input_widget.dart';

class PetWeightScreen extends StatefulWidget {
  const PetWeightScreen({super.key});

  @override
  State<PetWeightScreen> createState() => _PetWeightScreenState();
}

class _PetWeightScreenState extends State<PetWeightScreen> {
  final TextEditingController _weightController = TextEditingController();
  final UserPreferenceService _preferenceService = UserPreferenceService();

  @override
  void initState() {
    super.initState();
    _loadPetWeight();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadPetWeight() async {
    final weight = await PreferencesService.instance.getPetWeight();
    if (weight != null) {
      _weightController.text = weight.toString();
    }
  }

  Future<void> _savePetWeight() async {
    final weight = double.tryParse(_weightController.text);
    
    if (weight != null) {
      // SharedPreferences에 저장
      await PreferencesService.instance.setPetWeight(weight);
      
      // 기존 pet_weight preference 제거
      final existingPrefs = await _preferenceService.getPreferencesByCategory('pet_weight');
      for (final pref in existingPrefs) {
        await _preferenceService.deletePreference(pref.id!);
      }
      
      // 새로운 custom preference 추가
      final weightText = '${weight}kg';
      final newPreference = UserPreference(
        category: 'pet_weight',
        value: weightText,
        isCustom: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _preferenceService.addPreference(newPreference);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.save_complete),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } else if (_weightController.text.isEmpty) {
      // 빈 값인 경우 모든 데이터 삭제
      await PreferencesService.instance.setPetWeight(0);
      
      // preference도 삭제
      final existingPrefs = await _preferenceService.getPreferencesByCategory('pet_weight');
      for (final pref in existingPrefs) {
        await _preferenceService.deletePreference(pref.id!);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.save_complete),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.weight,
              style: TextStyle(
                color: AppTheme.blackColor,
                fontSize: AppTheme.appBarTitleFontSize,
                fontWeight: AppTheme.appBarTitleFontWeight,
                letterSpacing: 0.4,
              ),
            ),
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: AppTheme.blackColor, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: _savePetWeight,
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.adjustFontSizeForPlatform(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WeightInputWidget(
                      label: AppLocalizations.of(context)!.weight_kg,
                      controller: _weightController,
                      unit: 'kg',
                      hintText: '15.2',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}