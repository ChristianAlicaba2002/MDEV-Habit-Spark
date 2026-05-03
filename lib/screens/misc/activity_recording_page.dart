import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityRecordingPage extends StatefulWidget {
  final String activityType;
  final Color themeColor;

  const ActivityRecordingPage({
    super.key,
    required this.activityType,
    required this.themeColor,
  });

  @override
  State<ActivityRecordingPage> createState() => _ActivityRecordingPageState();
}

class _ActivityRecordingPageState extends State<ActivityRecordingPage> {
  late Stopwatch _stopwatch;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    // No auto-start: waiting for manual play button
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: widget.themeColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        widget.activityType.toUpperCase(),
                        style: GoogleFonts.outfit(color: widget.themeColor, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Spacer(),
                // Timer
                Text(
                  _formatTime(_stopwatch.elapsedMilliseconds),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 84,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -2,
                    fontFeatures: [const ui.FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'DURATION',
                  style: GoogleFonts.outfit(color: Colors.white12, letterSpacing: 6, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Focused Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _buildLiveStat('0.00', 'DISTANCE (KM)')),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.05)),
                    Expanded(child: _buildLiveStat('0.0', 'SPEED (KM/H)')),
                  ],
                ),
                const Spacer(),
                // 3-Button Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Finish Button (Left)
                    _buildControlButton(
                      CupertinoIcons.stop_fill,
                      () {
                        _stopwatch.stop();
                        _timer?.cancel();
                        Navigator.pop(context);
                      },
                      Colors.redAccent,
                      label: 'FINISH',
                    ),
                    // Start Button (Center)
                    _buildControlButton(
                      CupertinoIcons.play_fill,
                      () {
                        if (!_isRunning) {
                          setState(() {
                            _stopwatch.start();
                            _isRunning = true;
                            _startTimer();
                          });
                        }
                      },
                      _isRunning ? Colors.white10 : widget.themeColor,
                      label: 'START',
                      isLarge: true,
                    ),
                    // Pause Button (Right)
                    _buildControlButton(
                      CupertinoIcons.pause_fill,
                      () {
                        if (_isRunning) {
                          setState(() {
                            _stopwatch.stop();
                            _isRunning = false;
                            _timer?.cancel();
                          });
                        }
                      },
                      !_isRunning ? Colors.white10 : Colors.amberAccent,
                      label: 'PAUSE',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, Color color, {required String label, bool isLarge = false}) {
    double size = isLarge ? 95 : 75;
    bool isDisabled = color == Colors.white10;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(isDisabled ? 0.05 : 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(isDisabled ? 0.1 : 0.4), width: 2),
              boxShadow: [
                if (!isDisabled)
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Icon(icon, color: isDisabled ? Colors.white12 : color, size: size * 0.4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: isDisabled ? Colors.white10 : color.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
