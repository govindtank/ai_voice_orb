import 'dart:async';
import 'package:ai_voice_orb/ai_voice_orb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OKLab Color Interpolation', () {
    test('sRGB to OKLab and back round-trip precision', () {
      const colors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.amber,
        Colors.cyan,
        Colors.white,
        Colors.black,
      ];

      for (final original in colors) {
        final ok = OklabColor.fromColor(original);
        final restored = ok.toColor();

        expect(restored.r, closeTo(original.r, 0.02));
        expect(restored.g, closeTo(original.g, 0.02));
        expect(restored.b, closeTo(original.b, 0.02));
      }
    });

    test('OKLab color lerp at t=0 and t=1', () {
      const start = Color(0xFF00FFCC);
      const end = Color(0xFFFF0066);

      expect(OklabColor.lerp(start, end, 0.0), equals(start));
      expect(OklabColor.lerp(start, end, 1.0), equals(end));
    });

    test('OKLab palette interpolation', () {
      final pA = [Colors.blue, Colors.cyan];
      final pB = [Colors.red, Colors.orange];

      final mid = OklabColor.lerpPalette(pA, pB, 0.5);
      expect(mid.length, equals(2));
      expect(mid[0], isA<Color>());
    });
  });

  group('OrbController', () {
    test('State switching and notification', () {
      final controller = OrbController(initialState: OrbState.idle);
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      expect(controller.state, equals(OrbState.idle));

      controller.setState(OrbState.listening);
      expect(controller.state, equals(OrbState.listening));
      expect(notifyCount, equals(1));

      // Setting same state does not notify
      controller.setState(OrbState.listening);
      expect(notifyCount, equals(1));
    });

    test('Amplitude clamping and stream binding', () async {
      final controller = OrbController();
      controller.setAmplitude(1.5);
      expect(controller.amplitude, equals(1.0));

      controller.setAmplitude(-0.5);
      expect(controller.amplitude, equals(0.0));

      final streamController = StreamController<double>();
      controller.bindAmplitudeStream(streamController.stream);

      streamController.add(0.75);
      await Future<void>.delayed(Duration.zero);
      expect(controller.amplitude, closeTo(0.75, 1e-3));

      await streamController.close();
      controller.dispose();
    });

    test('Frequency bands and pulse', () async {
      final controller = OrbController();
      controller.setFrequencyBands([0.8, 0.4, 0.2]);
      expect(controller.frequencyBands, equals([0.8, 0.4, 0.2]));

      controller.pulse(intensity: 0.5);
      expect(controller.amplitude, greaterThanOrEqualTo(0.5));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      controller.dispose();
    });
  });

  group('OrbTheme & Presets', () {
    test('Preset instantiation and equality', () {
      final gemini = OrbTheme.geminiLive();
      final siri = OrbTheme.siriHorizon();
      final deepseek = OrbTheme.deepSeekNeon();
      final aurora = OrbTheme.auroraBorealis();
      final flame = OrbTheme.amberFlame();
      final error = OrbTheme.errorAlert();
      final mono = OrbTheme.monochrome();

      expect(gemini.colors.length, greaterThanOrEqualTo(3));
      expect(siri.colors.length, greaterThanOrEqualTo(3));
      expect(deepseek.colors.length, greaterThanOrEqualTo(3));
      expect(aurora.colors.length, greaterThanOrEqualTo(3));
      expect(flame.colors.length, greaterThanOrEqualTo(3));
      expect(error.colors.length, greaterThanOrEqualTo(3));
      expect(mono.colors.length, greaterThanOrEqualTo(3));

      expect(gemini == OrbTheme.geminiLive(), isTrue);
      expect(gemini == siri, isFalse);
    });

    test('Theme interpolation', () {
      final a = OrbTheme.geminiLive();
      final b = OrbTheme.amberFlame();

      final lerped = OrbTheme.lerp(a, b, 0.5);
      expect(lerped.colors.length, equals(4));
      expect(lerped.glowRadius, closeTo(0.45, 1e-3));
    });
  });

  group('AiVoiceOrb Widget', () {
    testWidgets('Renders and animates cleanly without crashing',
        (tester) async {
      final controller = OrbController(initialState: OrbState.listening);
      controller.setAmplitude(0.6);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AiVoiceOrb(
                controller: controller,
                size: 200,
                theme: OrbTheme.geminiLive(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AiVoiceOrb), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Advance frames
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      controller.setState(OrbState.speaking);
      await tester.pump(const Duration(milliseconds: 50));
      expect(controller.state, equals(OrbState.speaking));

      controller.dispose();
    });

    testWidgets('Invokes onTap callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AiVoiceOrb(
                size: 150,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AiVoiceOrb));
      await tester.pump(const Duration(milliseconds: 200));

      expect(tapped, isTrue);
    });
  });
}
