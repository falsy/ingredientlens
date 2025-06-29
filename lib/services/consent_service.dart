import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class ConsentService {
  static final ConsentService _instance = ConsentService._internal();
  factory ConsentService() => _instance;
  ConsentService._internal();

  bool _isConsentFormAvailable = false;
  bool _isPrivacyOptionsRequired = false;

  /// 동의 정보를 요청하고 필요시 동의 양식을 표시
  Future<void> requestConsentInfoUpdate() async {
    final completer = Completer<void>();
    
    try {
      // UMP SDK 초기화 및 동의 정보 요청
      final params = ConsentRequestParameters(
        consentDebugSettings: kDebugMode
            ? ConsentDebugSettings(
                debugGeography:
                    DebugGeography.debugGeographyEea, // 테스트용 EU 지역 설정
                testIdentifiers: [], // 필요시 테스트 기기 ID 추가
              )
            : null,
      );

      // 콜백 기반 API 사용
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          try {
            // 성공 콜백
            if (await ConsentInformation.instance.isConsentFormAvailable()) {
              _isConsentFormAvailable = true;
              await _loadAndShowConsentFormIfRequired();
            }

            // 개인정보 보호 옵션이 필요한지 확인
            _isPrivacyOptionsRequired = 
                await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() == 
                PrivacyOptionsRequirementStatus.required;
            
            completer.complete();
          } catch (error) {
            completer.completeError(error);
          }
        },
        (FormError error) {
          // 에러 콜백
          if (kDebugMode) {
            print('ConsentService Error: $error');
          }
          completer.completeError(error);
        },
      );
      
      return completer.future;
    } catch (error) {
      if (kDebugMode) {
        print('ConsentService Error: $error');
      }
      completer.completeError(error);
      return completer.future;
    }
  }

  /// 동의 양식을 로드하고 필요시 표시
  Future<void> _loadAndShowConsentFormIfRequired() async {
    try {
      final consentStatus = await ConsentInformation.instance.getConsentStatus();

      if (consentStatus == ConsentStatus.required) {
        // 동의가 필요한 경우 양식 표시 (콜백 기반)
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? loadAndShowError) {
          if (loadAndShowError != null) {
            if (kDebugMode) {
              print('Consent Form Error: $loadAndShowError');
            }
          } else {
            if (kDebugMode) {
              print('Consent form completed successfully');
            }
          }
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Consent Form Error: $error');
      }
    }
  }

  /// 개인정보 보호 옵션 양식 표시 (사용자가 설정에서 접근할 때)
  Future<void> showPrivacyOptionsForm() async {
    if (_isPrivacyOptionsRequired) {
      try {
        // 콜백 기반 API 사용
        ConsentForm.showPrivacyOptionsForm((FormError? formError) {
          if (formError != null) {
            if (kDebugMode) {
              print('Privacy Options Form Error: $formError');
            }
          } else {
            if (kDebugMode) {
              print('Privacy options form completed successfully');
            }
          }
        });
      } catch (error) {
        if (kDebugMode) {
          print('Privacy Options Form Error: $error');
        }
      }
    }
  }

  /// 광고를 로드할 수 있는지 확인
  Future<bool> canRequestAds() async {
    final consentStatus = await ConsentInformation.instance.getConsentStatus();
    return consentStatus == ConsentStatus.notRequired ||
        consentStatus == ConsentStatus.obtained;
  }

  /// 서비스 이용 가능 여부 확인 (동의 필수 지역에서)
  Future<bool> canUseService() async {
    final consentStatus = await ConsentInformation.instance.getConsentStatus();

    // 동의가 필요없는 지역이거나 동의를 받은 경우에만 서비스 이용 가능
    if (consentStatus == ConsentStatus.notRequired ||
        consentStatus == ConsentStatus.obtained) {
      return true;
    }

    // 동의가 필요한데 받지 않은 경우
    return false;
  }

  /// 개인정보 보호 옵션이 필요한지 확인
  bool get isPrivacyOptionsRequired => _isPrivacyOptionsRequired;

  /// 동의 양식이 사용 가능한지 확인
  bool get isConsentFormAvailable => _isConsentFormAvailable;

  /// 현재 동의 상태 반환
  Future<ConsentStatus> getConsentStatus() async {
    return await ConsentInformation.instance.getConsentStatus();
  }

  /// 동의 정보 재설정 (테스트용)
  Future<void> resetConsentInfo() async {
    if (kDebugMode) {
      await ConsentInformation.instance.reset();
    }
  }
}
