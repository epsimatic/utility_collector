import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watch_it/watch_it.dart';

import '../locator.dart';
import '../state/app_settings.dart';
import '../state/collection_store.dart';
import '../widgets/box_tile.dart';
import 'box_input_screen.dart';
import 'settings.dart' show Settings;

class OverviewScreen extends WatchingWidget {
  const OverviewScreen({super.key});

  static const _csvFileName = 'utility_collector_data.csv';
  static const _textFileName = 'utility_collector_data.txt';

  String _formatValue(double? v) => v == null ? '' : v.toStringAsFixed(2);

  String _buildCsv() {
    final store = getIt<CollectionStore>();
    final settings = getIt<AppSettings>();
    final metricCount = settings.metricCount;
    final metricLabel = settings.metricLabel;
    final buffer = StringBuffer('Квартира');
    for (var m = 0; m < metricCount; m++) {
      buffer.write(',${metricLabel(m)}');
    }
    for (var i = 0; i < store.boxCount; i++) {
      final box = store.boxAt(i);
      final boxNumber = i + 1;
      if (box.isEmpty) continue;
      buffer.write('\n$boxNumber,');
      for (var m = 0; m < box.metricCount; m++) {
        if (m > 0) buffer.write(',');
        buffer.write(_formatValue(box.valueAt(m)));
      }
    }
    return buffer.toString();
  }

  String _buildText() {
    final store = getIt<CollectionStore>();
    final metricLabel = getIt<AppSettings>().metricLabel;
    final now = DateTime.now();
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final buffer = StringBuffer(dateStr);
    for (var i = 0; i < store.boxCount; i++) {
      final box = store.boxAt(i);
      final boxNumber = i + 1;
      final parts = <String>[];
      for (var m = 0; m < box.metricCount; m++) {
        final v = box.valueAt(m);
        if (v != null) {
          parts.add('счётчик ${metricLabel(m)}: ${_formatValue(v)}');
        }
      }
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
      await getIt<CollectionStore>().clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = getIt<CollectionStore>();
    final boxCount = watchPropertyValue((AppSettings s) => s.boxCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сбор счётчиков'),
        centerTitle: true,
        leading: Center(
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final total = boxCount;
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
            tooltip: 'Настройки',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const Settings(),
              );
            },
          ),
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
                  itemCount: boxCount,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final boxNumber = index + 1;
                    return BoxTile(
                      boxNumber: boxNumber,
                      data: store.boxAt(index),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BoxInputScreen(initialIndex: index),
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
