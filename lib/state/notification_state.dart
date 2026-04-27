import 'package:flutter/foundation.dart';
import 'dart:async';

enum PillState { idle, notification, media, call, timer }

class NotificationData {
  final String appName;
  final String title;
  final String? body;
  final String? appIconPath;
  final String? packageName;
  final DateTime timestamp;

  const NotificationData({
    required this.appName,
    required this.title,
    this.body,
    this.appIconPath,
    this.packageName,
    required this.timestamp,
  });
}

class MediaData {
  final String trackName;
  final String artistName;
  final String? albumArtPath;
  final bool isPlaying;

  const MediaData({
    required this.trackName,
    required this.artistName,
    this.albumArtPath,
    required this.isPlaying,
  });
}

class NotificationState extends ChangeNotifier {
  PillState _pillState = PillState.idle;
  NotificationData? _currentNotification;
  MediaData? _currentMedia;
  bool _logoAnimationEnabled = true;
  bool _glowEnabled = true;
  bool _isScreenOn = true;
  final List<NotificationData> _queue = [];

  PillState get pillState => _pillState;
  NotificationData? get currentNotification => _currentNotification;
  MediaData? get currentMedia => _currentMedia;
  bool get logoAnimationEnabled => _logoAnimationEnabled && _isScreenOn;
  bool get glowEnabled => _glowEnabled;

  void pushNotification(NotificationData data) {
    if (_pillState != PillState.idle) {
      _queue.add(data);
      return;
    }
    _currentNotification = data;
    _pillState = PillState.notification;
    notifyListeners();
  }

  void collapse() {
    _pillState = PillState.idle;
    _currentNotification = null;
    notifyListeners();
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      Future.delayed(const Duration(milliseconds: 400), () {
        pushNotification(next);
      });
    }
  }

  void setMedia(MediaData data) {
    _currentMedia = data;
    _pillState = PillState.media;
    notifyListeners();
  }

  void setScreenState(bool isOn) {
    _isScreenOn = isOn;
    notifyListeners();
  }

  void toggleLogoAnimation(bool value) {
    _logoAnimationEnabled = value;
    notifyListeners();
  }

  void toggleGlow(bool value) {
    _glowEnabled = value;
    notifyListeners();
  }
}
