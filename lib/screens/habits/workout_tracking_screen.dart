import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/app_text_styles.dart';

class WorkoutTrackingScreen extends StatefulWidget {
  final String workoutType;

  const WorkoutTrackingScreen({
    super.key,
    required this.workoutType,
  });

  @override
  State<WorkoutTrackingScreen> createState() => _WorkoutTrackingScreenState();
}

class _WorkoutTrackingScreenState extends State<WorkoutTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.workoutType,
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 4 Stat Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  icon: CupertinoIcons.time,
                  label: 'Duration',
                  value: '0:00',
                ),
                _buildStatCard(
                  icon: CupertinoIcons.location,
                  label: 'Distance',
                  value: '0.0 km',
                ),
                _buildStatCard(
                  icon: CupertinoIcons.flame,
                  label: 'Calories',
                  value: '0 kcal',
                ),
                _buildStatCard(
                  icon: CupertinoIcons.speedometer,
                  label: 'Pace',
                  value: '0:00/km',
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Steps Today Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.person_2,
                        size: 28,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Steps Today',
                        style: TextStyle(
                          color: Colors.white.withAlpha(150),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'steps',
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
