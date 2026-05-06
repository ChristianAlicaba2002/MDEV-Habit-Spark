import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import '../../models/health_log_model.dart';
import '../../services/health_service.dart';
import '../../constants/app_colors.dart';

class RecentActivityPage extends StatelessWidget {
  final HealthService healthService;
  const RecentActivityPage({super.key, required this.healthService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E3E), Color(0xFF4A6666)],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.chevron_left, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Activity History',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<HealthLog>>(
                stream: healthService.getRecentLogsStream(limit: 50),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.warning));
                  }
                  final logs = snapshot.data ?? [];
                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.history, color: Colors.white24, size: 48),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Your activity history is empty',
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return _ActivityLogItem(log: logs[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityLogItem extends StatelessWidget {
  final HealthLog log;
  const _ActivityLogItem({required this.log});

  IconData _getIcon() {
    final type = log.type.toLowerCase();
    if (type.contains('steps')) return LucideIcons.footprints;
    if (type.contains('calor')) return LucideIcons.flame;
    if (type.contains('dist')) return LucideIcons.map_pin;
    if (type.contains('workout')) return LucideIcons.dumbbell;
    if (type.contains('sleep')) return LucideIcons.moon;
    if (type.contains('drink') || type.contains('water')) return LucideIcons.droplets;
    return LucideIcons.activity;
  }

  Color _getColor() {
    final type = log.type.toLowerCase();
    if (type.contains('steps')) return Colors.orangeAccent;
    if (type.contains('calor')) return Colors.redAccent;
    if (type.contains('dist')) return Colors.blueAccent;
    if (type.contains('workout')) return Colors.greenAccent;
    if (type.contains('sleep')) return Colors.purpleAccent;
    if (type.contains('drink') || type.contains('water')) return Colors.cyanAccent;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final isGoalCompletion = log.metadata?['isGoalCompletion'] == true;
    final color = _getColor();
    final timeStr = DateFormat('h:mm a').format(log.timestamp);
    final dateStr = DateFormat('MMM d').format(log.timestamp);
    final isToday = DateTime.now().day == log.timestamp.day && 
                   DateTime.now().month == log.timestamp.month;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGoalCompletion ? LucideIcons.circle_check : _getIcon(), 
              color: isGoalCompletion ? Colors.greenAccent : color, 
              size: 22
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGoalCompletion ? 'GOAL COMPLETED' : log.type.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isGoalCompletion ? 'Target ${log.type} reached' : '${log.value.toStringAsFixed(1)} ${log.unit}',
                  style: GoogleFonts.outfit(
                    color: isGoalCompletion ? Colors.greenAccent : color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isToday ? 'Today' : dateStr,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                timeStr,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
