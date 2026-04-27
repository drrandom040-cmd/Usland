import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'title': title,
    'body': body,
    'appIconPath': appIconPath,
    'packageName': packageName,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory NotificationData.fromJson(Map<dynamic, dynamic> json) => NotificationData(
    appName: json['appName'] ?? 'Unknown',
    title: json['title'] ?? '',
    body: json['body'],
    appIconPath: json['appIconPath'],
    packageName: json['packageName'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
  );
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

  Map<String, dynamic> toJson() => {
    'trackName': trackName,
    'artistName': artistName,
    'albumArtPath': albumArtPath,
    'isPlaying': isPlaying,
  };

  factory MediaData.fromJson(Map<dynamic, dynamic> json) => MediaData(
    trackName: json['trackName'] ?? '',
    artistName: json['artistName'] ?? '',
    albumArtPath: json['albumArtPath'],
    isPlaying: json['isPlaying'] ?? false,
  );
}

class CallData {
  final String? callerName;
  final String? callerNumber;

  const CallData({this.callerName, this.callerNumber});
}

class TimerData {
  final String? label;
  final DateTime endsAt;

  const TimerData({this.label, required this.endsAt});
}

class NotificationState extends ChangeNotifier {
  static const _channel = MethodChannel('com.elsewhere.usland/actions');

  PillState _pillState = PillState.idle;
  NotificationData? _currentNotification;
  MediaData? _currentMedia;
  CallData? _currentCall;
  TimerData? _currentTimer;
  bool _logoAnimationEnabled = true;
  bool _glowEnabled = true;
  bool _isScreenOn = true;
  bool _settingsRequested = false;
  final List<NotificationData> _queue = [];

  PillState get pillState => _pillState;
  NotificationData? get currentNotification => _currentNotification;
  MediaData? get currentMedia => _currentMedia;
  CallData? get currentCall => _currentCall;
  TimerData? get currentTimer => _currentTimer;
  bool get logoAnimationEnabled => _logoAnimationEnabled && _isScreenOn;
  bool get glowEnabled => _glowEnabled;
  bool get settingsRequested => _settingsRequested;

  NotificationData? peekQueue() {
    return _queue.isNotEmpty ? _queue.first : null;
  }

  void pushNotification(NotificationData data) {
    if (_pillState != PillState.idle) {
      if (!_queue.any((n) => n.title == data.title && n.appName == data.appName)) {
        _queue.add(data);
      }
      return;
    }
    _currentNotification = data;
    _pillState = PillState.notification;
    notifyListeners();
  }

  void collapse() {
    _pillState = PillState.idle;
    _currentNotification = null;
    _currentMedia = null;
    _currentCall = null;
    _currentTimer = null;
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

  void openSettings() {
    _settingsRequested = true;
    notifyListeners();
    _settingsRequested = false;
  }

  void openCurrentApp() {
    if (_currentNotification?.packageName != null) {
      try {
        _channel.invokeMethod('openApp', {
          'packageName': _currentNotification!.packageName,
        });
      } catch (_) {}
    }
    collapse();
  }
}
