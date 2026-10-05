# ai_voice_orb

[![Pub Version](https://img.shields.io/pub/v/ai_voice_orb.svg?style=flat-square&color=blue)](https://pub.dev/packages/ai_voice_orb)
[![Pub Points](https://img.shields.io/pub/points/ai_voice_orb?style=flat-square&color=2E8B57&label=pub%20points)](https://pub.dev/packages/ai_voice_orb/score)
[![Pub Likes](https://img.shields.io/pub/likes/ai_voice_orb?style=flat-square)](https://pub.dev/packages/ai_voice_orb)
[![CI](https://github.com/govindtank/ai_voice_orb/actions/workflows/ci.yml/badge.svg)](https://github.com/govindtank/ai_voice_orb/actions)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square)](LICENSE)

Fluid, audio-reactive neural voice visualizer for Conversational AI, Gemini Live, Siri, and voice assistant applications in Flutter.

<p align="center">
  <img src="https://raw.githubusercontent.com/govindtank/ai_voice_orb/main/screenshot.svg" width="750" alt="ai_voice_orb visualizer demo"/>
</p>

---

## ⚡ Why ai_voice_orb?

Modern AI voice agents (like **Gemini Live**, **OpenAI Realtime API**, **ElevenLabs**, and **Hume AI**) require an organic, living visual feedback element rather than rigid progress bars or plain static waves.

`ai_voice_orb` provides a **120 FPS GPU-accelerated fluid shader & CustomPainter**:
- **Organic Fluid Physics**: Multi-harmonic sinusoidal wave deformation with ambient corona bloom and specular highlights.
- **Conversational State Machine**: Seamless built-in transitions for `idle`, `listening`, `thinking`, `speaking`, and `error`.
- **OKLab Perceptual Blending**: Eliminates desaturated, muddy gray midtones during animated cross-fades between complementary hues.
- **Audio Stream Reactive**: Direct stream binding for microphone amplitude ($0.0 \dots 1.0$) and multi-band FFT frequency spectrum.
- **Orbiting Neural Particles**: Dynamic constellation sparks reacting to treble frequencies and speech volume.

---

## 🚀 Features

| Feature | Description |
| :--- | :--- |
| **GPU CustomPainter** | 120 FPS fluid membrane with zero CPU raster readbacks. |
| **OKLab Color Blending** | High-precision perceptual color interpolation preserving lightness and chromatic vibrancy. |
| **Built-in Presets** | `geminiLive`, `siriHorizon`, `deepSeekNeon`, `auroraBorealis`, `amberFlame`, `monochrome`. |
| **Audio Stream Binding** | Single line hook: `controller.bindAmplitudeStream(stream)`. |
| **Interactive Gestures** | Tap to pulse, wake-word energy bloom, and custom gesture hooks. |

---

## 📦 Installation

Add `ai_voice_orb` to your `pubspec.yaml`:

```yaml
dependencies:
  ai_voice_orb: ^1.0.0
```

Or via terminal:

```bash
flutter pub add ai_voice_orb
```

---

## 🏁 Quick Start

```dart
import 'package:ai_voice_orb/ai_voice_orb.dart';
import 'package:flutter/material.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final _orbController = OrbController(initialState: OrbState.idle);

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Center(
        child: AiVoiceOrb(
          controller: _orbController,
          theme: OrbTheme.geminiLive(),
          size: 240,
          onTap: () {
            // Switch state or trigger pulse
            _orbController.setState(OrbState.listening);
          },
        ),
      ),
    );
  }
}
```

---

## 🎙️ Real-Time Audio & Microphone Binding

Bind an amplitude stream directly from your favorite audio recorder package (such as `record`, `flutter_sound`, or WebSockets):

```dart
// Continuous amplitude updates [0.0 ... 1.0]
_orbController.bindAmplitudeStream(myAudioRecorder.amplitudeStream);

// Or update manually:
_orbController.setAmplitude(0.85);

// Set multi-band frequency spectrum: [bass, mid, treble]
_orbController.setFrequencyBands([0.9, 0.5, 0.2]);
```

---

## 🎨 Theme Presets

```dart
// 1. Iconic Gemini Live (Cyan / Royal Blue / Violet)
OrbTheme.geminiLive()

// 2. Siri Horizon (Pink / Violet / Cyan / Amber)
OrbTheme.siriHorizon()

// 3. DeepSeek Neon (Cyber Cyan / Electric Ocean / Mint)
OrbTheme.deepSeekNeon()

// 4. Aurora Borealis (Northern Lights Emerald / Arctic Sky)
OrbTheme.auroraBorealis()

// 5. Amber Flame (Sunburst Orange / Coral Red / Warm Gold)
OrbTheme.amberFlame()

// 6. Minimalist Monochrome
OrbTheme.monochrome()
```

---

## 💖 Support the Project

If you find this project useful, consider supporting its active maintenance and future development:

<p align="left">
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Sponsors" /></a>
  <a href="https://www.patreon.com/govindtank"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon" /></a>
</p>

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

*Maintained with ❤️ by [Govind Tank](https://github.com/govindtank).*
