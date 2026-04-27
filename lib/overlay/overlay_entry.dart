import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import 'package:usland/overlay/pill_widget.dart';
import 'package:usland/state/notification_state.dart';

void overlayMainEntry() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationState()),
      ],
      child: const OverlayRoot(),
    ),
  );
}

class OverlayRoot extends StatefulWidget {
  const OverlayRoot({super.key});

  @override
  State<OverlayRoot> createState() => _OverlayRootState();
}

class _OverlayRootState extends State<OverlayRoot> {
  @override
  void initState() {
    super.initState();
    _initOverlayListener();
  }

  void _initOverlayListener() {
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is Map) {
        final state = context.read<NotificationState>();
        final type = event['type'];
        final data = event['data'];

        if (type == 'notification') {
          state.pushNotification(NotificationData.fromJson(data));
        } else if (type == 'media') {
          state.setMedia(MediaData.fromJson(data));
        } else if (type == 'screen') {
          state.setScreenState(data == 'on');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.expand(
          child: Stack(
            children: [
              PillWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
