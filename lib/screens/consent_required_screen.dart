import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/consent_service.dart';

class ConsentRequiredScreen extends StatelessWidget {
  const ConsentRequiredScreen({super.key});

  void _handleConsentRequest(BuildContext context) async {
    // 동의 정보 업데이트 및 양식 표시
    await ConsentService().requestConsentInfoUpdate();

    // 동의 상태 재확인
    final canUseService = await ConsentService().canUseService();
    if (canUseService && context.mounted) {
      // 동의했으면 메인 화면으로
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _handleContinueWithoutConsent(BuildContext context) {
    // 동의하지 않고도 앱 계속 사용
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.blackColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  size: 40,
                  color: AppTheme.blackColor,
                ),
              ),
              const SizedBox(height: 32),

              // 제목
              Text(
                AppLocalizations.of(context)!
                    .translate('consent_required_title'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.blackColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 설명
              Text(
                AppLocalizations.of(context)!
                    .translate('consent_required_description'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.gray500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 추가 설명
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.gray500,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate('consent_required_info'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 동의하기 버튼
              SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => _handleConsentRequest(context),
                  style: AppTheme.getButtonStyle('action'),
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('consent_agree_button'),
                    style: AppTheme.getButtonTextStyle(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 동의 안 함 버튼
              SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: OutlinedButton(
                  onPressed: () => _handleContinueWithoutConsent(context),
                  style: AppTheme.getButtonStyle('cancel'),
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('consent_decline_button'),
                    style: AppTheme.getButtonTextStyle(color: AppTheme.gray700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
