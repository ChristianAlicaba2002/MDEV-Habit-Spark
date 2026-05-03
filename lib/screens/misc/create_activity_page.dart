import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/health_service.dart';

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final HealthService _healthService = HealthService();

  String _selectedType = 'Steps';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<Map<String, dynamic>> _activityTypes = [
    {'name': 'Steps', 'unit': 'steps', 'icon': Icons.directions_walk, 'color': Colors.tealAccent},
    {'name': 'Calories', 'unit': 'kcal', 'icon': CupertinoIcons.flame, 'color': Colors.orangeAccent},
    {'name': 'Distance', 'unit': 'km', 'icon': CupertinoIcons.map, 'color': Colors.blueAccent},
    {'name': 'Sleep', 'unit': 'hrs', 'icon': CupertinoIcons.moon, 'color': Colors.purpleAccent},
  ];

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final activity = _activityTypes.firstWhere((element) => element['name'] == _selectedType);
      
      await _healthService.logActivity(
        type: _selectedType,
        value: double.parse(_valueController.text),
        unit: activity['unit'],
        timestamp: _selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity logged successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _activityTypes.firstWhere((e) => e['name'] == _selectedType)['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Create Activity', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Activity Type', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 16),
              _buildTypeSelector(activeColor),
              const SizedBox(height: 32),
              Text('Value', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 16),
              _buildValueInput(activeColor),
              const SizedBox(height: 32),
              Text('Date', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 16),
              _buildDatePicker(activeColor),
              const SizedBox(height: 48),
              _buildSaveButton(activeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(Color activeColor) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _activityTypes.length,
        itemBuilder: (context, index) {
          final type = _activityTypes[index];
          final isSelected = _selectedType == type['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type['name']),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? type['color'].withOpacity(0.15) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? type['color'] : Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(type['icon'], color: isSelected ? type['color'] : Colors.white38),
                  const SizedBox(height: 8),
                  Text(type['name'], style: GoogleFonts.outfit(color: isSelected ? Colors.white : Colors.white38, fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildValueInput(Color activeColor) {
    return TextFormField(
      controller: _valueController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        suffixText: _activityTypes.firstWhere((e) => e['name'] == _selectedType)['unit'],
        suffixStyle: GoogleFonts.outfit(color: activeColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: activeColor)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Please enter a value' : null,
    );
  }

  Widget _buildDatePicker(Color activeColor) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(primary: activeColor, onPrimary: Colors.black, surface: const Color(0xFF1E1E1E)),
            ),
            child: child!,
          ),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.calendar, color: activeColor),
            const SizedBox(width: 16),
            Text(DateFormat('MMMM dd, yyyy').format(_selectedDate), style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
            const Spacer(),
            const Icon(CupertinoIcons.right_chevron, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(Color activeColor) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveActivity,
        style: ElevatedButton.styleFrom(
          backgroundColor: activeColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 8,
          shadowColor: activeColor.withOpacity(0.4),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.black)
            : Text('SAVE ACTIVITY', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }
}
