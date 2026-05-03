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
  late Timer _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _isRunning = true;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
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
                    Text(
                      widget.activityType.toUpperCase(),
                      style: GoogleFonts.outfit(color: widget.themeColor, letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
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
                    fontSize: 80,
                    fontWeight: FontWeight.w200,
                    fontFeatures: [const ui.FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'DURATION',
                  style: GoogleFonts.outfit(color: Colors.white24, letterSpacing: 4, fontSize: 12),
                ),
                const Spacer(),
                // Focused Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _buildLiveStat('1.24', 'DISTANCE (KM)')),
                    Container(width: 1, height: 40, color: Colors.white10),
                    Expanded(child: _buildLiveStat('12.5', 'SPEED (KM/H)')),
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
                      () => Navigator.pop(context),
                      Colors.redAccent,
                      label: 'FINISH',
                      isSmall: true,
                    ),
                    // Start/Resume Button (Center)
                    _buildControlButton(
                      CupertinoIcons.play_fill,
                      () {
                        if (!_isRunning) {
                          setState(() {
                            _stopwatch.start();
                            _isRunning = true;
                          });
                        }
                      },
                      _isRunning ? widget.themeColor.withOpacity(0.3) : widget.themeColor,
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
                          });
                        }
                      },
                      !_isRunning ? Colors.amberAccent.withOpacity(0.3) : Colors.amberAccent,
                      label: 'PAUSE',
                      isSmall: true,
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
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, Color color, {required String label, bool isLarge = false, bool isSmall = false}) {
    double size = isLarge ? 90 : 70;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: size * 0.4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(color: color.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }
}
