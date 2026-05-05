import 'dart:async';

class SessionTimerService {
  static final SessionTimerService _instance = SessionTimerService._internal();
  factory SessionTimerService() => _instance;
  SessionTimerService._internal() {
    _startTimer();
  }

  int _seconds = 0;
  Timer? _timer;
  final _controller = StreamController<int>.broadcast();

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      _controller.add(_seconds);
    });
  }

  Stream<int> get sessionStream => _controller.stream;
  int get currentSeconds => _seconds;

  void reset() {
    _seconds = 0;
    _controller.add(_seconds);
  }

  String get formattedTime {
    int h = _seconds ~/ 3600;
    int m = (_seconds % 3600) ~/ 60;
    int s = _seconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}
