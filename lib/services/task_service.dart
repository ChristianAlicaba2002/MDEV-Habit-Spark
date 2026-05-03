import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_spark/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of tasks for a specific user
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList();
      // Sort in memory to avoid needing a composite index
      tasks.sort((a, b) => a.order.compareTo(b.order));
      return tasks;
    });
  }

  // Add a new task (defaults to Other tasks)
  Future<void> addTask(String userId, String title, {String routine = 'none'}) async {
    final tasks = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();
    
    int nextOrder = tasks.docs.length;

    await _firestore.collection('tasks').add({
      'title': title,
      'isCompleted': false,
      'isRecent': false,
      'routine': routine,
      'order': nextOrder,
      'userId': userId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Update task routine
  Future<void> updateTaskRoutine(String taskId, String routine) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'routine': routine,
    });
  }

  // Toggle completion
  Future<void> toggleTask(String taskId, bool currentStatus) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  // Update task status (Recent/Other)
  Future<void> updateTaskStatus(String taskId, bool isRecent) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isRecent': isRecent,
    });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // Reorder tasks
  Future<void> reorderTasks(List<TaskModel> tasks) async {
    final batch = _firestore.batch();
    for (int i = 0; i < tasks.length; i++) {
      final docRef = _firestore.collection('tasks').doc(tasks[i].id);
      batch.update(docRef, {'order': i, 'isRecent': tasks[i].isRecent});
    }
    await batch.commit();
  }
}
