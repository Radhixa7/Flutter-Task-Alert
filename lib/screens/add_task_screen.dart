import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _priority = 'Medium';

  void _submit() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harap pilih deadline terlebih dahulu')),
    );
    return;
  }

  final priority = _priority.isNotEmpty
      ? _priority
      : Provider.of<TaskProvider>(context, listen: false)
          .recommendPriority(_descriptionController.text, _selectedDate!);

  final newTask = Task(
    id: const Uuid().v4(),
    title: _titleController.text,
    description: _descriptionController.text,
    deadline: _selectedDate!,
    priority: priority,
    isDone: false,
  );

Provider.of<TaskProvider>(context, listen: false).addTask(newTask);

    // 🔔 Jadwalkan notifikasi
    await NotificationService.scheduleNotification(
      id: newTask.id.hashCode,
      title: 'Pengingat Tugas',
      body: 'Tugas "${newTask.title}" akan segera jatuh tempo!',
      scheduledTime: newTask.deadline.subtract(const Duration(hours: 1)),
    );

    // ✅ Kembali ke layar sebelumnya
    if (!mounted) return;
    Navigator.pop(context);
}

  Future<void> _pickDateTime() async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );

  if (!mounted || date == null) return;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (!mounted || time == null) return;

  setState(() {
    _selectedDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Tugas'),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Pilih Deadline'
                      : 'Deadline: ${DateFormat('dd MMM yyyy HH:mm').format(_selectedDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
              value: _priority,
              items: ['Low', 'Medium', 'High']
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Prioritas'),
            ),
            const SizedBox(height: 12), // Tambahkan spacing
            ElevatedButton.icon(
              onPressed: () {
                final recommended = Provider.of<TaskProvider>(context, listen: false)
                    .recommendPriority(_descriptionController.text, _selectedDate ?? DateTime.now());

                setState(() {
                  _priority = recommended;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Prioritas direkomendasikan: $recommended')),
                );
              },
              icon: const Icon(Icons.smart_toy),
              label: const Text('Gunakan AI Rekomendasi'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
              onPressed: _submit,
            ),
            ],
          ),
        ),
      ),
    );
  }
}
