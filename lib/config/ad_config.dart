import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdConfig {
  // Application ID (각 플랫폼의 AndroidManifest.xml, Info.plist에서 설정)
  static String get applicationId {
    if (Platform.isAndroid) {
      final id = dotenv.env['ADMOB_ANDROID_APP_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_ANDROID_APP_ID not found in environment variables');
      }
      return id;
    } else if (Platform.isIOS) {
      final id = dotenv.env['ADMOB_IOS_APP_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_IOS_APP_ID not found in environment variables');
      }
      return id;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      final id = dotenv.env['ADMOB_ANDROID_BANNER_AD_UNIT_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_ANDROID_BANNER_AD_UNIT_ID not found in environment variables');
      }
      return id;
    } else if (Platform.isIOS) {
      final id = dotenv.env['ADMOB_IOS_BANNER_AD_UNIT_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_IOS_BANNER_AD_UNIT_ID not found in environment variables');
      }
      return id;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      final id = dotenv.env['ADMOB_ANDROID_INTERSTITIAL_AD_UNIT_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_ANDROID_INTERSTITIAL_AD_UNIT_ID not found in environment variables');
      }
      return id;
    } else if (Platform.isIOS) {
      final id = dotenv.env['ADMOB_IOS_INTERSTITIAL_AD_UNIT_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_IOS_INTERSTITIAL_AD_UNIT_ID not found in environment variables');
      }
      return id;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Compare Interstitial Ad Unit ID
  static String get compareAdUnitId {
    if (Platform.isAndroid) {
      final id = dotenv.env['ADMOB_ANDROID_COMPARE_AD_UNIT_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_ANDROID_COMPARE_AD_UNIT_ID not found in environment variables');
      }
      return id;
    } else if (Platform.isIOS) {
      final id = dotenv.env['ADMOB_IOS_COMPARE_AD_UNIT_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_IOS_COMPARE_AD_UNIT_ID not found in environment variables');
      }
      return id;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Home Footer Banner Ad Unit ID
  static String get homeFooterBannerAdUnitId {
    if (Platform.isAndroid) {
      final id = dotenv.env['ADMOB_ANDROID_HOME_BOTTOM_AD_UNIT_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_ANDROID_HOME_BOTTOM_AD_UNIT_ID not found in environment variables');
      }
      return id;
    } else if (Platform.isIOS) {
      final id = dotenv.env['ADMOB_IOS_HOME_BOTTOM_AD_UNIT_ID'];
      if (id == null || id.isEmpty) {
        throw Exception('ADMOB_IOS_HOME_BOTTOM_AD_UNIT_ID not found in environment variables');
      }
      return id;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
