import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  void _showAddTaskModal() {
    final TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Color(0xFF1D3D3D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('New Task', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      await _taskService.addTask(widget.userId, controller.text);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
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
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonLoader();
            }
            
            final allTasks = snapshot.data ?? [];
            final recentTasks = allTasks.where((t) => t.isRecent).toList();
            final otherTasks = allTasks.where((t) => !t.isRecent).toList();

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildDropZone('Recent Tasks (Max 3)', recentTasks, true, recentTasks.length >= 3),
                        const SizedBox(height: 32),
                        _buildDropZone('Other Tasks', otherTasks, false, false),
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

  Widget _buildDropZone(String title, List<TaskModel> tasks, bool isRecentZone, bool isFull) {
    return DragTarget<TaskModel>(
      onWillAccept: (data) => data != null && data.isRecent != isRecentZone && (!isRecentZone || !isFull),
      onAccept: (task) async {
        await _taskService.updateTaskStatus(task.id, isRecentZone);
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty ? Colors.white.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: candidateData.isNotEmpty ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
              ),
              child: tasks.isEmpty 
                ? _buildEmptyPlaceholder(isRecentZone)
                : Column(children: tasks.map((t) => _buildDraggableTask(t)).toList()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDraggableTask(TaskModel task) {
    return LongPressDraggable<TaskModel>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width - 48,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
          child: Text(task.title, style: GoogleFonts.outfit(color: Colors.white)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildTaskCard(task)),
      child: _buildTaskCard(task),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: task.isCompleted ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(task.title, style: GoogleFonts.outfit(color: task.isCompleted ? Colors.white.withOpacity(0.5) : Colors.white, decoration: task.isCompleted ? TextDecoration.lineThrough : null))),
            GestureDetector(
              onTap: () => _taskService.toggleTask(task.id, task.isCompleted),
              child: Icon(task.isCompleted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle, color: task.isCompleted ? Colors.green : Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(bool isRecent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.none)),
      child: Center(child: Text(isRecent ? 'Drag tasks here' : 'No other tasks', style: TextStyle(color: Colors.white.withOpacity(0.3)))),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _showAddTaskModal,
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
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }
}
