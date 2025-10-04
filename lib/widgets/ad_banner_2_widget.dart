import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import '../services/consent_service.dart';

class AdBanner2Widget extends StatefulWidget {
  const AdBanner2Widget({super.key});

  @override
  State<AdBanner2Widget> createState() => _AdBanner2WidgetState();
}

class _AdBanner2WidgetState extends State<AdBanner2Widget> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _checkConsentAndLoadAd();
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

  String get _adUnitId => AdConfig.banner2AdUnitId;

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
    if (!_isBannerAdReady || _bannerAd == null) {
      return const SizedBox.shrink(); // 광고가 로딩되지 않은 경우 아무것도 표시하지 않음
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ad Banner
        SizedBox(
          width: double.infinity,
          height: 80,
          child: AdWidget(ad: _bannerAd!),
        ),
      ],
    );
  }
}
