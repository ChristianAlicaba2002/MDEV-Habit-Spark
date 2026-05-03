import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'activity_recording_page.dart';
import '../../services/health_service.dart';
import '../../models/health_log_model.dart';

class StatsDetailsPage extends StatefulWidget {
  const StatsDetailsPage({super.key});

  @override
  State<StatsDetailsPage> createState() => _StatsDetailsPageState();
}

class _StatsDetailsPageState extends State<StatsDetailsPage> {
  DateTime _displayMonth = DateTime.now();
  final HealthService _healthService = HealthService();

  // Modal State
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.directions_walk;
  String _selectedUnit = 'km';
  
  final List<String> _unitOptions = ['km', 'm', 'cm', 'hrs', 'mins', 'steps', 'kcal', 'kg', 'ml', 'count'];

  // Icon Library with Keywords for searching
  final List<Map<String, dynamic>> _iconLibrary = [
    {'icon': Icons.directions_walk, 'tags': 'steps walk move'},
    {'icon': Icons.run_circle, 'tags': 'run jog sprint fast'},
    {'icon': Icons.directions_bike, 'tags': 'cycle bike bicycle ride'},
    {'icon': Icons.fitness_center, 'tags': 'gym lift weight workout'},
    {'icon': Icons.self_improvement, 'tags': 'yoga meditate calm zen'},
    {'icon': Icons.pool, 'tags': 'swim water pool'},
    {'icon': Icons.hiking, 'tags': 'hike mountain climb forest'},
    {'icon': Icons.sports_basketball, 'tags': 'ball basketball hoop'},
    {'icon': Icons.sports_soccer, 'tags': 'ball soccer football goal'},
    {'icon': Icons.sports_tennis, 'tags': 'ball tennis racket'},
    {'icon': Icons.bedtime, 'tags': 'sleep night rest moon'},
    {'icon': Icons.local_drink, 'tags': 'water drink thirst fluid'},
    {'icon': Icons.restaurant, 'tags': 'eat food meal dinner lunch'},
    {'icon': Icons.timer, 'tags': 'time stop watch clock'},
    {'icon': Icons.favorite, 'tags': 'heart love health'},
    {'icon': Icons.bolt, 'tags': 'power energy fast flash'},
    {'icon': Icons.psychology, 'tags': 'brain mind focus think'},
    {'icon': Icons.auto_stories, 'tags': 'read book study learn'},
    {'icon': Icons.edit, 'tags': 'write draw sketch note'},
    {'icon': Icons.code, 'tags': 'code program tech build'},
    {'icon': Icons.music_note, 'tags': 'music song listen audio'},
    {'icon': Icons.brush, 'tags': 'art paint craft hobby'},
    {'icon': Icons.camera_alt, 'tags': 'photo video camera shoot'},
    {'icon': Icons.pets, 'tags': 'dog cat pet animal'},
    {'icon': Icons.cleaning_services, 'tags': 'clean tidy home chores'},
    {'icon': Icons.eco, 'tags': 'green nature plant garden'},
    {'icon': Icons.savings, 'tags': 'money save budget coin'},
    {'icon': Icons.shopping_cart, 'tags': 'buy shop store groceries'},
    {'icon': Icons.work, 'tags': 'work office job business'},
    {'icon': Icons.home, 'tags': 'home house family stay'},
    {'icon': Icons.celebration, 'tags': 'party fun birthday gift'},
    {'icon': Icons.star, 'tags': 'rank gold best win'},
  ];

  void _showCreateActivityModal({String? editOldName}) {
    String searchQuery = '';
    bool isEditing = editOldName != null;
    if (isEditing) {
      _nameController.text = editOldName;
    } else {
      _nameController.clear();
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredIcons = _iconLibrary
              .where((item) => item['tags'].toString().contains(searchQuery.toLowerCase()))
              .toList();

          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: const Color(0xFF1D3D3D).withOpacity(0.98),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 24),
                  Text(isEditing ? 'Edit Activity' : 'New Activity', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // Search Bar for Icons
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      onChanged: (v) => setModalState(() => searchQuery = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search icons (e.g. run, gym)...',
                        hintStyle: TextStyle(color: Colors.white24),
                        prefixIcon: Icon(CupertinoIcons.search, color: Colors.white24, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Icon Selector Grid (Filtered)
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredIcons.length,
                      itemBuilder: (context, index) {
                        final icon = filteredIcons[index]['icon'] as IconData;
                        bool isSelected = _selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setModalState(() => _selectedIcon = icon),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.tealAccent.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? Colors.tealAccent : Colors.white10),
                            ),
                            child: Icon(icon, color: isSelected ? Colors.tealAccent : Colors.white24, size: 24),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildModalTextField('Activity name...', _nameController, CupertinoIcons.pencil),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_nameController.text.isEmpty) return;
                        
                        if (isEditing) {
                          await _healthService.renameActivityType(editOldName!, _nameController.text);
                        } else {
                          await _healthService.logActivity(
                            type: _nameController.text,
                            value: 0,
                            unit: 'hrs',
                          );
                        }
                        
                        _nameController.clear();
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(isEditing ? 'Update Activity' : 'Add Activity', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalTextField(String hint, TextEditingController controller, IconData icon, {bool isNumeric = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

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
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
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
                        child: Text('$title Progress', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityRecordingPage(activityType: title, themeColor: color)));
                        },
                        icon: Icon(CupertinoIcons.play_circle_fill, color: color, size: 28),
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
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                          child: TabBar(
                            indicator: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
                            labelColor: color,
                            unselectedLabelColor: Colors.white54,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
                            tabs: const [Tab(text: 'Today'), Tab(text: 'Weekly'), Tab(text: 'Monthly'), Tab(icon: Icon(CupertinoIcons.calendar, size: 18))],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 280,
                          child: TabBarView(
                            children: [
                              _buildTotalStreamView('Today\'s Total', title, unit, 'Excellent', color, DateTime.now(), DateTime.now().add(const Duration(days: 1))),
                              _buildTotalStreamView('Weekly Total', title, unit, 'On Track', color, DateTime.now().subtract(const Duration(days: 7)), DateTime.now()),
                              _buildTotalStreamView('Monthly Total', title, unit, 'Great', color, DateTime.now().subtract(const Duration(days: 30)), DateTime.now()),
                              _buildHistoryCalendarView(color, unit, setModalState),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _buildLogActionButton(title, color),
                  const SizedBox(height: 12),
                  _buildCloseButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalStreamView(String label, String type, String unit, String status, Color color, DateTime start, DateTime end) {
    return StreamBuilder<double>(
      stream: _healthService.getTypeTotalForPeriod(type, start, end),
      builder: (context, snapshot) {
        String total = snapshot.hasData ? snapshot.data!.toStringAsFixed(snapshot.data! % 1 == 0 ? 0 : 1) : '0';
        return _buildTotalView(label, total, unit, status, color);
      },
    );
  }

  Widget _buildLogActionButton(String title, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityRecordingPage(activityType: title, themeColor: color)));
        },
        icon: const Icon(CupertinoIcons.play_fill, size: 20),
        label: Text('START RECORDING', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      ),
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.05),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.white10)),
        ),
        child: const Text('Close'),
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
                IconButton(onPressed: () => setModalState(() => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1)), icon: const Icon(CupertinoIcons.chevron_left, color: Colors.white54, size: 16)),
                const SizedBox(width: 12),
                Text(monthYear, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 12),
                IconButton(onPressed: () => setModalState(() => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1)), icon: const Icon(CupertinoIcons.chevron_right, color: Colors.white54, size: 16)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<HealthLog>>(
            stream: _healthService.getDailyLogs(_displayMonth),
            builder: (context, snapshot) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.8),
                itemCount: daysInMonth,
                itemBuilder: (context, index) {
                  int day = index + 1;
                  bool isToday = day == DateTime.now().day && _displayMonth.month == DateTime.now().month && _displayMonth.year == DateTime.now().year;
                  return Container(
                    decoration: BoxDecoration(color: isToday ? color.withOpacity(0.2) : Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10), border: Border.all(color: isToday ? color.withOpacity(0.4) : Colors.white.withOpacity(0.05))),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(day.toString(), style: GoogleFonts.outfit(color: Colors.white70, fontSize: 10)), const SizedBox(height: 4), Text('0', style: GoogleFonts.outfit(color: isToday ? color : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)), Text(unit, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 7))]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getSmartUnit(String type, double value) {
    final t = type.toLowerCase();
    if (t.contains('step')) {
      return 'steps';
    }
    if (t.contains('walk') || t.contains('run') || t.contains('bike') || t.contains('cycle') || t.contains('distance')) {
      return 'km';
    }
    if (t.contains('eat') || t.contains('water') || t.contains('drink')) {
      return 'ml';
    }
    
    // Time-based detection
    double seconds = value * 3600;
    if (seconds < 60) return 'secs';
    if (seconds < 3600) return 'mins';
    return 'hrs';
  }

  String _formatTotalValue(double value, String unit) {
    if (unit.toLowerCase() == 'hrs' || unit.toLowerCase() == 'mins' || unit.toLowerCase() == 'secs') {
      int totalSeconds = unit.toLowerCase() == 'hrs' 
          ? (value * 3600).round() 
          : (unit.toLowerCase() == 'mins' ? (value * 60).round() : value.round());
      
      if (totalSeconds < 60) {
        return "$totalSeconds";
      }
      
      int m = totalSeconds ~/ 60;
      int s = totalSeconds % 60;
      
      if (m < 60) {
        return "$m:${s.toString().padLeft(2, '0')}";
      }
      
      int h = m ~/ 60;
      int remM = m % 60;
      return "$h:${remM.toString().padLeft(2, '0')}";
    }
    
    return value == 0 ? "0" : (value < 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(1));
  }

  Widget _buildTotalView(String label, String totalStr, String unit, String status, Color color) {
    double value = double.tryParse(totalStr) ?? 0.0;
    String smartUnit = _getSmartUnit(label, value);
    String formattedValue = _formatTotalValue(value, unit);
    bool isTime = unit.toLowerCase() == 'hrs' || unit.toLowerCase() == 'mins' || unit.toLowerCase() == 'secs';

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
              formattedValue,
              style: GoogleFonts.outfit(
                color: Colors.white, 
                fontSize: isTime ? 64 : 72, 
                fontWeight: FontWeight.w900,
                letterSpacing: isTime ? -2 : -1,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(bottom: isTime ? 12 : 16),
              child: Text(
                smartUnit,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(CupertinoIcons.back, color: Colors.white), onPressed: () => Navigator.pop(context)), title: Text('Health Insights', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold))),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2C3E3E), Color(0xFF4A6666)])),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 10),
              _buildMainChart(),
              const SizedBox(height: 30),
              _buildSectionHeader('Detailed Activity'),
              const SizedBox(height: 16),
              
              StreamBuilder<List<HealthLog>>(
                stream: _healthService.getDailyLogs(DateTime.now()),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 10)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator(color: Colors.orangeAccent));
                  }
                  
                  final activities = snapshot.data ?? [];
                  final uniqueTypes = activities.map((e) => e.type.toLowerCase()).toSet().toList();
                  final displayTypes = uniqueTypes.isEmpty ? ['steps', 'calories', 'distance', 'sleep'] : uniqueTypes;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.0),
                    itemCount: displayTypes.length,
                    itemBuilder: (context, index) {
                      String type = displayTypes[index];
                      Color color = _getThemeColor(type);
                      IconData icon = _getThemeIcon(type);
                      String unit = activities.firstWhere((e) => e.type.toLowerCase() == type, orElse: () => HealthLog(userId: '', type: type, value: 0, unit: _getDefaultUnit(type), timestamp: DateTime.now())).unit;
                      return _buildHealthStatTile(type.toUpperCase(), unit, 10000, icon, color);
                    },
                  );
                },
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

  Color _getThemeColor(String type) {
    switch (type.toLowerCase()) {
      case 'steps': return Colors.tealAccent;
      case 'calories': return Colors.orangeAccent;
      case 'distance': return Colors.blueAccent;
      case 'sleep': return Colors.purpleAccent;
      case 'gym': return Colors.redAccent;
      case 'yoga': return Colors.pinkAccent;
      case 'water': return Colors.cyanAccent;
      default: return Colors.orangeAccent;
    }
  }

  IconData _getThemeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'steps': return Icons.directions_walk;
      case 'calories': return CupertinoIcons.flame;
      case 'distance': return CupertinoIcons.map;
      case 'sleep': return CupertinoIcons.moon;
      case 'gym': return Icons.fitness_center;
      case 'yoga': return Icons.self_improvement;
      case 'water': return Icons.local_drink;
      default: return Icons.bolt;
    }
  }

  String _getDefaultUnit(String type) {
    switch (type.toLowerCase()) {
      case 'steps': return 'steps';
      case 'calories': return 'kcal';
      case 'distance': return 'km';
      case 'sleep': return 'hrs';
      default: return 'unit';
    }
  }

  void _showActivityOptions(String type, Color color) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Manage $type', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showCreateActivityModal(editOldName: type);
            },
            child: const Text('Edit Activity'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(type);
            },
            child: const Text('Delete Activity'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D3D3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
        title: Text('Delete $type?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('This will remove the activity and all its recorded data. This cannot be undone.', style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () async {
              await _healthService.deleteActivityType(type);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatTile(String title, String unit, double goal, IconData icon, Color color) {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = start.add(const Duration(days: 1));

    return StreamBuilder<double>(
      stream: _healthService.getTypeTotalForPeriod(title, start, end),
      builder: (context, snapshot) {
        double current = snapshot.data ?? 0;
        double progress = (current / goal).clamp(0.0, 1.0);
        
        // Use the smart stopwatch formatting for the tiles too!
        String valueStr = _formatTotalValue(current, unit);
        bool isTime = unit.toLowerCase() == 'hrs' || unit.toLowerCase() == 'mins';
            
        String badge = current >= goal ? 'Goal!' : (current > 0 ? 'Active' : 'Start');

        return GestureDetector(
          onTap: () => _showStatProgressModal(title, unit, color, icon),
          onLongPress: () => _showActivityOptions(title, color),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(title, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6), fontSize: 13)), 
                    const SizedBox(height: 4), 
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end, 
                      children: [
                        Text(
                          valueStr, 
                          style: GoogleFonts.outfit(
                            color: Colors.white, 
                            fontSize: isTime ? 34 : 38, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: isTime ? -1.5 : -1,
                          )
                        ), 
                        const SizedBox(width: 6),
                        Padding(
                          padding: EdgeInsets.only(bottom: isTime ? 6 : 8),
                          child: Text(
                            _getSmartUnit(title, current),
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]
                    ), 
                    const Spacer(), 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), 
                      child: Text(badge, style: GoogleFonts.outfit(color: const Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.bold))
                    )
                  ]
                ),
                Positioned(bottom: 0, right: 0, child: SizedBox(width: 40, height: 40, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress, strokeWidth: 4, backgroundColor: Colors.white.withOpacity(0.05), valueColor: const AlwaysStoppedAnimation(Colors.orange)), Icon(icon, color: Colors.white, size: 16)]))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));

  Widget _buildMainChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Weekly Progress', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)), const Icon(CupertinoIcons.graph_square, color: Colors.orange, size: 20)]),
          const SizedBox(height: 24),
          SizedBox(height: 150, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [_buildChartBar('Mon', 0.4), _buildChartBar('Tue', 0.7), _buildChartBar('Wed', 0.9), _buildChartBar('Thu', 0.5), _buildChartBar('Fri', 0.8), _buildChartBar('Sat', 0.6), _buildChartBar('Sun', 0.3)])),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double height) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 30, height: 100 * height, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.orange.withOpacity(0.8), Colors.orange.withOpacity(0.2)]), borderRadius: BorderRadius.circular(8))), const SizedBox(height: 8), Text(day, style: const TextStyle(color: Colors.white38, fontSize: 10))]);

  Widget _buildLogButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: [Colors.orange, Color(0xFFFF8C00)]), boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
      child: ElevatedButton(onPressed: _showCreateActivityModal, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: Text('New Activity', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }
}
