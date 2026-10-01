import 'dart:async';
import 'package:flutter/foundation.dart';
import 'orb_state.dart';
import 'orb_theme.dart';

/// Controller for driving the state, audio amplitude, frequency spectrum,
/// and themes of an [AiVoiceOrb].
class OrbController extends ChangeNotifier {
  OrbState _state;
  double _amplitude = 0.0;
  List<double> _frequencyBands = const <double>[0.0, 0.0, 0.0];
  OrbTheme? _theme;
  double _pulseBoost = 0.0;
  bool _isDisposed = false;

  Timer? _pulseTimer;
  StreamSubscription<double>? _amplitudeSub;
  StreamSubscription<List<double>>? _frequencySub;

  /// Creates an [OrbController] with initial state [initialState] and optional [theme].
  OrbController({
    OrbState initialState = OrbState.idle,
    OrbTheme? theme,
  })  : _state = initialState,
        _theme = theme;

  /// Current conversational AI state of the orb.
  OrbState get state => _state;

  /// Normalized audio amplitude in the range `[0.0, 1.0]`.
  double get amplitude => (_amplitude + _pulseBoost).clamp(0.0, 1.0);

  /// Multi-band frequency spectrum values (e.g. `[bass, mid, treble]`).
  List<double> get frequencyBands => _frequencyBands;

  /// Active custom theme override, or `null` if using the widget's default theme.
  OrbTheme? get theme => _theme;

  /// Changes the conversational AI state.
  void setState(OrbState newState) {
    if (_state == newState || _isDisposed) {
      return;
    }
    _state = newState;
    notifyListeners();
  }

  /// Sets the normalized audio amplitude `[0.0, 1.0]`.
  void setAmplitude(double amp) {
    if (_isDisposed) {
      return;
    }
    final clamped = amp.clamp(0.0, 1.0);
    if ((_amplitude - clamped).abs() < 1e-4) {
      return;
    }
    _amplitude = clamped;
    notifyListeners();
  }

  /// Sets multi-band frequency spectrum intensities.
  void setFrequencyBands(List<double> bands) {
    if (_isDisposed) {
      return;
    }
    _frequencyBands = List<double>.unmodifiable(
      bands.map((b) => b.clamp(0.0, 1.0)),
    );
    notifyListeners();
  }

  /// Updates the active theme for the orb.
  void setTheme(OrbTheme? newTheme) {
    if (_theme == newTheme || _isDisposed) {
      return;
    }
    _theme = newTheme;
    notifyListeners();
  }

  /// Triggers a sudden energy pulse on the orb (e.g. on user tap or wake-word).
  void pulse({double intensity = 0.4}) {
    if (_isDisposed) {
      return;
    }
    _pulseTimer?.cancel();
    _pulseBoost = intensity.clamp(0.0, 1.0);
    notifyListeners();

    _pulseTimer = Timer(const Duration(milliseconds: 180), () {
      if (!_isDisposed) {
        _pulseBoost = 0.0;
        notifyListeners();
      }
    });
  }

  /// Subscribes to a continuous audio amplitude stream (e.g. from mic/recorder).
  void bindAmplitudeStream(Stream<double> stream) {
    _amplitudeSub?.cancel();
    _amplitudeSub = stream.listen(setAmplitude);
  }

  /// Subscribes to an audio FFT spectrum stream.
  void bindFrequencyStream(Stream<List<double>> stream) {
    _frequencySub?.cancel();
    _frequencySub = stream.listen(setFrequencyBands);
  }

  /// Cancels any active audio stream subscriptions.
  void unbindStreams() {
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    _frequencySub?.cancel();
    _frequencySub = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pulseTimer?.cancel();
    unbindStreams();
    super.dispose();
  }
}
