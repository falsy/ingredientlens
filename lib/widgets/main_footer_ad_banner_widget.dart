import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/theme.dart';
import '../config/ad_config.dart';
import '../config/app_config.dart';
import '../services/consent_service.dart';

class MainFooterAdBannerWidget extends StatefulWidget {
  const MainFooterAdBannerWidget({super.key});

  @override
  State<MainFooterAdBannerWidget> createState() => _MainFooterAdBannerWidgetState();
}

class _MainFooterAdBannerWidgetState extends State<MainFooterAdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // 광고 표시 여부 (app_config.dart에서 전역 관리)
  bool get _enableAds => AppConfig.enableAds;

  @override
  void initState() {
    super.initState();
    if (_enableAds) {
      _checkConsentAndLoadAd();
    } else {
      setState(() {});
    }
  }

  void _checkConsentAndLoadAd() async {
    final canRequestAds = await ConsentService().canRequestAds();
    if (canRequestAds && mounted) {
      _loadBannerAd();
    } else {
      if (kDebugMode) {
        print('Cannot request ads due to consent status');
      }
      setState(() {
        _isBannerAdReady = false;
      });
    }
  }

  String get _adUnitId => AdConfig.homeFooterBannerAdUnitId;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('Home footer banner ad loaded successfully');
          }
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print(
                'Failed to load home footer banner ad: \${error.code} - \${error.message}');
            print('Retry count: \$_retryCount / \$_maxRetries');
          }
          ad.dispose();

          if (_retryCount < _maxRetries) {
            _retryCount++;
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                _loadBannerAd();
              }
            });
          } else {
            setState(() {
              _isBannerAdReady = false;
            });
          }
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('Home footer banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('Home footer banner ad closed');
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고가 비활성화된 경우 완전히 숨김
    if (!_enableAds) {
      return const SizedBox.shrink();
    }

    // 광고가 활성화된 경우에만 영역 표시
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ad Banner
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.cardBorderColor,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: _isBannerAdReady && _bannerAd != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AdWidget(ad: _bannerAd!))
              : const SizedBox.shrink(), // 광고 로딩 중인 경우 빈 공간
        ),
      ],
    );
  }
}
