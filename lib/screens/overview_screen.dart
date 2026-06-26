import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:share_plus/share_plus.dart';

import '../state/collection_store.dart';
import '../widgets/box_tile.dart';
import 'box_input_screen.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key, required this.store});

  final CollectionStore store;

  static const _exportFileName = 'utility_collector_data.json';

  Future<void> _shareData(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = File('${Directory.systemTemp.path}/$_exportFileName');
      await file.writeAsString(store.exportJsonString());
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: _exportFileName),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Не удалось поделиться: $e')),
      );
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    final result = await FlutterPlatformAlert.showCustomAlert(
      windowTitle: 'Очистить все данные?',
      text:
          'Все собранные показания будут удалены. Это действие нельзя отменить.',
      iconStyle: IconStyle.warning,
      positiveButtonTitle: 'OK',
      negativeButtonTitle: 'Отмена',
    );
    if (result == CustomButton.positiveButton) {
      await store.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Квартиры'),
        leading: Center(
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final total = store.boxCount;
              final done = store.filledBoxCount;
              return Text(
                '$done / $total',
                style: Theme.of(context).textTheme.titleMedium,
              );
            },
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Поделиться',
            icon: const Icon(Icons.ios_share),
            onPressed: () => _shareData(context),
          ),
          IconButton(
            tooltip: 'Очистить',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: store.boxCount,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final boxNumber = index + 1;
              return BoxTile(
                boxNumber: boxNumber,
                data: store.boxAt(index),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          BoxInputScreen(store: store, initialIndex: index),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
