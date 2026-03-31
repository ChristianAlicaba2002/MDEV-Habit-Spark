import 'package:flutter/material.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/services/habit_service.dart';
import 'package:habit_spark/constants/app_colors.dart';

class CreateEditHabitPage extends StatefulWidget {
  final Habit? habit; // null for create, non-null for edit
  final String userId;

  const CreateEditHabitPage({
    super.key,
    this.habit,
    required this.userId,
  });

  @override
  State<CreateEditHabitPage> createState() => _CreateEditHabitPageState();
}

class _CreateEditHabitPageState extends State<CreateEditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final HabitService _habitService = HabitService();
  bool _isLoading = false;
  
  // Icon selection
  IconData _selectedIcon = Icons.check_circle_outline;
  final List<IconData> _availableIcons = [
    Icons.directions_run,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.menu_book,
    Icons.water_drop,
    Icons.restaurant,
    Icons.bedtime,
    Icons.school,
    Icons.code,
    Icons.music_note,
    Icons.brush,
    Icons.camera_alt,
    Icons.favorite,
    Icons.wb_sunny,
    Icons.nightlight,
    Icons.local_cafe,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedIcon = _getIconFromString(widget.habit!.icon) ?? _getHabitIcon(widget.habit!.name);
    }
  }

  String _getIconString(IconData icon) {
    if (icon == Icons.directions_run) return 'directions_run';
    if (icon == Icons.fitness_center) return 'fitness_center';
    if (icon == Icons.self_improvement) return 'self_improvement';
    if (icon == Icons.menu_book) return 'menu_book';
    if (icon == Icons.water_drop) return 'water_drop';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.bedtime) return 'bedtime';
    if (icon == Icons.school) return 'school';
    if (icon == Icons.code) return 'code';
    if (icon == Icons.music_note) return 'music_note';
    if (icon == Icons.brush) return 'brush';
    if (icon == Icons.camera_alt) return 'camera_alt';
    if (icon == Icons.favorite) return 'favorite';
    if (icon == Icons.wb_sunny) return 'wb_sunny';
    if (icon == Icons.nightlight) return 'nightlight';
    if (icon == Icons.local_cafe) return 'local_cafe';
    return 'check_circle_outline';
  }

  IconData? _getIconFromString(String? iconString) {
    if (iconString == null) return null;
    switch (iconString) {
      case 'directions_run': return Icons.directions_run;
      case 'fitness_center': return Icons.fitness_center;
      case 'self_improvement': return Icons.self_improvement;
      case 'menu_book': return Icons.menu_book;
      case 'water_drop': return Icons.water_drop;
      case 'restaurant': return Icons.restaurant;
      case 'bedtime': return Icons.bedtime;
      case 'school': return Icons.school;
      case 'code': return Icons.code;
      case 'music_note': return Icons.music_note;
      case 'brush': return Icons.brush;
      case 'camera_alt': return Icons.camera_alt;
      case 'favorite': return Icons.favorite;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'nightlight': return Icons.nightlight;
      case 'local_cafe': return Icons.local_cafe;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  IconData _getHabitIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('run') || lowerName.contains('jog')) return Icons.directions_run;
    if (lowerName.contains('read')) return Icons.menu_book;
    if (lowerName.contains('water') || lowerName.contains('drink')) return Icons.water_drop;
    if (lowerName.contains('exercise') || lowerName.contains('workout')) return Icons.fitness_center;
    if (lowerName.contains('meditate') || lowerName.contains('yoga')) return Icons.self_improvement;
    if (lowerName.contains('sleep')) return Icons.bedtime;
    if (lowerName.contains('eat') || lowerName.contains('meal')) return Icons.restaurant;
    if (lowerName.contains('study') || lowerName.contains('learn')) return Icons.school;
    if (lowerName.contains('code') || lowerName.contains('program')) return Icons.code;
    return Icons.check_circle_outline;
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final iconString = _getIconString(_selectedIcon);
      
      if (widget.habit == null) {
        // Create new habit
        await _habitService.addHabit(
          widget.userId, 
          _nameController.text.trim(),
          icon: iconString,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habit created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing habit
        await _habitService.updateHabit(
          widget.habit!.id,
          _nameController.text.trim(),
          icon: iconString,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habit updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Habit',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this habit? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.habit != null) {
      try {
        await _habitService.deleteHabit(widget.habit!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habit deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting habit: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habit != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Habit' : 'Create Habit',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteHabit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit Name
              const Text(
                'Habit Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Morning Run, Read 30 minutes',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Icon Selection
              const Text(
                'Choose Icon',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableIcons.map((icon) {
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4ECDC4)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4ECDC4)
                                : Colors.white.withOpacity(0.1),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : Colors.white60,
                          size: 28,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEdit ? 'Update Habit' : 'Create Habit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
