import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'activity_recording_page.dart';

class StatsDetailsPage extends StatefulWidget {
  const StatsDetailsPage({super.key});

  @override
  State<StatsDetailsPage> createState() => _StatsDetailsPageState();
}

class _StatsDetailsPageState extends State<StatsDetailsPage> {
  DateTime _displayMonth = DateTime.now();

  void _showStatProgressModal(String title, String unit, Color color, IconData icon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xFF1D3D3D).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '$title Progress',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            labelColor: color,
                            unselectedLabelColor: Colors.white54,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
                            tabs: const [
                              Tab(text: 'Today'),
                              Tab(text: 'Weekly'),
                              Tab(text: 'Monthly'),
                              Tab(icon: Icon(CupertinoIcons.calendar, size: 18)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 280, // Slightly reduced to make room for buttons
                          child: TabBarView(
                            children: [
                              _buildTotalView('Current Total', '5,400', unit, 'Excellent', color),
                              _buildTotalView('Weekly Total', '35,210', unit, 'On Track', color),
                              _buildTotalView('Monthly Total', '142,800', unit, 'Great', color),
                              _buildHistoryCalendarView(color, unit, setModalState),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close modal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivityRecordingPage(
                              activityType: title,
                              themeColor: color,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.play_fill, size: 20),
                      label: Text('START RECORDING', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(color: Colors.white10),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCalendarView(Color color, String unit, StateSetter setModalState) {
    int daysInMonth = DateUtils.getDaysInMonth(_displayMonth.year, _displayMonth.month);
    String monthYear = DateFormat('MMMM yyyy').format(_displayMonth);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daily History', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setModalState(() {
                      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
                    });
                  },
                  icon: const Icon(CupertinoIcons.chevron_left, color: Colors.white54, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Text(monthYear, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    setModalState(() {
                      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
                    });
                  },
                  icon: const Icon(CupertinoIcons.chevron_right, color: Colors.white54, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              int day = index + 1;
              String value = (day * 150 + (_displayMonth.month * 10)).toString(); // Mock dynamic data
              bool isToday = day == DateTime.now().day && _displayMonth.month == DateTime.now().month && _displayMonth.year == DateTime.now().year;
              
              return Container(
                decoration: BoxDecoration(
                  color: isToday ? color.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isToday ? color.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(day.toString(), style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(value, style: GoogleFonts.outfit(color: isToday ? color : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(unit, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 7)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalView(String label, String total, String unit, String status, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              total,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                unit.toUpperCase(),
                style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.checkmark_seal_fill, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                'Status: $status',
                style: GoogleFonts.outfit(color: color, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Health Insights',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E3E), Color(0xFF4A6666)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 10),
              _buildMainChart(),
              const SizedBox(height: 30),
              _buildSectionHeader('Detailed Activity'),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildHealthStatCard('Steps', '5,400', 'steps', 0.75, 'Good', Icons.directions_walk, Colors.tealAccent),
                  _buildHealthStatCard('Calories', '312', 'KCAL', 0.45, 'Average', CupertinoIcons.flame, Colors.orangeAccent),
                  _buildHealthStatCard('Distance', '4.2', 'KM', 0.85, 'Great', CupertinoIcons.map, Colors.blueAccent),
                  _buildHealthStatCard('Sleep', '7.5', 'HRS', 0.90, 'Good', CupertinoIcons.moon, Colors.purpleAccent),
                ],
              ),
              const SizedBox(height: 40),
              _buildLogButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMainChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
              ),
              const Icon(CupertinoIcons.graph_square, color: Colors.orange, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Mon', 0.4),
                _buildChartBar('Tue', 0.7),
                _buildChartBar('Wed', 0.9),
                _buildChartBar('Thu', 0.5),
                _buildChartBar('Fri', 0.8),
                _buildChartBar('Sat', 0.6),
                _buildChartBar('Sun', 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 100 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orange.withOpacity(0.8), Colors.orange.withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildHealthStatCard(String title, String value, String unit, double progress, String badge, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showStatProgressModal(title, unit, color, icon),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4CAF50),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: -4,
              right: -4,
              child: IconButton(
                icon: Icon(CupertinoIcons.plus_circle, color: Colors.white.withOpacity(0.3), size: 20),
                onPressed: () {},
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation(Colors.orange),
                    ),
                    Icon(icon, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Colors.orange, Color(0xFFFF8C00)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          'Log Today\'s Activity',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
