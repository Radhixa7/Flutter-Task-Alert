import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../models/theme_mode_enum.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Tampilan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<AppThemeMode>(
              title: const Text('Ikuti Sistem'),
              value: AppThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Terang'),
              value: AppThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Gelap'),
              value: AppThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
            ),
            const SizedBox(height: 32),
            const Text(
              'Umum',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset Semua Tugas'),
              subtitle: const Text('Hapus semua tugas dari sistem.'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi Reset'),
                    content: const Text('Apakah kamu yakin ingin menghapus semua tugas?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          taskProvider.resetTasks();
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Semua tugas telah dihapus.')),
                          );
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              "language".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButton<Locale>(
              value: context.locale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  context.setLocale(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('id'),
                  child: Text('Bahasa Indonesia'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
