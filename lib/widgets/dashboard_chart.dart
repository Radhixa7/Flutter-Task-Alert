import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardChart extends StatefulWidget {
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
  State<DashboardChart> createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.completed + widget.pending + widget.highPriority;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (total == 0) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.grey[50]!, Colors.grey[100]!],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                "Belum ada data untuk ditampilkan",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color.fromARGB(255, 33, 33, 33), const Color.fromARGB(255, 66, 66, 66)]
                  : [Colors.white, const Color.fromARGB(255, 250, 250, 250)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Status Tugas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 6,
                      centerSpaceRadius: 50,
                      sections: _generateSections(total),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatsCards(total, isDark),
                const SizedBox(height: 16),
                _buildLegend(isDark),
                ],
              ),
            ),
          ),
        );
      }, // <--- TUTUP builder
    );
  }

  List<PieChartSectionData> _generateSections(int total) {
    final sections = <PieChartSectionData>[];
    final data = [
      {'value': widget.completed, 'color': const Color(0xFF4CAF50), 'label': 'Selesai'},
      {'value': widget.pending, 'color': const Color(0xFFE53E3E), 'label': 'Belum Selesai'},
      {'value': widget.highPriority, 'color': const Color(0xFFFF9800), 'label': 'Prioritas Tinggi'},
    ];

    for (int i = 0; i < data.length; i++) {
      final value = data[i]['value'] as int;
      final color = data[i]['color'] as Color;
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      if (value > 0) {
        sections.add(
          PieChartSectionData(
            color: color,
            value: (value * _animation.value).toDouble(),
            title: '${((value / total) * 100).toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
            ),
          ),
        );
      }
    }

    return sections;
  }

  Widget _buildStatsCards(int total, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Tugas',
            total.toString(),
            Icons.assignment_outlined,
            const Color(0xFF667eea),
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Selesai',
            '${((widget.completed / total) * 100).toStringAsFixed(0)}%',
            Icons.check_circle_outline,
            const Color(0xFF4CAF50),
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Tertunda',
            '${((widget.pending / total) * 100).toStringAsFixed(0)}%',
            Icons.pending_outlined,
            const Color(0xFFE53E3E),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(255, 66, 66, 66) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color.fromARGB(255, 158, 158, 158) : const Color.fromARGB(255, 117, 117, 117),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    final legendItems = [
      {'color': const Color(0xFF4CAF50), 'label': 'Selesai', 'value': widget.completed},
      {'color': const Color(0xFFE53E3E), 'label': 'Belum Selesai', 'value': widget.pending},
      {'color': const Color(0xFFFF9800), 'label': 'Prioritas Tinggi', 'value': widget.highPriority},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(255, 38, 38, 38) : const Color.fromARGB(255, 250, 250, 250),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color.fromARGB(255, 66, 66, 66) : const Color.fromARGB(255, 224, 224, 224),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color.fromARGB(255, 189, 189, 189) : const Color.fromARGB(255, 97, 97, 97),
            ),
          ),
          const SizedBox(height: 8),
          ...legendItems.map((item) {
            final color = item['color'] as Color;
            final label = item['label'] as String;
            final value = item['value'] as int;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color.fromARGB(255, 189, 189, 189) : const Color.fromARGB(255, 97, 97, 97),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}