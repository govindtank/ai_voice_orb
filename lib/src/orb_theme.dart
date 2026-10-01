import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'oklab.dart';

/// Visual styling and color configuration for [AiVoiceOrb].
@immutable
class OrbTheme {
  /// Palette of gradient colors used to render the fluid body.
  final List<Color> colors;

  /// High-intensity central core energy color.
  final Color coreColor;

  /// Outer ambient glow and corona bloom color.
  final Color glowColor;

  /// Blur radius factor for the ambient outer glow `[0.0, 1.0]`.
  final double glowRadius;

  /// Color of orbiting neural constellation particles.
  final Color particleColor;

  /// Particle count density factor `[0.0, 2.0]`.
  final double particleDensity;

  /// Creates a custom [OrbTheme].
  const OrbTheme({
    required this.colors,
    this.coreColor = const Color(0xFFFFFFFF),
    this.glowColor = const Color(0xFF38BDF8),
    this.glowRadius = 0.4,
    this.particleColor = const Color(0xE6FFFFFF),
    this.particleDensity = 1.0,
  });

  /// Iconic Gemini Live theme: Electric Cyan, Deep Royal Blue, Indigo, and Bright Violet.
  factory OrbTheme.geminiLive() {
    return const OrbTheme(
      colors: [
        Color(0xFF06B6D4), // Cyan 500
        Color(0xFF3B82F6), // Blue 500
        Color(0xFF6366F1), // Indigo 500
        Color(0xFF8B5CF6), // Purple 500
      ],
      coreColor: Color(0xFFFFFFFF),
      glowColor: Color(0xFF38BDF8),
      glowRadius: 0.45,
      particleColor: Color(0xEEBAE6FD),
      particleDensity: 1.2,
    );
  }

  /// Siri Horizon dynamic multi-color gradient theme.
  factory OrbTheme.siriHorizon() {
    return const OrbTheme(
      colors: [
        Color(0xFFFF2A85), // Neon Pink
        Color(0xFF8B5CF6), // Violet
        Color(0xFF06B6D4), // Cyan
        Color(0xFFFBBF24), // Amber
      ],
      coreColor: Color(0xFFFFF0F5),
      glowColor: Color(0xFFFF2A85),
      glowRadius: 0.5,
      particleColor: Color(0xFFFDE047),
      particleDensity: 1.0,
    );
  }

  /// DeepSeek futuristic neon cyan and deep electric ocean blue.
  factory OrbTheme.deepSeekNeon() {
    return const OrbTheme(
      colors: [
        Color(0xFF00F0FF), // Cyber Cyan
        Color(0xFF0051FF), // Electric Royal Blue
        Color(0xFF00FFA3), // Neon Mint
        Color(0xFF1E1B4B), // Deep Navy
      ],
      coreColor: Color(0xFFE0F2FE),
      glowColor: Color(0xFF00F0FF),
      glowRadius: 0.4,
      particleColor: Color(0xFF67E8F9),
      particleDensity: 1.1,
    );
  }

  /// Aurora Borealis shimmering northern lights green and arctic sky.
  factory OrbTheme.auroraBorealis() {
    return const OrbTheme(
      colors: [
        Color(0xFF10B981), // Emerald
        Color(0xFF34D399), // Mint
        Color(0xFF38BDF8), // Arctic Sky
        Color(0xFF059669), // Jade
      ],
      coreColor: Color(0xFFECFDF5),
      glowColor: Color(0xFF34D399),
      glowRadius: 0.45,
      particleColor: Color(0xFFA7F3D0),
      particleDensity: 0.9,
    );
  }

  /// Amber Flame fiery sunburst orange and warm golden embers.
  factory OrbTheme.amberFlame() {
    return const OrbTheme(
      colors: [
        Color(0xFFEF4444), // Coral Red
        Color(0xFFF97316), // Sunburst Orange
        Color(0xFFFBBF24), // Amber
        Color(0xFFB45309), // Warm Ochre
      ],
      coreColor: Color(0xFFFFFBEB),
      glowColor: Color(0xFFF97316),
      glowRadius: 0.45,
      particleColor: Color(0xFFFDE68A),
      particleDensity: 1.3,
    );
  }

  /// Error alert pulsating crimson and amber warning theme.
  factory OrbTheme.errorAlert() {
    return const OrbTheme(
      colors: [
        Color(0xFFEF4444), // Red 500
        Color(0xFFDC2626), // Red 600
        Color(0xFF991B1B), // Red 800
        Color(0xFFF59E0B), // Amber 500
      ],
      coreColor: Color(0xFFFEF2F2),
      glowColor: Color(0xFFEF4444),
      glowRadius: 0.55,
      particleColor: Color(0xFFFCA5A5),
      particleDensity: 1.5,
    );
  }

  /// Minimalist Monochrome dark/light theme.
  factory OrbTheme.monochrome() {
    return const OrbTheme(
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFCBD5E1),
        Color(0xFF64748B),
        Color(0xFF334155),
      ],
      coreColor: Color(0xFFFFFFFF),
      glowColor: Color(0xFF94A3B8),
      glowRadius: 0.35,
      particleColor: Color(0xFFE2E8F0),
      particleDensity: 0.8,
    );
  }

  /// Perceptually interpolates between [a] and [b] using OKLab color space.
  static OrbTheme lerp(OrbTheme a, OrbTheme b, double t) {
    if (t <= 0.0) {
      return a;
    }
    if (t >= 1.0) {
      return b;
    }

    return OrbTheme(
      colors: OklabColor.lerpPalette(a.colors, b.colors, t),
      coreColor: OklabColor.lerp(a.coreColor, b.coreColor, t),
      glowColor: OklabColor.lerp(a.glowColor, b.glowColor, t),
      glowRadius: a.glowRadius + (b.glowRadius - a.glowRadius) * t,
      particleColor: OklabColor.lerp(a.particleColor, b.particleColor, t),
      particleDensity:
          a.particleDensity + (b.particleDensity - a.particleDensity) * t,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is OrbTheme &&
        listEquals(other.colors, colors) &&
        other.coreColor == coreColor &&
        other.glowColor == glowColor &&
        other.glowRadius == glowRadius &&
        other.particleColor == particleColor &&
        other.particleDensity == particleDensity;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(colors),
        coreColor,
        glowColor,
        glowRadius,
        particleColor,
        particleDensity,
      );
}
