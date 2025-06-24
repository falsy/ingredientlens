import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/theme.dart';
import '../config/ad_config.dart';
import '../config/app_config.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _adFailed = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // 광고 표시 여부 (app_config.dart에서 전역 관리)
  bool get _enableAds => AppConfig.enableAds;

  @override
  void initState() {
    super.initState();
    if (_enableAds) {
      _loadBannerAd();
    } else {
      setState(() {
        _adFailed = true;
      });
    }
  }

  String get _adUnitId => AdConfig.bannerAdUnitId;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('Banner ad loaded successfully');
          }
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print(
                'Failed to load banner ad: \${error.code} - \${error.message}');
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
              _adFailed = true;
            });
          }
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('Banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('Banner ad closed');
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
    // 항상 광고 영역을 예약하고, 광고가 로드되면 표시
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _enableAds && _isBannerAdReady && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : const SizedBox.shrink(), // 광고 로딩 중이거나 비활성화된 경우 빈 공간
    );
  }
}
