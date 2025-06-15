import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasksBox');

  List<Task> get tasks => _taskBox.values.toList();

  Future<void> fetchTasks() async {
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
    _scheduleNotifications(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
    _cancelNotifications(task.id);        // 🔴 Cancel notifikasi lama
    _scheduleNotifications(task);         // 🟢 Jadwalkan ulang notifikasi baru
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
    _cancelNotifications(id);             // 🔴 Hapus notifikasi yang terkait
    notifyListeners();
  }

  // Method untuk toggle status tugas - digunakan di TaskScreen
  void toggleTaskStatus(String id) {
    final task = _taskBox.get(id);
    if (task != null) {
      task.isDone = !task.isDone;
      task.save(); // penting agar perubahan disimpan
      
      // Update notifikasi berdasarkan status baru
      if (task.isDone) {
        _cancelNotifications(id); // Batalkan notifikasi jika tugas selesai
      } else {
        _scheduleNotifications(task); // Jadwalkan ulang jika tugas dibuka kembali
      }
      
      notifyListeners();
    }
  }

  // Alternative method yang kompatibel dengan TaskScreen
  void toggleTaskCompletion(String id) {
    toggleTaskStatus(id);
  }

  // Method untuk mendapatkan task berdasarkan ID
  Task? getTaskById(String id) {
    return _taskBox.get(id);
  }

  // Method untuk mendapatkan tasks berdasarkan status
  List<Task> getTasksByStatus(bool isDone) {
    return tasks.where((task) => task.isDone == isDone).toList();
  }

  // Method untuk mendapatkan tasks berdasarkan prioritas
  List<Task> getTasksByPriority(String priority) {
    return tasks.where((task) => task.priority == priority).toList();
  }

  // Method untuk mendapatkan statistik
  Map<String, int> getTaskStatistics() {
    final allTasks = tasks;
    return {
      'total': allTasks.length,
      'completed': allTasks.where((task) => task.isDone).length,
      'pending': allTasks.where((task) => !task.isDone).length,
      'high_priority': allTasks.where((task) => task.priority == 'High').length,
      'medium_priority': allTasks.where((task) => task.priority == 'Medium').length,
      'low_priority': allTasks.where((task) => task.priority == 'Low').length,
    };
  }

  void resetTasks() async {
    // Cancel semua notifikasi sebelum menghapus tasks
    for (final task in tasks) {
      _cancelNotifications(task.id);
    }
    
    await _taskBox.clear();
    notifyListeners();
  }

  String recommendPriority(String description, DateTime deadline) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;

    final desc = description.toLowerCase();
    final isImportant = desc.contains('ujian') ||
        desc.contains('presentasi') ||
        desc.contains('lomba') ||
        desc.contains('deadline') ||
        desc.contains('tugas akhir') ||
        desc.contains('penting') ||
        desc.contains('urgent');

    if (isImportant || daysLeft <= 1) {
      return 'High';
    } else if (daysLeft <= 3) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  void _scheduleNotifications(Task task) {
    // Jangan jadwalkan notifikasi untuk tugas yang sudah selesai
    if (task.isDone) return;
    
    final now = DateTime.now();

    final oneDayBefore = task.deadline.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      NotificationService.scheduleNotification(
        id: task.id.hashCode ^ 1,
        title: 'Reminder Tugas',
        body: 'Tugas "${task.title}" tinggal 1 hari lagi!',
        scheduledTime: oneDayBefore,
      );
    }

    final oneHourBefore = task.deadline.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      NotificationService.scheduleNotification(
        id: task.id.hashCode ^ 2,
        title: 'Reminder Tugas',
        body: 'Tugas "${task.title}" tinggal 1 jam lagi!',
        scheduledTime: oneHourBefore,
      );
    }

    if (task.deadline.isAfter(now)) {
      NotificationService.scheduleNotification(
        id: task.id.hashCode ^ 3,
        title: 'Deadline Tugas',
        body: 'Tugas "${task.title}" sudah mencapai batas waktu!',
        scheduledTime: task.deadline,
      );
    }
  }

  void _cancelNotifications(String id) {
    NotificationService.cancelNotification(id.hashCode ^ 1);
    NotificationService.cancelNotification(id.hashCode ^ 2);
    NotificationService.cancelNotification(id.hashCode ^ 3);
  }
}