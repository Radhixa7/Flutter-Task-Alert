import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // Untuk emulator Android. Ganti dengan IP jika pakai device

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data tugas');
    }
  }

  Future<void> addTask(Task task) async {
  await http.post(
    Uri.parse('$baseUrl/tasks'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(task.toJson()),
  );

  // Set notifikasi
  await NotificationService.scheduleNotification(
    id: task.id.hashCode, // Gunakan hash dari ID string sebagai int
    title: 'Tugas Baru: ${task.title}',
    body: task.description ?? '',
    scheduledTime: task.deadline, // Pastikan task.deadline adalah DateTime yang valid
  );
}

  Future<void> updateTask(Task task) async {
    await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
  }

  Future<void> deleteTask(String id) async {
    await http.delete(Uri.parse('$baseUrl/tasks/$id'));
  }
}
