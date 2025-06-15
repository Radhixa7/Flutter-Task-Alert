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
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Init EasyLocalization
    await EasyLocalization.ensureInitialized();

    // Init Hive first
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>('tasksBox');

    // Init Notification Service
    await NotificationService.init();
    debugPrint('[Main] NotificationService initialized successfully');

    // Request permissions explicitly
    await _requestAllPermissions();

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('id')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('[Main] Error during initialization: $e');
    // Still run the app even if some services fail
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('id')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    );
  }
}

Future<void> _requestAllPermissions() async {
  try {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    debugPrint('[Main] Notification permission: $notificationStatus');

    // Request exact alarm permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      debugPrint('[Main] Exact alarm permission: $alarmStatus');
    }

    // Request storage permission if needed
    final storageStatus = await Permission.storage.request();
    debugPrint('[Main] Storage permission: $storageStatus');

  } catch (e) {
    debugPrint('[Main] Error requesting permissions: $e');
  }
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
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: themeProvider.themeModeFlutter,
            home: const MainScreen(),
            routes: {
              '/add-task': (context) => const AddTaskScreen(),
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