import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../services/preferences_service.dart';
import '../widgets/weight_input_widget.dart';

class BabyWeightScreen extends StatefulWidget {
  const BabyWeightScreen({super.key});

  @override
  State<BabyWeightScreen> createState() => _BabyWeightScreenState();
}

class _BabyWeightScreenState extends State<BabyWeightScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBabyWeight();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadBabyWeight() async {
    final weight = PreferencesService.instance.getBabyWeight();
    if (weight != null && weight > 0) {
      _weightController.text = weight.toString();
    }
  }

  Future<void> _saveBabyWeight() async {
    try {
      final weightText = _weightController.text.trim();
      
      if (weightText.isNotEmpty) {
        final weight = double.tryParse(weightText);
        if (weight != null) {
          await PreferencesService.instance.setBabyWeight(weight);
        }
      } else {
        // 빈 값인 경우 0으로 저장 (삭제)
        await PreferencesService.instance.setBabyWeight(0);
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
              AppLocalizations.of(context)!.baby_weight,
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
                      hintText: '10.5',
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _saveBabyWeight,
                        style: AppTheme.getButtonStyle('action'),
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: AppTheme.getButtonTextStyle(),
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