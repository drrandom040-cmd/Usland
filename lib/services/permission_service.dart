import 'dart:io';
import 'package:flutter/services.dart';

class PermissionService {
  static const _channel = MethodChannel('com.elsewhere.usland/permissions');

  static Future<bool> checkOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  static Future<bool> checkNotificationListenerPermission() async {
    try {
      final result = await _channel
          .invokeMethod<bool>('checkNotificationListenerPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestNotificationListenerPermission() async {
    try {
      await _channel.invokeMethod('requestNotificationListenerPermission');
    } catch (_) {}
  }

  /// Only meaningful on Android 13+. Returns true on older versions.
  static Future<bool> checkPostNotificationsPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final result = await _channel
          .invokeMethod<bool>('checkPostNotificationsPermission');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> requestPostNotificationsPermission() async {
    try {
      await _channel.invokeMethod('requestPostNotificationsPermission');
    } catch (_) {}
  }

  static Future<bool> allPermissionsGranted() async {
    final overlay = await checkOverlayPermission();
    final listener = await checkNotificationListenerPermission();
    final post = await checkPostNotificationsPermission();
    return overlay && listener && post;
  }
}
