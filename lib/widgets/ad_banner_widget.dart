import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/theme.dart';
import '../config/ad_config.dart';
import '../services/consent_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        // Text(
        //   AppLocalizations.of(context)!.translate('ads_title'),
        //   style: const TextStyle(
        //     color: AppTheme.gray400,
        //     fontSize: 16,
        //     fontWeight: FontWeight.w400,
        //     letterSpacing: 0,
        //     height: 1.2,
        //   ),
        // ),
        // const SizedBox(height: 6),

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
