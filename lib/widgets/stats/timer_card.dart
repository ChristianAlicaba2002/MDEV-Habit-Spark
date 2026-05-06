import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/services/session_timer_service.dart';

class TimerCard extends StatelessWidget {
  final SessionTimerService timerService;
  final double height;

  const TimerCard({
    super.key,
    required this.timerService,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: timerService.sessionStream,
      initialData: timerService.currentSeconds,
      builder: (context, snapshot) {
        final seconds = snapshot.data ?? 0;
        final progress = (seconds / 86400).clamp(0.0, 1.0);
        int h = seconds ~/ 3600;
        int m = (seconds % 3600) ~/ 60;
        int s = seconds % 60;

        return Container(
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Active Minutes",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation(Colors.orange),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    "${h * 60 + m}",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                "Session Time",
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
              ),
              Text(
                "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}",
                style: GoogleFonts.outfit(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
