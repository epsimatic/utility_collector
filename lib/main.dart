import 'package:flutter/material.dart';

import 'screens/overview_screen.dart';
import 'state/collection_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await CollectionStore.load();
  runApp(UtilityCollectorApp(store: store));
}

class UtilityCollectorApp extends StatelessWidget {
  const UtilityCollectorApp({super.key, required this.store});

  final CollectionStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Сбор счётчиков',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: OverviewScreen(store: store),
    );
  }
}
