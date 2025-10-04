import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/preferences_service.dart';
import '../widgets/weight_input_widget.dart';

class PhysicalInfoScreen extends StatefulWidget {
  const PhysicalInfoScreen({super.key});

  @override
  State<PhysicalInfoScreen> createState() => _PhysicalInfoScreenState();
}

class _PhysicalInfoScreenState extends State<PhysicalInfoScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPhysicalInfo();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadPhysicalInfo() async {
    final height = PreferencesService.instance.getHeight();
    final weight = PreferencesService.instance.getCurrentWeight();
    final targetWeight = PreferencesService.instance.getTargetWeight();

    if (height != null && height > 0) {
      _heightController.text = height.toString();
    }
    if (weight != null && weight > 0) {
      _weightController.text = weight.toString();
    }
    if (targetWeight != null && targetWeight > 0) {
      _targetWeightController.text = targetWeight.toString();
    }
  }

  Future<void> _savePhysicalInfo() async {
    try {
      final heightText = _heightController.text.trim();
      final weightText = _weightController.text.trim();
      final targetWeightText = _targetWeightController.text.trim();

      if (heightText.isNotEmpty) {
        final height = double.tryParse(heightText);
        if (height != null) {
          await PreferencesService.instance.setHeight(height);
        }
      }

      if (weightText.isNotEmpty) {
        final weight = double.tryParse(weightText);
        if (weight != null) {
          await PreferencesService.instance.setCurrentWeight(weight);
        }
      }

      if (targetWeightText.isNotEmpty) {
        final targetWeight = double.tryParse(targetWeightText);
        if (targetWeight != null) {
          await PreferencesService.instance.setTargetWeight(targetWeight);
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.physical_info,
          style: const TextStyle(
            color: AppTheme.blackColor,
            fontSize: AppTheme.appBarTitleFontSize,
            fontWeight: AppTheme.appBarTitleFontWeight,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeightInputWidget(
                  label: AppLocalizations.of(context)!.height_cm,
                  controller: _heightController,
                  unit: 'cm',
                  hintText: '170',
                ),
                WeightInputWidget(
                  label: AppLocalizations.of(context)!.weight_kg,
                  controller: _weightController,
                  unit: 'kg',
                  hintText: '70',
                ),
                WeightInputWidget(
                  label: AppLocalizations.of(context)!.target_weight_kg,
                  controller: _targetWeightController,
                  unit: 'kg',
                  hintText: '65',
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _savePhysicalInfo,
                    style: AppTheme.getButtonStyle('action'),
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: AppTheme.getButtonTextStyle(
                        color: AppTheme.whiteColor,
                        type: 'action',
                      ),
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
