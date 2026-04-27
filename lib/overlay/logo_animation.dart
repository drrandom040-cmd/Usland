import 'package:flutter/material.dart';

class LogoAnimation extends StatefulWidget {
  final bool isVisible;
  final bool animationEnabled;
  final bool glowEnabled;

  const LogoAnimation({
    super.key,
    required this.isVisible,
    required this.animationEnabled,
    required this.glowEnabled,
  });

  @override
  State<LogoAnimation> createState() => _LogoAnimationState();
}

class _LogoAnimationState extends State<LogoAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late AnimationController _visibilityController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _visibilityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isVisible ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(LogoAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _visibilityController.forward();
      } else {
        _visibilityController.reverse();
      }
    }
    if (!widget.animationEnabled) {
      _rotationController.stop();
      _glowController.stop();
    } else {
      if (!_rotationController.isAnimating) _rotationController.repeat();
      if (!_glowController.isAnimating) _glowController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _glowController,
        _visibilityController,
      ]),
      builder: (context, child) {
        final scale = 0.6 + (0.4 * _visibilityController.value);
        final opacity = _visibilityController.value;
        final glowOpacity = widget.glowEnabled
            ? (0.3 * (1.0 - _glowController.value))
            : 0.0;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.glowEnabled)
                  Container(
                    width: 40 + (20 * _glowController.value),
                    height: 40 + (20 * _glowController.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFCCCCFF).withOpacity(glowOpacity),
                    ),
                  ),
                RotationTransition(
                  turns: _rotationController,
                  child: Image.asset(
                    'assets/logo.png',
                    width: 28,
                    height: 28,
                    errorBuilder: (context, error, stack) => const Text(
                      'E',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
