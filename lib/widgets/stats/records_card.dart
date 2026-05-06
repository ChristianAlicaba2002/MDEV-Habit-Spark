import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/services/health_service.dart';

class RecordsCard extends StatelessWidget {
  final HealthService healthService;
  final double height;

  const RecordsCard({
    super.key,
    required this.healthService,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
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
            "Records",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _PRStreamItem(
            label: "Longest Run",
            type: "running",
            unit: "km",
            healthService: healthService,
          ),
          const SizedBox(height: 16),
          _PRStreamItem(
            label: "Max Lift",
            type: "lifting",
            unit: "kg",
            healthService: healthService,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _PRStreamItem extends StatelessWidget {
  final String label;
  final String type;
  final String unit;
  final HealthService healthService;
  const _PRStreamItem({
    required this.label,
    required this.type,
    required this.unit,
    required this.healthService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: healthService.getActivityMonthlyStats(type),
      builder: (context, snapshot) {
        final total = snapshot.data?['total'] ?? 0.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
            ),
            Text(
              "${total.toInt()} $unit",
              style: GoogleFonts.outfit(
                color: Colors.orangeAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}
