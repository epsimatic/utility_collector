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

  static const _csvFileName = 'utility_collector_data.csv';
  static const _textFileName = 'utility_collector_data.txt';

  String _formatValue(double? v) => v == null ? '' : v.toStringAsFixed(2);

  String _buildCsv() {
    final buffer = StringBuffer('Квартира,T0,T1,T2');
    for (var i = 0; i < store.boxCount; i++) {
      final box = store.boxAt(i);
      final boxNumber = i + 1;
      if (box.isEmpty) continue;
      buffer
        ..write('\n$boxNumber,')
        ..write('${_formatValue(box.t0)},')
        ..write('${_formatValue(box.t1)},')
        ..write(_formatValue(box.t2));
    }
    return buffer.toString();
  }

  String _buildText() {
    final now = DateTime.now();
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final buffer = StringBuffer(dateStr);
    for (var i = 0; i < store.boxCount; i++) {
      final box = store.boxAt(i);
      final boxNumber = i + 1;
      final parts = <String>[];
      if (box.t0 != null) parts.add('счётчик T0: ${_formatValue(box.t0)}');
      if (box.t1 != null) parts.add('счётчик T1: ${_formatValue(box.t1)}');
      if (box.t2 != null) parts.add('счётчик T2: ${_formatValue(box.t2)}');
      if (parts.isEmpty) continue;
      buffer.write('\nКвартира $boxNumber, ${parts.join(', ')}');
    }
    return buffer.toString();
  }

  Future<void> _shareCSV(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = File('${Directory.systemTemp.path}/$_csvFileName');
      await file.writeAsString(_buildCsv());
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: _csvFileName),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Не удалось поделиться: $e')),
      );
    }
  }

  Future<void> _shareText(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = File('${Directory.systemTemp.path}/$_textFileName');
      await file.writeAsString(_buildText());
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: _textFileName),
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
        title: const Text('Сбор счётчиков'),
        centerTitle: true,
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
            tooltip: 'Очистить',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              spacing: 16.0,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    label: FittedBox(child: Text('Выгрузить Excel')),
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareCSV(context),
                  ),
                ),
                Expanded(
                  child: FilledButton.icon(
                    label: FittedBox(child: Text('Выгрузить текст')),
                    icon: const Icon(Icons.description_outlined),
                    onPressed: () => _shareText(context),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListenableBuilder(
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
                            builder: (_) => BoxInputScreen(
                              store: store,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
