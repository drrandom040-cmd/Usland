import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotchInfo {
  final bool hasNotch;
  final Rect? cutoutBounds;
  final NotchPosition position;

  const NotchInfo({
    required this.hasNotch,
    this.cutoutBounds,
    required this.position,
  });
}

enum NotchPosition { center, left, right, none }

class NotchDetector {
  static const _channel = MethodChannel('com.elsewhere.usland/notch');

  static Future<NotchInfo> detect(BuildContext context) async {
    try {
      final result = await _channel.invokeMethod<Map>('getNotchInfo');
      if (result == null || result['hasNotch'] == false) {
        return const NotchInfo(hasNotch: false, position: NotchPosition.none);
      }

      final bounds = Rect.fromLTWH(
        (result['left'] as num).toDouble(),
        (result['top'] as num).toDouble(),
        (result['width'] as num).toDouble(),
        (result['height'] as num).toDouble(),
      );

      final screenWidth = MediaQuery.of(context).size.width;
      final centerX = bounds.left + bounds.width / 2;
      NotchPosition pos;

      if (centerX < screenWidth * 0.35) {
        pos = NotchPosition.left;
      } else if (centerX > screenWidth * 0.65) {
        pos = NotchPosition.right;
      } else {
        pos = NotchPosition.center;
      }

      return NotchInfo(hasNotch: true, cutoutBounds: bounds, position: pos);
    } catch (e) {
      return const NotchInfo(hasNotch: false, position: NotchPosition.none);
    }
  }
}
