import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/health_service.dart';

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
  
  // Real Sensor Data
  late Stream<StepCount> _stepCountStream;
  int _initialSteps = -1; 
  int _currentSessionSteps = 0;
  double _meters = 0.0;
  double _currentSpeed = 0.0;
  
  bool _isSensorAvailable = true;

  // Smart Mode Detection
  bool get _isMovementActivity {
    final type = widget.activityType.toLowerCase();
    return type.contains('step') || 
           type.contains('run') || 
           type.contains('walk') || 
           type.contains('bike') || 
           type.contains('hike') ||
           type.contains('cycle');
  }

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    if (_isMovementActivity) {
      _initPedometer();
    }
  }

  Future<void> _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    } else {
      setState(() => _isSensorAvailable = false);
    }
  }

  void _onStepCount(StepCount event) {
    if (!mounted || !_isMovementActivity) return;
    
    setState(() {
      if (_isRunning) {
        if (_initialSteps == -1) {
          _initialSteps = event.steps;
        }
        _currentSessionSteps = event.steps - _initialSteps;
        _meters = _currentSessionSteps * 0.75; 
      }
    });
  }

  void _onStepCountError(error) {
    debugPrint('Pedometer Error: $error');
    if (mounted) setState(() => _isSensorAvailable = false);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _isRunning) {
        setState(() {
          if (_isMovementActivity && !_isSensorAvailable) {
            _currentSessionSteps += 1;
            _meters += 0.8;
          }
          
          if (_isMovementActivity && _stopwatch.elapsedMilliseconds > 0) {
            double hours = _stopwatch.elapsedMilliseconds / 3600000;
            _currentSpeed = (_meters / 1000) / hours;
          }
        });
      }
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

  Map<String, String> _formatAdaptiveDistance(double meters) {
    if (meters < 10) return {'value': meters.toStringAsFixed(1), 'unit': 'm'};
    if (meters < 100) return {'value': (meters / 10).toStringAsFixed(1), 'unit': 'dam'};
    if (meters < 1000) return {'value': (meters / 100).toStringAsFixed(1), 'unit': 'hm'};
    return {'value': (meters / 1000).toStringAsFixed(2), 'unit': 'km'};
  }

  @override
  Widget build(BuildContext context) {
    var dist = _formatAdaptiveDistance(_meters);

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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isMovementActivity 
                              ? (_isSensorAvailable ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash_fill)
                              : CupertinoIcons.timer,
                            color: widget.themeColor,
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.activityType.toUpperCase(),
                            style: GoogleFonts.outfit(color: widget.themeColor, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Mode-based central visual
                if (!_isMovementActivity) 
                  Icon(
                    widget.activityType.toLowerCase().contains('sleep') 
                        ? CupertinoIcons.moon_zzz_fill 
                        : CupertinoIcons.timer_fill,
                    color: widget.themeColor.withOpacity(0.1),
                    size: 180,
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
                
                // Triple Stats Row (Only for movement)
                if (_isMovementActivity)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: _buildLiveStat(_currentSessionSteps.toString(), 'STEPS')),
                      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.05)),
                      Expanded(child: _buildLiveStat(dist['value']!, 'DIST (${dist['unit']})')),
                      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.05)),
                      Expanded(child: _buildLiveStat(_currentSpeed.toStringAsFixed(1), 'SPEED (KM/H)')),
                    ],
                  ),
                  
                const Spacer(),
                // 3-Button Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      CupertinoIcons.stop_fill,
                      () async {
                        double value;
                        String unit;
                        
                        if (_isMovementActivity) {
                          value = _meters / 1000;
                          unit = 'km';
                        } else {
                          // Automatically record hours (will be displayed as HH:MM:SS)
                          value = _stopwatch.elapsedMilliseconds / 3600000;
                          unit = 'hrs';
                        }

                        await HealthService().logActivity(
                          type: widget.activityType,
                          value: value,
                          unit: unit,
                          metadata: {
                            'duration': _stopwatch.elapsedMilliseconds,
                            'steps': _currentSessionSteps,
                            'speed': _currentSpeed,
                            'mode': _isMovementActivity ? 'movement' : 'timed',
                          },
                        );
                        if (mounted) Navigator.pop(context);
                      },
                      Colors.redAccent,
                      label: 'FINISH',
                    ),
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
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 9, letterSpacing: 1.0, fontWeight: FontWeight.bold)),
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
                if (!isDisabled) BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, spreadRadius: 1),
              ],
            ),
            child: Icon(icon, color: isDisabled ? Colors.white12 : color, size: size * 0.4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.outfit(color: isDisabled ? Colors.white10 : color.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ],
    );
  }
}
