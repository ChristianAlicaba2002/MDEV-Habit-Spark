import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  bool _hapticsEnabled = true;
  double _soundVolume = 1.0; // 0.0 to 1.0
  bool _isInitialized = false;

  bool get hapticsEnabled => _hapticsEnabled;
  double get soundVolume => _soundVolume;

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
    _soundVolume = prefs.getDouble('soundVolume') ?? 1.0;
    _isInitialized = true;
  }

  Future<void> setHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticsEnabled', value);
  }

  Future<void> setSoundVolume(double value) async {
    _soundVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('soundVolume', value);
  }

  // 1. The "Achievement Ping" (Completion)
  Future<void> playAchievementPing() async {
    await init();
    if (_hapticsEnabled) {
      // The vibration feels like "work done"
      await HapticFeedback.heavyImpact();
    }
    if (_soundVolume > 0) {
      // Future integration: Play custom high-pitched synthwave "chime" or "pop"
      // using an audio package (e.g. audioplayers) with volume adjusted by _soundVolume.
      // For now, use a system click.
      await SystemSound.play(SystemSoundType.click);
    }
  }

  // 2. The "Interface Click" (Navigation)
  Future<void> playInterfaceClick() async {
    await init();
    if (_hapticsEnabled) {
      // It makes Flutter widgets feel like physical hardware.
      await HapticFeedback.selectionClick();
    }
    if (_soundVolume > 0) {
      // Future integration: Play custom low-frequency "thud" or "wood-block"
      await SystemSound.play(SystemSoundType.click);
    }
  }

  // 3. The "Error Note" (Warnings)
  Future<void> playErrorNote() async {
    await init();
    if (_hapticsEnabled) {
      // Two quick, low-toned pulses (a "gentle stop")
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.vibrate();
    }
    if (_soundVolume > 0) {
      // Future integration: Play synthwave "beeps" and "boops"
      await SystemSound.play(SystemSoundType.alert);
    }
  }
}
