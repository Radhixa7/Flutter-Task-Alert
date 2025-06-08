import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/task_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/edit_task_screen.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

// Tambahkan import untuk Hive
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await EasyLocalization.ensureInitialized();

  // Inisialisasi Hive
  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  // Registrasi adapter
  Hive.registerAdapter(TaskAdapter());

  // Buka Box untuk task
  await Hive.openBox<Task>('tasksBox');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('id')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Task Alert',
            theme: ThemeData(
              fontFamily: GoogleFonts.inter().fontFamily,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.themeModeFlutter,
            home: const MainScreen(),
            routes: {
              '/add': (context) => const AddTaskScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/tasks': (context) => const TaskScreen(),
              '/editTask': (context) => const EditTaskScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
