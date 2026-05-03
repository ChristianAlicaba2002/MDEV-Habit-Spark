import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_spark/models/task_model.dart';
import 'package:habit_spark/services/task_service.dart';
import 'package:shimmer/shimmer.dart';

class TasksListPage extends StatefulWidget {
  final String title;
  final String userId;

  const TasksListPage({super.key, required this.title, required this.userId});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  final TaskService _taskService = TaskService();
  String _selectedRoutine = 'none';

  void _showTaskModal({TaskModel? existingTask}) {
    final TextEditingController controller = TextEditingController(
      text: existingTask?.title ?? '',
    );
    _selectedRoutine = existingTask?.routine ?? 'none';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Color(0xFF1D3D3D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      existingTask == null ? 'New Task' : 'Edit Task',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    if (existingTask != null)
                      IconButton(
                        onPressed: () async {
                          await _taskService.deleteTask(existingTask.id);
                          Navigator.pop(context);
                        },
                        icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Task title...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Select Routine', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRoutineChip('morning', CupertinoIcons.sunrise, 'Morning', setModalState),
                    _buildRoutineChip('afternoon', CupertinoIcons.sun_max, 'Afternoon', setModalState),
                    _buildRoutineChip('evening', CupertinoIcons.moon_stars, 'Evening', setModalState),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        if (existingTask == null) {
                          await _taskService.addTask(widget.userId, controller.text, routine: _selectedRoutine);
                        } else {
                          await _taskService.updateTaskTitleAndRoutine(existingTask.id, controller.text, _selectedRoutine);
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: Text(existingTask == null ? 'Add Task' : 'Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickMoveMenu(TaskModel task) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1D3D3D).withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Move Task',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  task.title,
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildQuickMoveOption(
                      'Recent (Top)',
                      CupertinoIcons.star_fill,
                      const [Color(0xFFFFD700), Color(0xFFFFA500)],
                      () => _handleQuickMove(task.id, isRecent: true),
                    ),
                    _buildQuickMoveOption(
                      'Morning',
                      CupertinoIcons.sunrise_fill,
                      const [Color(0xFFFF9A8B), Color(0xFFFF6A88)],
                      () => _handleQuickMove(task.id, routine: 'morning'),
                    ),
                    _buildQuickMoveOption(
                      'Afternoon',
                      CupertinoIcons.sun_max_fill,
                      const [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
                      () => _handleQuickMove(task.id, routine: 'afternoon'),
                    ),
                    _buildQuickMoveOption(
                      'Evening',
                      CupertinoIcons.moon_stars_fill,
                      const [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
                      () => _handleQuickMove(task.id, routine: 'evening'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleQuickMove(String taskId, {bool isRecent = false, String? routine}) async {
    HapticFeedback.lightImpact();
    if (isRecent) {
      await _taskService.updateTaskStatus(taskId, true);
    } else if (routine != null) {
      await _taskService.updateTaskStatus(taskId, false);
      await _taskService.updateTaskRoutine(taskId, routine);
    }
    Navigator.pop(context);
  }

  Widget _buildQuickMoveOption(String label, IconData icon, List<Color> gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: gradient).createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineChip(String value, IconData icon, String label, StateSetter setModalState) {
    bool isSelected = _selectedRoutine == value;
    return GestureDetector(
      onTap: () => setModalState(() => _selectedRoutine = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.white70),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(CupertinoIcons.back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(widget.title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2C3E3E), Color(0xFF4A6666)]),
        ),
        child: StreamBuilder<List<TaskModel>>(
          stream: _taskService.getTasksStream(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
            if (snapshot.connectionState == ConnectionState.waiting) return _buildSkeletonLoader();
            
            final allTasks = snapshot.data ?? [];
            final recentTasks = allTasks.where((t) => t.isRecent).toList();
            final morningTasks = allTasks.where((t) => !t.isRecent && t.routine == 'morning').toList();
            final afternoonTasks = allTasks.where((t) => !t.isRecent && t.routine == 'afternoon').toList();
            final eveningTasks = allTasks.where((t) => !t.isRecent && t.routine == 'evening').toList();
            final otherTasks = allTasks.where((t) => !t.isRecent && t.routine == 'none').toList();

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 10),
                        _buildDropZone('Recent Tasks (Max 3)', recentTasks, true, recentTasks.length >= 3),
                        const SizedBox(height: 24),
                        _buildRoutineSection('Morning Routine', morningTasks, CupertinoIcons.sunrise, 'morning'),
                        _buildRoutineSection('Afternoon Routine', afternoonTasks, CupertinoIcons.sun_max, 'afternoon'),
                        _buildRoutineSection('Evening Routine', eveningTasks, CupertinoIcons.moon_stars, 'evening'),
                        if (otherTasks.isNotEmpty) _buildDropZone('Other Tasks', otherTasks, false, false),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  _buildAddButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoutineSection(String title, List<TaskModel> tasks, IconData icon, String routineValue) {
    return DragTarget<TaskModel>(
      onWillAccept: (data) => data != null && (data.routine != routineValue || data.isRecent),
      onAccept: (task) async {
        await _taskService.updateTaskStatus(task.id, false);
        await _taskService.updateTaskRoutine(task.id, routineValue);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: isHovered ? Colors.white : Colors.white70),
                  const SizedBox(width: 8),
                  Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isHovered && tasks.isEmpty ? 20 : 0),
              decoration: BoxDecoration(
                color: isHovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isHovered ? Colors.white.withOpacity(0.3) : Colors.transparent),
              ),
              child: Column(
                children: [
                  if (isHovered && tasks.isEmpty)
                    Text('Drop here', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                  ...tasks.map((t) => _buildDraggableTask(t)).toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropZone(String title, List<TaskModel> tasks, bool isRecentZone, bool isFull) {
    return DragTarget<TaskModel>(
      onWillAccept: (data) => data != null && data.isRecent != isRecentZone && (!isRecentZone || !isFull),
      onAccept: (task) async {
        await _taskService.updateTaskStatus(task.id, isRecentZone);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tasks.isNotEmpty || isRecentZone) 
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(title, style: GoogleFonts.outfit(color: isHovered ? Colors.white : Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isHovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isHovered ? Colors.white.withOpacity(0.3) : Colors.transparent, width: 2),
              ),
              child: tasks.isEmpty && isRecentZone
                ? _buildEmptyPlaceholder(isRecentZone)
                : Column(children: tasks.map((t) => _buildDraggableTask(t)).toList()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDraggableTask(TaskModel task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _taskService.deleteTask(task.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
        child: const Icon(CupertinoIcons.trash, color: Colors.white),
      ),
      child: Draggable<TaskModel>(
        data: task,
        axis: Axis.vertical,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width - 64,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]),
            child: Text(task.title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15)),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: _buildTaskCard(task)),
        child: _buildTaskCard(task),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: task.isCompleted ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showTaskModal(existingTask: task),
                onDoubleTap: () => _showQuickMoveMenu(task),
                child: Text(task.title, style: GoogleFonts.outfit(color: task.isCompleted ? Colors.white.withOpacity(0.5) : Colors.white, fontSize: 15, decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
              ),
            ),
            GestureDetector(
              onTap: () => _taskService.toggleTask(task.id, task.isCompleted),
              child: Icon(task.isCompleted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle, color: task.isCompleted ? Colors.green : Colors.white.withOpacity(0.5), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(bool isRecent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Center(child: Text(isRecent ? 'Drag tasks here' : 'No tasks', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13))),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: () => _showTaskModal(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        child: const Text('Add New Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
        ),
      ),
    );
  }
}
