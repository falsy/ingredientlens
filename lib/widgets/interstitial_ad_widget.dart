import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import '../config/app_config.dart';
import '../utils/theme.dart';
import '../services/localization_service.dart';
import '../services/consent_service.dart';

class InterstitialAdWidget extends StatefulWidget {
  final VoidCallback onAdDismissed;
  final VoidCallback? onAnalysisCancelled;
  final String? customAdUnitId;

  const InterstitialAdWidget({
    super.key,
    required this.onAdDismissed,
    this.onAnalysisCancelled,
    this.customAdUnitId,
  });

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget> {
  InterstitialAd? _interstitialAd;
  bool _isAdShown = false;
  bool _isLoadingAfterAd = false;
  bool _isCancelled = false;
  int _remainingSeconds = 5;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    if (AppConfig.enableAds) {
      _checkConsentAndLoadAd();
    } else {
      // 광고가 비활성화되어 있으면 바로 로딩 화면으로
      setState(() {
        _isLoadingAfterAd = true;
      });
      widget.onAdDismissed();
    }
  }

  void _checkConsentAndLoadAd() async {
    final canRequestAds = await ConsentService().canRequestAds();
    if (canRequestAds && mounted) {
      _loadInterstitialAd();
      _startCountdown();
    } else {
      if (kDebugMode) {
        print('Cannot request interstitial ads due to consent status');
      }
      // 동의가 없으면 광고 없이 진행
      setState(() {
        _isLoadingAfterAd = true;
      });
      widget.onAdDismissed();
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            _canClose = true;
          }
        });
      }
      return _remainingSeconds > 0 && mounted;
    });

    // 안전장치: 35초 후에도 광고가 닫히지 않으면 강제로 닫기 버튼 표시
    Future.delayed(const Duration(seconds: 35), () {
      if (mounted && _isAdShown) {
        setState(() {
          _canClose = true;
        });
      }
    });
  }

  void _loadInterstitialAd() {
    final adUnitId = widget.customAdUnitId ?? AdConfig.interstitialAdUnitId;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
          });
          _showAd();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) print('Interstitial ad failed to load: $error');
          // 광고 로드 실패 시 로딩 화면 표시하고 API 호출
          if (!_isCancelled) {
            setState(() {
              _isLoadingAfterAd = true;
            });
            widget.onAdDismissed();
          }
        },
      ),
    );
  }

  void _showAd() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) print('Ad dismissed');
        ad.dispose();
        if (!_isCancelled) {
          setState(() {
            _isAdShown = false;
            _isLoadingAfterAd = true;
          });
          // 광고가 닫혔을 때 콜백 호출 (결과 화면으로 전환)
          widget.onAdDismissed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) print('Ad failed to show: $error');
        ad.dispose();
        if (!_isCancelled) {
          setState(() {
            _isLoadingAfterAd = true;
          });
          widget.onAdDismissed();
        }
      },
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) print('Ad showed full screen');
        setState(() {
          _isAdShown = true;
        });
        // API는 이미 카메라 화면에서 시작됨
      },
      onAdClicked: (ad) {
        if (kDebugMode) print('Ad clicked');
      },
      onAdImpression: (ad) {
        if (kDebugMode) print('Ad impression');
      },
    );

    _interstitialAd?.show();
  }

  void _closeAd() {
    if (kDebugMode) print('Force closing ad');
    try {
      _interstitialAd?.dispose();
    } catch (e) {
      if (kDebugMode) print('Error disposing ad: $e');
    }

    if (!_isCancelled) {
      setState(() {
        _isAdShown = false;
        _isLoadingAfterAd = true;
      });
      // API 호출 시작
      widget.onAdDismissed();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고가 표시되는 동안은 투명한 오버레이만 표시
    if (_isAdShown && !_isLoadingAfterAd) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              if (!_canClose)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_remainingSeconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_canClose)
                Positioned(
                  top: 50,
                  right: 20,
                  child: GestureDetector(
                    onTap: _closeAd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.blackColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.translate('close'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // 광고 로딩 중이거나 광고가 닫힌 후 항상 로딩 화면 표시
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppTheme.blackColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.translate('analyzing'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            // 분석 중 취소 버튼 (로딩 화면일 때만 표시)
            if (_isLoadingAfterAd)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 분석 취소
                            setState(() {
                              _isCancelled = true;
                            });
                            if (widget.onAnalysisCancelled != null) {
                              widget.onAnalysisCancelled!();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.gray100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.gray300),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppTheme.blackColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
