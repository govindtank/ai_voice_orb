import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'orb_state.dart';
import 'orb_theme.dart';

/// GPU-accelerated [CustomPainter] rendering the multi-layer fluid neural orb,
/// ambient glow corona, and reactive constellation particles.
class OrbPainter extends CustomPainter {
  /// Continuous time parameter driving wave harmonics and fluid rotation.
  final double time;

  /// Current audio amplitude in range `[0.0, 1.0]`.
  final double amplitude;

  /// Multi-band frequency spectrum array `[bass, mid, treble]`.
  final List<double> frequencyBands;

  /// Conversational state of the voice agent.
  final OrbState state;

  /// Active visual theme palette.
  final OrbTheme theme;

  /// Whether outer ambient glow corona is rendered.
  final bool enableGlow;

  /// Whether orbiting neural spark particles are rendered.
  final bool enableParticles;

  /// Creates an [OrbPainter].
  const OrbPainter({
    required this.time,
    required this.amplitude,
    required this.frequencyBands,
    required this.state,
    required this.theme,
    this.enableGlow = true,
    this.enableParticles = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final minDimension = math.min(size.width, size.height);
    final baseRadius = minDimension * 0.32;

    if (baseRadius <= 0) {
      return;
    }

    final bass = frequencyBands.isNotEmpty ? frequencyBands[0] : 0.0;
    final treble = frequencyBands.length > 2 ? frequencyBands[2] : 0.0;

    final effectiveAmplitude = (amplitude + bass * 0.4).clamp(0.0, 1.0);
    final speed = state.baseSpeed;
    final deformation =
        state.baseDeformation * (1.0 + effectiveAmplitude * 1.5);

    // 1. Draw Outer Ambient Glow Corona
    if (enableGlow && theme.glowRadius > 0) {
      _drawGlowCorona(canvas, center, baseRadius, effectiveAmplitude);
    }

    // 2. Draw Secondary Outer Fluid Membrane (Depth layer)
    _drawFluidLayer(
      canvas: canvas,
      center: center,
      baseRadius: baseRadius * 1.05,
      deformation: deformation * 0.8,
      phaseOffset: 1.2,
      rotationSpeed: speed * 0.8,
      opacity: 0.45,
      scale: 1.0 + effectiveAmplitude * 0.08,
    );

    // 3. Draw Primary Fluid Membrane
    _drawFluidLayer(
      canvas: canvas,
      center: center,
      baseRadius: baseRadius,
      deformation: deformation,
      phaseOffset: 0.0,
      rotationSpeed: speed,
      opacity: 0.95,
      scale: 1.0 + effectiveAmplitude * 0.12,
    );

    // 4. Draw Inner Radiant Energy Core
    _drawRadiantCore(canvas, center, baseRadius * 0.45, effectiveAmplitude);

    // 5. Draw Orbiting Neural Spark Particles
    if (enableParticles && theme.particleDensity > 0) {
      _drawNeuralParticles(
        canvas,
        center,
        baseRadius,
        effectiveAmplitude,
        treble,
      );
    }
  }

  void _drawGlowCorona(
    Canvas canvas,
    Offset center,
    double radius,
    double amp,
  ) {
    final glowRadius = radius * (1.3 + theme.glowRadius + amp * 0.3);
    final glowMultiplier = state.glowMultiplier;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.glowColor
              .withValues(alpha: (0.35 * glowMultiplier).clamp(0.0, 1.0)),
          theme.glowColor
              .withValues(alpha: (0.15 * glowMultiplier).clamp(0.0, 1.0)),
          theme.glowColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: glowRadius),
      );

    canvas.drawCircle(center, glowRadius, paint);
  }

  void _drawFluidLayer({
    required Canvas canvas,
    required Offset center,
    required double baseRadius,
    required double deformation,
    required double phaseOffset,
    required double rotationSpeed,
    required double opacity,
    required double scale,
  }) {
    final path = Path();
    const pointCount = 64;
    final points = <Offset>[];

    final t = time * rotationSpeed + phaseOffset;

    for (var i = 0; i < pointCount; i++) {
      final theta = (i * 2 * math.pi) / pointCount;

      // 4 Harmonic wave formula
      final wave1 = math.sin(theta * 2.0 + t * 1.5) * 0.4;
      final wave2 = math.cos(theta * 3.0 - t * 2.0) * 0.3;
      final wave3 = math.sin(theta * 5.0 + t * 3.2) * 0.2;
      final wave4 = math.cos(theta * 1.0 + t * 0.8) * 0.25;

      final totalDeformation = (wave1 + wave2 + wave3 + wave4) * deformation;
      final r = (baseRadius * (1.0 + totalDeformation)) * scale;

      final x = center.dx + r * math.cos(theta);
      final y = center.dy + r * math.sin(theta);
      points.add(Offset(x, y));
    }

    // Connect smooth Catmull-Rom / cubic bezier spline path
    path.moveTo(
      (points[0].dx + points[pointCount - 1].dx) / 2,
      (points[0].dy + points[pointCount - 1].dy) / 2,
    );

    for (var i = 0; i < pointCount; i++) {
      final pCurr = points[i];
      final pNext = points[(i + 1) % pointCount];
      final midX = (pCurr.dx + pNext.dx) / 2;
      final midY = (pCurr.dy + pNext.dy) / 2;
      path.quadraticBezierTo(pCurr.dx, pCurr.dy, midX, midY);
    }
    path.close();

    // Create rotating Sweep Gradient for fluid body
    final gradientRotation =
        time * 0.5 * (state == OrbState.thinking ? 2.5 : 1.0);
    final sweepColors = theme.colors
        .map((c) => c.withValues(alpha: (c.a * opacity).clamp(0.0, 1.0)))
        .toList();

    // Loop gradient back to first color for seamless sweep
    if (sweepColors.isNotEmpty) {
      sweepColors.add(sweepColors.first);
    }

    final paint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        colors: sweepColors,
        transform: GradientRotation(gradientRotation),
      ).createShader(
        Rect.fromCircle(center: center, radius: baseRadius * scale * 1.2),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  void _drawRadiantCore(
    Canvas canvas,
    Offset center,
    double radius,
    double amp,
  ) {
    final coreRadius = radius * (1.0 + amp * 0.25);

    // Core glow gradient
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.coreColor.withValues(alpha: 0.95),
          theme.coreColor.withValues(alpha: 0.4),
          theme.coreColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: coreRadius),
      );

    canvas.drawCircle(center, coreRadius, corePaint);

    // Specular highlight at top-left
    final highlightCenter = Offset(
      center.dx - coreRadius * 0.35,
      center.dy - coreRadius * 0.35,
    );
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, coreRadius * 0.3);

    canvas.drawCircle(highlightCenter, coreRadius * 0.25, highlightPaint);
  }

  void _drawNeuralParticles(
    Canvas canvas,
    Offset center,
    double radius,
    double amp,
    double treble,
  ) {
    final particleCount = (14 * theme.particleDensity).round();
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < particleCount; i++) {
      // Deterministic angle & speed based on index
      final indexSeed = i * 2.3999632; // Golden angle multiplier
      final orbitSpeed = 0.4 + (i % 5) * 0.15;
      final theta = indexSeed + time * orbitSpeed;

      final radialDist =
          radius * (1.15 + (math.sin(time * 2.0 + i) * 0.12) + amp * 0.25);
      final x = center.dx + radialDist * math.cos(theta);
      final y = center.dy + radialDist * math.sin(theta);

      final pSize = 1.8 + (math.sin(time * 3.0 + i) * 0.8) + (treble * 1.5);
      final alpha = (0.3 + (math.sin(time * 4.0 + i * 2) * 0.3) + amp * 0.4)
          .clamp(0.0, 1.0);

      particlePaint.color = theme.particleColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), pSize, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.state != state ||
        oldDelegate.theme != theme ||
        oldDelegate.enableGlow != enableGlow ||
        oldDelegate.enableParticles != enableParticles ||
        oldDelegate.frequencyBands != frequencyBands;
  }
}
