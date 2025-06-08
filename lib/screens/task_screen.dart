import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final allTasks = taskProvider.tasks;

    final filteredTasks = allTasks.where((task) {
      switch (_selectedFilter) {
        case 'Selesai':
          return task.isDone;
        case 'Belum Selesai':
          return !task.isDone;
        case 'Prioritas Tinggi':
          return task.priority == 'High';
        case 'Prioritas Sedang':
          return task.priority == 'Medium';
        case 'Prioritas Rendah':
          return task.priority == 'Low';
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Filter Tugas',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                DropdownMenuItem(value: 'Belum Selesai', child: Text('Belum Selesai')),
                DropdownMenuItem(value: 'Prioritas Tinggi', child: Text('Prioritas Tinggi')),
                DropdownMenuItem(value: 'Prioritas Sedang', child: Text('Prioritas Sedang')),
                DropdownMenuItem(value: 'Prioritas Rendah', child: Text('Prioritas Rendah')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text('Tidak ada tugas yang cocok.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskTile(
                        task: task,
                        onTapEdit: () {
                          Navigator.pushNamed(
                            context,
                            '/editTask',
                            arguments: task,
                          );
                        },
                        onTapDelete: () {
                          showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Tugas'),
                              content: const Text('Apakah kamu yakin ingin menghapus tugas ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          ).then((confirm) {
                            if (confirm == true && mounted) {
                              context.read<TaskProvider>().deleteTask(task.id);
                            }
                          });
                        }
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
