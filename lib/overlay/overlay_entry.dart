import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usland/overlay/pill_widget.dart';
import 'package:usland/state/notification_state.dart';

// This is the entry point for the overlay window spawned by flutter_overlay_window.
// It runs in a separate Flutter engine from the main app.
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

class OverlayRoot extends StatelessWidget {
  const OverlayRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            PillWidget(),
          ],
        ),
      ),
    );
  }
}
