import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usland/state/notification_state.dart';
import 'package:usland/services/permission_service.dart';
import 'package:usland/services/notification_service.dart';
import 'package:usland/settings/settings_screen.dart';
import 'package:usland/utils/design.dart';
import 'package:usland/overlay/overlay_entry.dart';

@pragma('vm:entry-point')
void overlayMain() => overlayMainEntry();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NotificationState())],
      child: const UslandApp(),
    ),
  );
}

class UslandApp extends StatelessWidget {
  const UslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usland',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: UslandDesign.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: UslandDesign.ultraviolet,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _overlayGranted = false;
  bool _listenerGranted = false;
  bool _postNotifGranted = false;
  bool _overlayActive = false;
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService(
      state: context.read<NotificationState>(),
    );
    _checkPermissions();
    _listenScreenState();
  }

  void _listenScreenState() {
    const channel = MethodChannel('com.elsewhere.usland/events');
    channel.setMethodCallHandler((call) async {
      final state = context.read<NotificationState>();
      if (call.method == 'screenOff') state.setScreenState(false);
      if (call.method == 'screenOn') state.setScreenState(true);
    });
  }

  Future<void> _checkPermissions() async {
    final overlay = await PermissionService.checkOverlayPermission();
    final listener = await PermissionService.checkNotificationListenerPermission();
    final post = await PermissionService.checkPostNotificationsPermission();
    if (!mounted) return;
    setState(() {
      _overlayGranted = overlay;
      _listenerGranted = listener;
      _postNotifGranted = post;
    });
    if (overlay && listener && post) await _startOverlay();
  }

  Future<void> _startOverlay() async {
    if (_overlayActive) return;
    await FlutterOverlayWindow.showOverlay(
      enableDrag: false,
      overlayTitle: 'Usland',
      overlayContent: 'Overlay active',
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
      width: WindowSize.matchParent,
      height: 120,
    );
    await _notificationService.init();
    if (mounted) setState(() => _overlayActive = true);
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _overlayGranted && _listenerGranted && _postNotifGranted;
    return Scaffold(
      backgroundColor: UslandDesign.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Image.asset('assets/logo.png', height: 48,
                errorBuilder: (_, __, ___) => Text('USLAND',
                  style: GoogleFonts.dmSans(
                    color: UslandDesign.periwinkle,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Dynamic Island for Android',
                style: GoogleFonts.dmSans(
                  color: UslandDesign.textSecondary, fontSize: 14)),
              const SizedBox(height: 48),
              if (!allGranted) ...[
                Text('Permissions needed',
                  style: GoogleFonts.dmSans(
                    color: UslandDesign.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
                const SizedBox(height: 16),
                _permissionTile(
                  label: 'Draw over apps',
                  granted: _overlayGranted,
                  onTap: () async {
                    await PermissionService.requestOverlayPermission();
                    await Future.delayed(const Duration(seconds: 1));
                    _checkPermissions();
                  },
                ),
                const SizedBox(height: 8),
                _permissionTile(
                  label: 'Notification access',
                  granted: _listenerGranted,
                  onTap: () async {
                    await PermissionService.requestNotificationListenerPermission();
                    await Future.delayed(const Duration(seconds: 1));
                    _checkPermissions();
                  },
                ),
                const SizedBox(height: 8),
                _permissionTile(
                  label: 'Post notifications',
                  granted: _postNotifGranted,
                  onTap: () async {
                    await PermissionService.requestPostNotificationsPermission();
                    await Future.delayed(const Duration(seconds: 1));
                    _checkPermissions();
                  },
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: UslandDesign.periwinkle.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: UslandDesign.periwinkle.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                        color: UslandDesign.periwinkle, size: 20),
                      const SizedBox(width: 12),
                      Text('Usland is active',
                        style: GoogleFonts.dmSans(
                          color: UslandDesign.periwinkle,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  child: Text('Open Settings',
                    style: GoogleFonts.dmSans(
                      color: UslandDesign.periwinkle, fontSize: 14)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionTile({
    required String label,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: granted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: granted
              ? UslandDesign.periwinkle.withOpacity(0.4)
              : UslandDesign.textSecondary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              granted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: granted ? UslandDesign.periwinkle : UslandDesign.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                style: GoogleFonts.dmSans(
                  color: granted
                    ? UslandDesign.textPrimary
                    : UslandDesign.textSecondary,
                  fontSize: 14,
                )),
            ),
            if (!granted)
              Text('Grant →',
                style: GoogleFonts.dmSans(
                  color: UslandDesign.periwinkle, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
