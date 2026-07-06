import 'package:flutter/material.dart';

import 'locator.dart';
import 'screens/overview_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const UtilityCollectorApp());
}

class UtilityCollectorApp extends StatelessWidget {
  const UtilityCollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Сбор счётчиков',
      debugShowCheckedModeBanner: false,
      // locale: const Locale('ru', 'RU'),
      // supportedLocales: const [Locale('en', 'US'), Locale('ru', 'RU')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const OverviewScreen(),
    );
  }
}
