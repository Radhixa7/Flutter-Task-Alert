import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/dashboard_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    final total = tasks.length;
    final completed = tasks.where((t) => t.isDone).length;
    final pending = tasks.where((t) => !t.isDone).length;
    final highPriority = tasks.where((t) => t.priority == 'High').length;
    final nearingDeadline = tasks
        .where((t) =>
            t.deadline.difference(DateTime.now()).inDays <= 2 && !t.isDone)
        .length;

    return Scaffold(
      appBar: AppBar(
  title: const Text('Dashboard'),
  actions: [
    IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        Navigator.pushNamed(context, '/settings'); // pastikan route '/settings' sudah dibuat
      },
    ),
  ],
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSummaryCard(title: 'Total Tugas', value: total),
            DashboardSummaryCard(title: 'Selesai', value: completed),
            DashboardSummaryCard(title: 'Belum Selesai', value: pending),
            DashboardSummaryCard(title: 'Prioritas Tinggi', value: highPriority),
            DashboardSummaryCard(title: 'Dekat Deadline', value: nearingDeadline),
            const SizedBox(height: 20),
            Text(
              "Distribusi Tugas",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: DashboardChart(
                completed: completed,
                pending: pending,
                highPriority: highPriority,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
