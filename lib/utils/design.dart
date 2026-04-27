import 'package:flutter/material.dart';

class UslandDesign {
  // Colors
  static const background = Color(0xFF0D0D0D);
  static const periwinkle = Color(0xFFCCCCFF);
  static const ultraviolet = Color(0xFF7B00FF);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF999999);

  // Pill dimensions
  static const pillCollapsedWidth = 120.0;
  static const pillCollapsedHeight = 34.0;
  static const pillExpandedHeightMax = 120.0;
  static const pillBorderRadius = 50.0;

  // Animation durations
  static const pillExpandDuration = Duration(milliseconds: 300);
  static const logoExitDuration = Duration(milliseconds: 200);
  static const logoEnterDuration = Duration(milliseconds: 200);
  static const rotationDuration = Duration(seconds: 6);
  static const glowDuration = Duration(seconds: 3);
  static const notificationAutoDismiss = Duration(seconds: 4);

  // Curves
  static const expandCurve = Curves.easeInOut;
  static const logoExitCurve = Curves.easeIn;
  static const logoEnterCurve = Curves.easeOut;
  static const glowCurve = Curves.easeOut;
}
