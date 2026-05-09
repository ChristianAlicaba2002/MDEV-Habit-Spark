import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';

class SmartNudgesPage extends StatefulWidget {
  final String userId;

  const SmartNudgesPage({
    super.key,
    required this.userId,
  });

  @override
  State<SmartNudgesPage> createState() => _SmartNudgesPageState();
}

class _SmartNudgesPageState extends State<SmartNudgesPage> {
  // Temporary local state for the toggles. In a real app, this would be tied to Firestore or SharedPreferences.
  bool _morningEnabled = true;
  bool _afternoonEnabled = true;
  bool _eveningEnabled = true;
  bool _midnightEnabled = false;

  @override
  Widget build(BuildContext context) {
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
                      'Smart Nudges',
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
                  'Coaching, not nagging.\nAlign with the natural flow of your day.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Nudge List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildNudgeCard(
                      title: 'Morning Kickstart',
                      purpose: 'Vision & Intent',
                      description: 'Visualizing the day\'s goals.',
                      icon: CupertinoIcons.sun_max_fill,
                      iconColor: Colors.amber,
                      isEnabled: _morningEnabled,
                      onChanged: (val) => setState(() => _morningEnabled = val),
                    ),
                    _buildNudgeCard(
                      title: 'Afternoon Reset',
                      purpose: 'Momentum & Pivot',
                      description: 'Recovering from a busy morning.',
                      icon: CupertinoIcons.cloud_sun_fill,
                      iconColor: Colors.orangeAccent,
                      isEnabled: _afternoonEnabled,
                      onChanged: (val) => setState(() => _afternoonEnabled = val),
                    ),
                    _buildNudgeCard(
                      title: 'Evening Reflection',
                      purpose: 'Closure & Reward',
                      description: 'Enjoying the haptic "pop" of finishing tasks.',
                      icon: CupertinoIcons.moon_fill,
                      iconColor: Colors.amberAccent,
                      isEnabled: _eveningEnabled,
                      onChanged: (val) => setState(() => _eveningEnabled = val),
                    ),
                    _buildNudgeCard(
                      title: 'Midnight Check',
                      purpose: 'Streak Protection',
                      description: 'Final logging for the late-night grinders.',
                      icon: CupertinoIcons.sparkles,
                      iconColor: Colors.blueAccent,
                      isEnabled: _midnightEnabled,
                      onChanged: (val) => setState(() => _midnightEnabled = val),
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

  Widget _buildNudgeCard({
    required String title,
    required String purpose,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        blur: 0,
        opacity: 0.1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withOpacity(0.3)),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CupertinoSwitch(
                        value: isEnabled,
                        onChanged: onChanged,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    purpose,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
