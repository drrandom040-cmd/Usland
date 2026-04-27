import 'dart:async';
import 'package:flutter/material.dart';
import 'package:usland/state/notification_state.dart';
import 'package:usland/utils/design.dart';

class TimerView extends StatefulWidget {
  final TimerData? data;

  const TimerView({super.key, required this.data});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration remaining) {
    if (remaining.isNegative) return '00:00';
    final h = remaining.inHours;
    final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) return const SizedBox.shrink();

    final remaining = widget.data!.endsAt.difference(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_outlined,
            color: UslandDesign.periwinkle,
            size: 20,
          ),
          const SizedBox(width: 10),
          if (widget.data!.label != null) ...[
            Text(
              widget.data!.label!,
              style: const TextStyle(
                color: UslandDesign.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _formatCountdown(remaining),
            style: TextStyle(
              color: UslandDesign.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
