import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title,
          style: TextStyle(
              decoration: task.isDone ? TextDecoration.lineThrough : null)),
      subtitle: Text(task.description),
      trailing: Icon(
        task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: task.isDone ? Colors.green : null,
      ),
    );
  }
}
