import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/services/streak_service.dart';

class StreakCard extends StatelessWidget {
  final StreakService streakService;
  final String userId;
  final double height;

  const StreakCard({
    super.key,
    required this.streakService,
    required this.userId,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: streakService.getStreakStream(userId),
      builder: (context, snapshot) {
        final longestStreak = snapshot.data?['longestStreak'] ?? 0;
        final currentStreak = snapshot.data?['currentStreak'] ?? 0;

        return Container(
          height: height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Highest Streak",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 54),
                    const SizedBox(height: 8),
                    Text(
                      "$longestStreak",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "DAYS",
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  "Current: $currentStreak days",
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
