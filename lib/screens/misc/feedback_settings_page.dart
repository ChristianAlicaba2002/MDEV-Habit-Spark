import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/services/feedback_service.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';

class FeedbackSettingsPage extends StatefulWidget {
  const FeedbackSettingsPage({super.key});

  @override
  State<FeedbackSettingsPage> createState() => _FeedbackSettingsPageState();
}

class _FeedbackSettingsPageState extends State<FeedbackSettingsPage> {
  final _feedbackService = FeedbackService();

  bool _isLoading = true;
  late bool _hapticsEnabled;
  late double _soundVolume;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _feedbackService.init();
    if (mounted) {
      setState(() {
        _hapticsEnabled = _feedbackService.hapticsEnabled;
        _soundVolume = _feedbackService.soundVolume;
        _isLoading = false;
      });
    }
  }

  void _onHapticsChanged(bool value) {
    setState(() => _hapticsEnabled = value);
    _feedbackService.setHapticsEnabled(value);
    if (value) {
      _feedbackService.playInterfaceClick();
    }
  }

  void _onVolumeChanged(double value) {
    setState(() => _soundVolume = value);
  }

  void _onVolumeChangeEnd(double value) {
    _feedbackService.setSoundVolume(value);
    _feedbackService.playAchievementPing(); // Test the sound
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B1B),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B1B),
              Color(0xFF162A2A),
              Color(0xFF1A3333),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RoundIconButton(
                      icon: CupertinoIcons.arrow_left,
                      onTap: () => Navigator.pop(context),
                      outlined: true,
                      isSquare: true,
                    ),
                    const Text(
                      'Feedback',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Subtitle
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Text(
                  'Customize your multi-sensory experience.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Settings List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Haptics Toggle
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      blur: 0,
                      opacity: 0.1,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.hand_draw_fill, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Haptic Feedback',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Physical responses for interactions.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: _hapticsEnabled,
                            onChanged: _onHapticsChanged,
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sound Volume Slider
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      blur: 0,
                      opacity: 0.1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(CupertinoIcons.speaker_3_fill, color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sound Effects (SFX)',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Adjust the intensity of app sounds.',
                                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Icon(CupertinoIcons.speaker_fill, color: Colors.white.withOpacity(0.4), size: 16),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: AppColors.primary,
                                    inactiveTrackColor: Colors.white.withOpacity(0.1),
                                    thumbColor: Colors.white,
                                    overlayColor: AppColors.primary.withOpacity(0.2),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: _soundVolume,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 10,
                                    onChanged: _onVolumeChanged,
                                    onChangeEnd: _onVolumeChangeEnd,
                                  ),
                                ),
                              ),
                              Icon(CupertinoIcons.speaker_3_fill, color: Colors.white.withOpacity(0.4), size: 16),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              '${(_soundVolume * 100).toInt()}%',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
