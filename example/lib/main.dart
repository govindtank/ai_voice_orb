import 'dart:async';
import 'dart:math' as math;
import 'package:ai_voice_orb/ai_voice_orb.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AiVoiceOrbExampleApp());
}

/// Main example application widget.
class AiVoiceOrbExampleApp extends StatelessWidget {
  /// Default constructor.
  const AiVoiceOrbExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Voice Orb Playground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF06B6D4),
          brightness: Brightness.dark,
        ),
      ),
      home: const OrbPlaygroundScreen(),
    );
  }
}

/// Interactive playground screen.
class OrbPlaygroundScreen extends StatefulWidget {
  /// Default constructor.
  const OrbPlaygroundScreen({super.key});

  @override
  State<OrbPlaygroundScreen> createState() => _OrbPlaygroundScreenState();
}

class _OrbPlaygroundScreenState extends State<OrbPlaygroundScreen> {
  late final OrbController _controller;
  OrbTheme _selectedTheme = OrbTheme.geminiLive();
  bool _enableGlow = true;
  bool _enableParticles = true;
  bool _isSimulatingMic = false;
  Timer? _simTimer;
  double _manualAmplitude = 0.0;
  double _speed = 1.0;

  final Map<String, OrbTheme> _themes = {
    'Gemini Live': OrbTheme.geminiLive(),
    'Siri Horizon': OrbTheme.siriHorizon(),
    'DeepSeek Neon': OrbTheme.deepSeekNeon(),
    'Aurora Borealis': OrbTheme.auroraBorealis(),
    'Amber Flame': OrbTheme.amberFlame(),
    'Error Alert': OrbTheme.errorAlert(),
    'Monochrome': OrbTheme.monochrome(),
  };

  @override
  void initState() {
    super.initState();
    _controller = OrbController(
      initialState: OrbState.idle,
      theme: _selectedTheme,
    );
  }

  void _toggleMicSimulation(bool enabled) {
    setState(() => _isSimulatingMic = enabled);
    _simTimer?.cancel();

    if (enabled) {
      _controller.setState(OrbState.listening);
      var tick = 0.0;
      _simTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        tick += 0.15;
        final amp = (math.sin(tick) * 0.4 + math.cos(tick * 2.5) * 0.3 + 0.35)
            .clamp(0.0, 1.0);
        _controller.setAmplitude(amp);
        _controller.setFrequencyBands([
          amp * 0.9,
          (amp * 0.7 + 0.2).clamp(0.0, 1.0),
          (amp * 0.5 + 0.1).clamp(0.0, 1.0),
        ]);
      });
    } else {
      _controller.setAmplitude(0.0);
      _controller.setFrequencyBands(const [0.0, 0.0, 0.0]);
    }
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Voice Orb Playground',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Center Orb Display Area
                Center(
                  child: AiVoiceOrb(
                    controller: _controller,
                    theme: _selectedTheme,
                    size: 220,
                    speed: _speed,
                    enableGlow: _enableGlow,
                    enableParticles: _enableParticles,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Orb tapped: Pulse triggered!'),
                          duration: Duration(milliseconds: 600),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return Text(
                      'State: ${_controller.state.name.toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Controls Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1F2937)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // State Selector Chips
                      const Text(
                        'AI STATE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: OrbState.values.map((state) {
                                final isSelected = _controller.state == state;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(state.name),
                                    selected: isSelected,
                                    onSelected: (sel) {
                                      if (sel) {
                                        _controller.setState(state);
                                        if (state == OrbState.error) {
                                          setState(() {
                                            _selectedTheme =
                                                OrbTheme.errorAlert();
                                          });
                                        }
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Theme Selector
                      const Text(
                        'THEME PRESETS (OKLab BLENDING)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _themes.entries.map((entry) {
                            final isSelected = _selectedTheme == entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(entry.key),
                                selected: isSelected,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(
                                        () => _selectedTheme = entry.value);
                                    _controller.setTheme(entry.value);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Simulated Mic & Amplitude Slider
                      const Text(
                        'AUDIO INPUT & MIC STREAM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _isSimulatingMic
                                  ? _controller.amplitude
                                  : _manualAmplitude,
                              onChanged: _isSimulatingMic
                                  ? null
                                  : (val) {
                                      setState(() => _manualAmplitude = val);
                                      _controller.setAmplitude(val);
                                    },
                            ),
                          ),
                          IconButton.filledTonal(
                            icon: Icon(
                              _isSimulatingMic ? Icons.mic : Icons.mic_off,
                              color:
                                  _isSimulatingMic ? Colors.cyan : Colors.grey,
                            ),
                            onPressed: () =>
                                _toggleMicSimulation(!_isSimulatingMic),
                            tooltip: 'Toggle Simulated Voice Stream',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Animation Speed Slider
                      Row(
                        children: [
                          const Text('Speed: ', style: TextStyle(fontSize: 13)),
                          Expanded(
                            child: Slider(
                              min: 0.5,
                              max: 2.5,
                              value: _speed,
                              onChanged: (v) => setState(() => _speed = v),
                            ),
                          ),
                          Text('${_speed.toStringAsFixed(1)}x',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Visual Toggles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('Glow Corona',
                                  style: TextStyle(fontSize: 13)),
                              Switch(
                                value: _enableGlow,
                                onChanged: (v) =>
                                    setState(() => _enableGlow = v),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Particles',
                                  style: TextStyle(fontSize: 13)),
                              Switch(
                                value: _enableParticles,
                                onChanged: (v) =>
                                    setState(() => _enableParticles = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
