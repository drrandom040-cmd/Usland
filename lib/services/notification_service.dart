import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:usland/state/notification_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final NotificationState state;
  final Set<String> _mutedPackages = {};

  NotificationService({required this.state});

  Future<void> init() async {
    await _loadMutedPackages();

    NotificationListenerService.notificationsStream.listen((event) {
      _handleNotification(event);
    });
  }

  Future<void> _loadMutedPackages() async {
    final prefs = await SharedPreferences.getInstance();
    final muted = prefs.getStringList('muted_packages') ?? [];
    _mutedPackages.addAll(muted);
  }

  void _handleNotification(NotificationEvent event) {
    if (event.packageName == 'com.elsewhere.usland') return;
    if (_mutedPackages.contains(event.packageName)) return;
    if (event.hasRemoved == true) return;

    final data = NotificationData(
      appName: event.packageName ?? 'Unknown',
      title: event.title ?? '',
      body: event.content,
      packageName: event.packageName,
      timestamp: DateTime.now(),
    );

    // Update main app state
    state.pushNotification(data);

    // Share with overlay
    FlutterOverlayWindow.sendMessage({
      'type': 'notification',
      'data': data.toJson(),
    });
  }
}
