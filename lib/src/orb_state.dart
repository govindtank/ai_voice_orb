/// Operational state of the conversational AI voice agent.
enum OrbState {
  /// Idle state: Gentle, low-frequency breathing pulse when awaiting interaction.
  idle,

  /// Listening state: Highly sensitive, audio-reactive deformation synced with user speech input.
  listening,

  /// Thinking state: Energetic swirling fluid rotation while the LLM generates a response.
  thinking,

  /// Speaking state: Rhythmic outward harmonic blooms and pulse waves reflecting AI speech synthesis.
  speaking,

  /// Error state: Rapid warning vibration and alert color glow.
  error,

  /// Custom state: Open parameter space for custom animation behaviors.
  custom,
}

/// Helpful characteristics and animation metrics associated with an [OrbState].
extension OrbStateProperties on OrbState {
  /// Base fluid animation speed multiplier for this state.
  double get baseSpeed {
    switch (this) {
      case OrbState.idle:
        return 0.7;
      case OrbState.listening:
        return 1.2;
      case OrbState.thinking:
        return 2.4;
      case OrbState.speaking:
        return 1.6;
      case OrbState.error:
        return 3.0;
      case OrbState.custom:
        return 1.0;
    }
  }

  /// Base wave deformation intensity (how much the membrane warps).
  double get baseDeformation {
    switch (this) {
      case OrbState.idle:
        return 0.08;
      case OrbState.listening:
        return 0.22;
      case OrbState.thinking:
        return 0.18;
      case OrbState.speaking:
        return 0.28;
      case OrbState.error:
        return 0.35;
      case OrbState.custom:
        return 0.15;
    }
  }

  /// Base glow bloom intensity multiplier.
  double get glowMultiplier {
    switch (this) {
      case OrbState.idle:
        return 0.8;
      case OrbState.listening:
        return 1.3;
      case OrbState.thinking:
        return 1.6;
      case OrbState.speaking:
        return 1.4;
      case OrbState.error:
        return 1.8;
      case OrbState.custom:
        return 1.0;
    }
  }
}
