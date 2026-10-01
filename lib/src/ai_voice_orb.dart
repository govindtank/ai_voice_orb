import 'package:flutter/material.dart';
import 'orb_controller.dart';
import 'orb_painter.dart';
import 'orb_theme.dart';

/// A fluid, audio-reactive neural voice visualizer widget for Conversational AI,
/// Gemini Live, Siri, and voice assistant applications.
class AiVoiceOrb extends StatefulWidget {
  /// Optional controller driving the voice orb's state and audio amplitude.
  final OrbController? controller;

  /// Visual theme and color configuration. Defaults to [OrbTheme.geminiLive].
  final OrbTheme? theme;

  /// Dimensions (width and height) of the orb in logical pixels.
  final double size;

  /// Global animation speed multiplier (defaults to 1.0).
  final double speed;

  /// Whether outer ambient glow corona is rendered.
  final bool enableGlow;

  /// Whether orbiting neural spark particles are rendered.
  final bool enableParticles;

  /// Optional callback invoked when the user taps the orb.
  final VoidCallback? onTap;

  /// Optional callback invoked when the user long-presses the orb.
  final VoidCallback? onLongPress;

  /// Creates an [AiVoiceOrb] visualizer.
  const AiVoiceOrb({
    super.key,
    this.controller,
    this.theme,
    this.size = 220.0,
    this.speed = 1.0,
    this.enableGlow = true,
    this.enableParticles = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<AiVoiceOrb> createState() => _AiVoiceOrbState();
}

class _AiVoiceOrbState extends State<AiVoiceOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  OrbController? _internalController;

  OrbController get _effectiveController =>
      widget.controller ?? (_internalController ??= OrbController());

  // Smooth theme transition caching
  OrbTheme? _previousTheme;
  OrbTheme? _currentTheme;
  double _themeTransitionProgress = 1.0;

  @override
  void initState() {
    super.initState();
    _currentTheme =
        widget.theme ?? _effectiveController.theme ?? OrbTheme.geminiLive();
    _previousTheme = _currentTheme;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _effectiveController.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(AiVoiceOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerUpdate);
      _effectiveController.addListener(_onControllerUpdate);
    }

    final newTheme =
        widget.theme ?? _effectiveController.theme ?? OrbTheme.geminiLive();
    if (_currentTheme != newTheme) {
      _previousTheme = _currentTheme;
      _currentTheme = newTheme;
      _themeTransitionProgress = 0.0;
    }
  }

  void _onControllerUpdate() {
    final controllerTheme = _effectiveController.theme;
    if (controllerTheme != null && controllerTheme != _currentTheme) {
      _previousTheme = _currentTheme;
      _currentTheme = controllerTheme;
      _themeTransitionProgress = 0.0;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController?.dispose();
    } else {
      widget.controller?.removeListener(_onControllerUpdate);
    }
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        if (_themeTransitionProgress < 1.0) {
          _themeTransitionProgress =
              (_themeTransitionProgress + 0.05).clamp(0.0, 1.0);
        }

        final activeTheme =
            (_themeTransitionProgress < 1.0 && _previousTheme != null)
                ? OrbTheme.lerp(
                    _previousTheme!,
                    _currentTheme ?? OrbTheme.geminiLive(),
                    _themeTransitionProgress,
                  )
                : (_currentTheme ?? OrbTheme.geminiLive());

        final time = _animController.value * 20.0 * widget.speed;

        final orbWidget = SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: OrbPainter(
              time: time,
              amplitude: _effectiveController.amplitude,
              frequencyBands: _effectiveController.frequencyBands,
              state: _effectiveController.state,
              theme: activeTheme,
              enableGlow: widget.enableGlow,
              enableParticles: widget.enableParticles,
            ),
          ),
        );

        if (widget.onTap != null || widget.onLongPress != null) {
          return GestureDetector(
            onTap: () {
              _effectiveController.pulse();
              widget.onTap?.call();
            },
            onLongPress: widget.onLongPress,
            behavior: HitTestBehavior.opaque,
            child: orbWidget,
          );
        }

        return orbWidget;
      },
    );
  }
}
