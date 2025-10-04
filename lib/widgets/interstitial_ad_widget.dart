import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
import '../config/ad_config.dart';
import '../utils/theme.dart';
import '../services/consent_service.dart';

class InterstitialAdWidget extends StatefulWidget {
  final VoidCallback onAdDismissed;
  final VoidCallback? onAnalysisCancelled;
  final VoidCallback? onApiError;
  final String? customAdUnitId;
  final bool showInterstitialAd; // 전면 광고 표시 여부

  const InterstitialAdWidget({
    super.key,
    required this.onAdDismissed,
    this.onAnalysisCancelled,
    this.onApiError,
    this.customAdUnitId,
    this.showInterstitialAd = true, // 기본값 true로 설정 (전면 광고 활성화)
  });

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget>
    with SingleTickerProviderStateMixin {
  static const _channel = MethodChannel('app/system_ui');
  
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _isAdShown = false;
  bool _isLoadingAfterAd = false;
  bool _isCancelled = false;
  int _remainingSeconds = 5;
  bool _canClose = false;
  
  // 이전 시스템 UI 상태를 저장
  SystemUiMode? _previousSystemUiMode;
  List<SystemUiOverlay>? _previousOverlays;

  // 그라데이션 애니메이션을 위한 컨트롤러
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // 그라데이션 애니메이션 초기화
    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xFF4ECDC4),
      end: const Color(0xFF7FD18C),
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    ));

    _checkConsentAndLoadAd();
    // 배너 광고는 전면광고가 꺼진 후에 로드
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

  Future<void> _showAd() async {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) async {
        if (kDebugMode) print('Ad showed full screen');
        setState(() {
          _isAdShown = true;
        });
        // 광고가 화면에 표시될 때 네이티브 Android에서 fitsSystemWindows 설정
        try {
          await _channel.invokeMethod('beginAdMode');
        } catch (e) {
          if (kDebugMode) print('Failed to invoke beginAdMode: $e');
        }
      },
      onAdDismissedFullScreenContent: (ad) async {
        if (kDebugMode) print('Ad dismissed');
        ad.dispose();
        // 광고 종료 시 시스템 UI 복원
        await _restoreSystemUI();
        // 광고 종료 시 네이티브 설정 복원
        try {
          await _channel.invokeMethod('endAdMode');
        } catch (e) {
          if (kDebugMode) print('Failed to invoke endAdMode: $e');
        }
        if (!_isCancelled) {
          setState(() {
            _isAdShown = false;
            _isLoadingAfterAd = true;
          });
          // 광고가 닫혔을 때 콜백 호출 (결과 화면으로 전환)
          widget.onAdDismissed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        if (kDebugMode) print('Ad failed to show: $error');
        ad.dispose();
        // 광고 실패 시에도 시스템 UI 복원
        await _restoreSystemUI();
        // 광고 실패 시에도 네이티브 설정 복원
        try {
          await _channel.invokeMethod('endAdMode');
        } catch (e) {
          if (kDebugMode) print('Failed to invoke endAdMode: $e');
        }
        if (!_isCancelled) {
          setState(() {
            _isLoadingAfterAd = true;
          });
          widget.onAdDismissed();
        }
      },
      onAdClicked: (ad) {
        if (kDebugMode) print('Ad clicked');
      },
      onAdImpression: (ad) {
        if (kDebugMode) print('Ad impression');
      },
    );

    // 광고 표시 전 시스템 UI를 Immersive 모드로 설정
    await _prepareSystemUIForAd();
    
    // 광고 자체를 Immersive 모드로 설정 (6.0.0 신기능)
    _interstitialAd?.setImmersiveMode(true);
    
    _interstitialAd?.show();
  }

  void _closeAd() async {
    if (kDebugMode) print('Force closing ad');
    try {
      _interstitialAd?.dispose();
    } catch (e) {
      if (kDebugMode) print('Error disposing ad: $e');
    }

    // 시스템 UI 복원
    await _restoreSystemUI();

    if (!_isCancelled) {
      setState(() {
        _isAdShown = false;
        _isLoadingAfterAd = true;
      });
      // API 호출 시작
      widget.onAdDismissed();
    }
  }

  // 광고 표시 전 현재 시스템 UI 상태를 저장하고 Immersive 모드로 설정
  Future<void> _prepareSystemUIForAd() async {
    try {
      // 현재 상태를 저장 (기본값으로 edgeToEdge 가정)
      _previousSystemUiMode = SystemUiMode.edgeToEdge;
      _previousOverlays = null; // edgeToEdge는 overlays가 null
      
      // 완전히 숨김 모드 (제스처에도 반응하지 않음)
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [], // 아무것도 표시하지 않음
      );
      if (kDebugMode) print('System UI set to fully hidden mode');
    } catch (e) {
      if (kDebugMode) print('Failed to set immersive mode: $e');
    }
  }

  // 광고 종료 후 시스템 UI를 이전 상태로 복원
  Future<void> _restoreSystemUI() async {
    try {
      if (_previousSystemUiMode != null) {
        // 이전 상태로 복원
        await SystemChrome.setEnabledSystemUIMode(
          _previousSystemUiMode!,
          overlays: _previousOverlays,
        );
        if (kDebugMode) print('System UI restored to previous state: $_previousSystemUiMode');
      } else {
        // fallback: edgeToEdge 모드로 복원 (스와이프 제스처 모드)
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        if (kDebugMode) print('System UI restored to edgeToEdge mode (fallback)');
      }
    } catch (e) {
      if (kDebugMode) print('Failed to restore system UI: $e');
    }
  }

  @override
  void deactivate() {
    // 위젯이 비활성화될 때 시스템 UI 복원 (뒤로가기 등으로 인한 예상치 못한 종료)
    if (_isAdShown) {
      _restoreSystemUI();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    // dispose 시에도 시스템 UI 복원 (예상치 못한 종료 대응)
    if (_isAdShown) {
      _restoreSystemUI();
    }
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
                  bottom: MediaQuery.of(context).padding.bottom + 30, // 하단 네비게이션 바 위에 배치
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _closeAd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.blackColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.close,
                              color: AppTheme.whiteColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.close,
                              style: const TextStyle(
                                color: AppTheme.whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
            // 중앙 로딩 인디케이터
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _colorAnimation.value ?? const Color(0xFF4ECDC4),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.analyzing,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.blackColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      AppLocalizations.of(context)!.ai_analysis_message,
                      style: const TextStyle(
                        color: AppTheme.gray600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.gray100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.gray100),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color.fromARGB(180, 0, 0, 0),
                              size: 21,
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