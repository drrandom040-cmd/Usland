import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usland/state/notification_state.dart';
import 'package:usland/utils/design.dart';
import 'package:usland/utils/notch_detector.dart';
import 'package:usland/overlay/logo_animation.dart';
import 'package:usland/overlay/notification_view.dart';
import 'package:usland/overlay/media_view.dart';
import 'package:usland/overlay/call_view.dart';
import 'package:usland/overlay/timer_view.dart';

class PillWidget extends StatefulWidget {
  const PillWidget({super.key});

  @override
  State<PillWidget> createState() => _PillWidgetState();
}

class _PillWidgetState extends State<PillWidget> {
  NotchInfo _notchInfo = const NotchInfo(
    hasNotch: false,
    position: NotchPosition.none,
  );
  Timer? _autoDismissTimer;
  bool _userTouching = false;

  @override
  void initState() {
    super.initState();
    _detectNotch();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  Future<void> _detectNotch() async {
    final info = await NotchDetector.detect(context);
    if (mounted) {
      setState(() => _notchInfo = info);
    }
  }

  void _startAutoDismiss(NotificationState state) {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(UslandDesign.notificationAutoDismiss, () {
      if (!_userTouching && mounted) {
        state.collapse();
      }
    });
  }

  double get _pillTop {
    if (_notchInfo.hasNotch && _notchInfo.cutoutBounds != null) {
      return _notchInfo.cutoutBounds!.top;
    }
    return 8.0;
  }

  double _pillLeft(BuildContext context, bool isIdle) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isIdle) {
      if (_notchInfo.hasNotch && _notchInfo.cutoutBounds != null) {
        // Center the pill over the notch horizontally
        final notchCenter =
            _notchInfo.cutoutBounds!.left + _notchInfo.cutoutBounds!.width / 2;
        return notchCenter - UslandDesign.pillCollapsedWidth / 2;
      }
      return (screenWidth - UslandDesign.pillCollapsedWidth) / 2;
    }
    // Expanded: 5% margin on each side
    return screenWidth * 0.05;
  }

  double _pillWidth(BuildContext context, bool isIdle) {
    if (isIdle) {
      if (_notchInfo.hasNotch && _notchInfo.cutoutBounds != null) {
        // Match notch width but not smaller than our min
        return _notchInfo.cutoutBounds!.width
            .clamp(UslandDesign.pillCollapsedWidth, double.infinity);
      }
      return UslandDesign.pillCollapsedWidth;
    }
    return MediaQuery.of(context).size.width * 0.9;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationState>();
    final isIdle = state.pillState == PillState.idle;

    // Kick off auto-dismiss whenever we leave idle
    if (!isIdle) {
      _startAutoDismiss(state);
    }

    return AnimatedPositioned(
      duration: UslandDesign.pillExpandDuration,
      curve: UslandDesign.expandCurve,
      top: _pillTop,
      left: _pillLeft(context, isIdle),
      child: GestureDetector(
        onTap: () {
          if (isIdle) {
            // Expand to show last notification if any queued
            final queued = state.peekQueue();
            if (queued != null) state.pushNotification(queued);
          }
        },
        onLongPress: () {
          // Open settings
          state.openSettings();
        },
        onVerticalDragEnd: (details) {
          if (!isIdle) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0) {
                // Swipe up — dismiss
                _autoDismissTimer?.cancel();
                state.collapse();
              } else if (details.primaryVelocity! > 0) {
                // Swipe down — open originating app
                state.openCurrentApp();
              }
            }
          }
        },
        onTapDown: (_) => _userTouching = true,
        onTapUp: (_) => _userTouching = false,
        onTapCancel: () => _userTouching = false,
        child: AnimatedContainer(
          duration: UslandDesign.pillExpandDuration,
          curve: UslandDesign.expandCurve,
          width: _pillWidth(context, isIdle),
          height: isIdle
              ? (_notchInfo.hasNotch && _notchInfo.cutoutBounds != null
                  ? _notchInfo.cutoutBounds!.height
                      .clamp(UslandDesign.pillCollapsedHeight, double.infinity)
                  : UslandDesign.pillCollapsedHeight)
              : UslandDesign.pillExpandedHeightMax,
          decoration: BoxDecoration(
            color: UslandDesign.background,
            borderRadius:
                BorderRadius.circular(UslandDesign.pillBorderRadius),
            boxShadow: isIdle
                ? []
                : [
                    BoxShadow(
                      color: UslandDesign.ultraviolet.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(UslandDesign.pillBorderRadius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Logo always rendered, visibility controlled inside
                LogoAnimation(
                  isVisible: isIdle,
                  animationEnabled: state.logoAnimationEnabled,
                  glowEnabled: state.glowEnabled,
                ),
                // Expanded content
                AnimatedOpacity(
                  duration: UslandDesign.logoExitDuration,
                  opacity: isIdle ? 0.0 : 1.0,
                  child: isIdle
                      ? const SizedBox.shrink()
                      : _buildExpandedContent(state),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(NotificationState state) {
    switch (state.pillState) {
      case PillState.notification:
        return NotificationView(data: state.currentNotification);
      case PillState.media:
        return MediaView(data: state.currentMedia);
      case PillState.call:
        return CallView(data: state.currentCall);
      case PillState.timer:
        return TimerView(data: state.currentTimer);
      default:
        return const SizedBox.shrink();
    }
  }
}
