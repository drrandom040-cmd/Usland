import 'dart:io';
import 'package:flutter/services.dart';

class ApiCompat {
  static const _channel = MethodChannel('com.elsewhere.usland/api');

  static Future<int> getSdkVersion() async {
    if (!Platform.isAndroid) return 0;
    try {
      final version = await _channel.invokeMethod<int>('getSdkVersion');
      return version ?? 26;
    } catch (e) {
      return 26;
    }
  }

  // Android 8.0+
  static bool get supportsNotificationChannels => true;

  // Android 9.0+ (API 28)
  static Future<bool> get supportsDisplayCutout async {
    return await getSdkVersion() >= 28;
  }

  // Android 11+ (API 30)
  static Future<bool> get requiresQueryAllPackages async {
    return await getSdkVersion() >= 30;
  }

  // Android 12+ (API 31)
  static Future<bool> get requiresMutablePendingIntent async {
    return await getSdkVersion() >= 31;
  }

  // Android 13+ (API 33)
  static Future<bool> get requiresPostNotificationsPermission async {
    return await getSdkVersion() >= 33;
  }

  // Android 14+ (API 34)
  static Future<bool> get requiresForegroundServiceType async {
    return await getSdkVersion() >= 34;
  }
}
