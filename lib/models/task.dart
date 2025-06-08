import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String priority;

  @HiveField(4)
  DateTime deadline;

  @HiveField(5)
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.deadline,
    this.isDone = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      deadline: DateTime.parse(json['deadline']),
      isDone: json['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'deadline': deadline.toIso8601String(),
      'isDone': isDone,
    };
  }
}
