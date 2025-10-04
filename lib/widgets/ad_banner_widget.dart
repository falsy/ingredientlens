import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
    try {
      final canRequestAds = await ConsentService().canRequestAds();
      if (kDebugMode) {
        print('Ad banner - canRequestAds: $canRequestAds');
      }
      
      if (canRequestAds && mounted) {
        _loadBannerAd();
      } else {
        if (kDebugMode) {
          print('Cannot request ads due to consent status');
        }
        if (mounted) {
          setState(() {
            _isBannerAdReady = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking consent for ads: $e');
      }
      if (mounted) {
        setState(() {
          _isBannerAdReady = false;
        });
      }
    }
  }

  String get _adUnitId => AdConfig.bannerAdUnitId;

  void _loadBannerAd() {
    try {
      _bannerAd = BannerAd(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (kDebugMode) {
              print('Banner ad loaded successfully');
            }
            if (mounted) {
              setState(() {
                _isBannerAdReady = true;
              });
            }
          },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print(
                'Failed to load banner ad: ${error.code} - ${error.message}');
            print('Retry count: $_retryCount / $_maxRetries');
          }
          ad.dispose();

          if (_retryCount < _maxRetries && mounted) {
            _retryCount++;
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                _loadBannerAd();
              }
            });
          } else {
            if (mounted) {
              setState(() {
                _isBannerAdReady = false;
              });
            }
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
    } catch (e) {
      if (kDebugMode) {
        print('Error loading banner ad: $e');
      }
      if (mounted) {
        setState(() {
          _isBannerAdReady = false;
        });
      }
    }
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
