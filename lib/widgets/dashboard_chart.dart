import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChart extends StatelessWidget {
  final int completed;
  final int pending;
  final int highPriority;

  const DashboardChart({
    super.key,
    required this.completed,
    required this.pending,
    required this.highPriority,
  });

  @override
  Widget build(BuildContext context) {
    final total = completed + pending + highPriority;

    if (total == 0) {
      return const Center(
        child: Text("Belum ada data untuk ditampilkan."),
      );
    }

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Status Tugas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: completed.toDouble(),
                        color: Colors.green,
                        title: '${((completed / total) * 100).toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: pending.toDouble(),
                        color: Colors.red,
                        title: '${((pending / total) * 100).toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: highPriority.toDouble(),
                        color: Colors.orange,
                        title: '${((highPriority / total) * 100).toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  _legend(Colors.green, "Selesai"),
                  _legend(Colors.red, "Belum Selesai"),
                  _legend(Colors.orange, "Prioritas Tinggi"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
