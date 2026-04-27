import 'package:notification_listener_service/notification_listener_service.dart';
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

  Future<void> mutePackage(String packageName) async {
    _mutedPackages.add(packageName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('muted_packages', _mutedPackages.toList());
  }

  Future<void> unmutePackage(String packageName) async {
    _mutedPackages.remove(packageName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('muted_packages', _mutedPackages.toList());
  }

  bool isMuted(String packageName) => _mutedPackages.contains(packageName);

  void _handleNotification(NotificationEvent event) {
    // Ignore our own notifications
    if (event.packageName == 'com.elsewhere.usland') return;

    // Ignore muted apps
    if (_mutedPackages.contains(event.packageName)) return;

    // Ignore dismissal events
    if (event.hasRemoved == true) return;

    final data = NotificationData(
      appName: event.packageName ?? 'Unknown',
      title: event.title ?? '',
      body: event.content,
      packageName: event.packageName,
      timestamp: DateTime.now(),
    );

    state.pushNotification(data);
  }
}
