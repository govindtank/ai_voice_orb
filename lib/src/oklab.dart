import 'dart:math' as math;
import 'dart:ui';

/// High-precision OKLab color space transformations and perceptual interpolation.
///
/// Standard sRGB interpolation creates desaturated muddy gray midtones between
/// complementary hues. OKLab operates in a perceptually uniform color space,
/// preserving constant perceived lightness and chromatic vibrancy.
class OklabColor {
  /// Perceptual lightness `[0.0, 1.0]`.
  final double l;

  /// Green-red chromatic coordinate.
  final double a;

  /// Blue-yellow chromatic coordinate.
  final double b;

  /// Alpha opacity channel `[0.0, 1.0]`.
  final double alpha;

  /// Creates an [OklabColor].
  const OklabColor(this.l, this.a, this.b, [this.alpha = 1.0]);

  /// Converts a Flutter [Color] from sRGB space to [OklabColor].
  factory OklabColor.fromColor(Color color) {
    // 1. sRGB to linear sRGB
    final r = _sRgbToLinear(color.r);
    final g = _sRgbToLinear(color.g);
    final b = _sRgbToLinear(color.b);

    // 2. Linear sRGB to LMS cone responses
    final lmsL = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    final lmsM = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    final lmsS = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

    // 3. Cube root non-linearity
    final l_ = _cbrt(lmsL);
    final m_ = _cbrt(lmsM);
    final s_ = _cbrt(lmsS);

    // 4. LMS to OKLab
    final okL = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
    final okA = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
    final okB = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;

    return OklabColor(okL, okA, okB, color.a);
  }

  /// Converts this [OklabColor] back to a Flutter [Color] in sRGB space.
  Color toColor() {
    // 1. OKLab to non-linear LMS
    final l_ = l + 0.3963377774 * a + 0.2158037573 * b;
    final m_ = l - 0.1055613458 * a - 0.0638541728 * b;
    final s_ = l - 0.0894841775 * a - 1.2914855480 * b;

    // 2. Cube non-linearity
    final lmsL = l_ * l_ * l_;
    final lmsM = m_ * m_ * m_;
    final lmsS = s_ * s_ * s_;

    // 3. LMS to linear sRGB
    final rLin =
        4.0767416621 * lmsL - 3.3077115913 * lmsM + 0.2309699292 * lmsS;
    final gLin =
        -1.2684380046 * lmsL + 2.6097574011 * lmsM - 0.3413193965 * lmsS;
    final bLin =
        -0.0041960863 * lmsL - 0.7034186147 * lmsM + 1.7076147010 * lmsS;

    // 4. Linear sRGB to standard sRGB
    final r = _linearToSRgb(rLin).clamp(0.0, 1.0);
    final g = _linearToSRgb(gLin).clamp(0.0, 1.0);
    final bVal = _linearToSRgb(bLin).clamp(0.0, 1.0);
    final aVal = alpha.clamp(0.0, 1.0);

    return Color.from(alpha: aVal, red: r, green: g, blue: bVal);
  }

  /// Perceptually interpolates between two colors [start] and [end] by parameter [t].
  static Color lerp(Color start, Color end, double t) {
    if (t <= 0.0) {
      return start;
    }
    if (t >= 1.0) {
      return end;
    }

    final okStart = OklabColor.fromColor(start);
    final okEnd = OklabColor.fromColor(end);

    final l = okStart.l + (okEnd.l - okStart.l) * t;
    final a = okStart.a + (okEnd.a - okStart.a) * t;
    final b = okStart.b + (okEnd.b - okStart.b) * t;
    final alpha = okStart.alpha + (okEnd.alpha - okStart.alpha) * t;

    return OklabColor(l, a, b, alpha).toColor();
  }

  /// Perceptually interpolates between two color palettes [paletteA] and [paletteB].
  static List<Color> lerpPalette(
    List<Color> paletteA,
    List<Color> paletteB,
    double t,
  ) {
    if (paletteA.isEmpty) {
      return paletteB;
    }
    if (paletteB.isEmpty) {
      return paletteA;
    }
    if (t <= 0.0) {
      return paletteA;
    }
    if (t >= 1.0) {
      return paletteB;
    }

    final count = math.max(paletteA.length, paletteB.length);
    final result = <Color>[];

    for (var i = 0; i < count; i++) {
      final colorA = paletteA[i % paletteA.length];
      final colorB = paletteB[i % paletteB.length];
      result.add(lerp(colorA, colorB, t));
    }

    return List<Color>.unmodifiable(result);
  }

  static double _sRgbToLinear(double channel) {
    if (channel <= 0.04045) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _linearToSRgb(double linear) {
    if (linear <= 0.0031308) {
      return 12.92 * linear;
    }
    return 1.055 * math.pow(linear, 1.0 / 2.4).toDouble() - 0.055;
  }

  static double _cbrt(double x) {
    if (x == 0.0) {
      return 0.0;
    }
    if (x > 0.0) {
      return math.pow(x, 1.0 / 3.0).toDouble();
    }
    return -math.pow(-x, 1.0 / 3.0).toDouble();
  }
}
