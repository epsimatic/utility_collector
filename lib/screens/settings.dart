import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import '../locator.dart';
import '../state/app_settings.dart';
import '../state/collection_store.dart';

class Settings extends WatchingStatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final TextEditingController _boxCountController;

  @override
  void initState() {
    super.initState();
    _boxCountController = TextEditingController(
      text: getIt<AppSettings>().boxCount.toString(),
    );
  }

  @override
  void dispose() {
    _boxCountController.dispose();
    super.dispose();
  }

  void _commitBoxCount() {
    final text = _boxCountController.text.trim();
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) {
      _boxCountController.text = getIt<AppSettings>().boxCount.toString();
      return;
    }
    final settings = getIt<AppSettings>();
    if (parsed == settings.boxCount) return;
    settings.boxCount = parsed;
    getIt<CollectionStore>().resizeBoxes(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();
    final metricsStartWith1 = watchPropertyValue(
      (AppSettings s) => s.metricsStartWith1,
    );
    final metricCount = watchPropertyValue((AppSettings s) => s.metricCount);

    return AlertDialog(
      title: const Text("Настройки"),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4.0),
          ListTile(
            leading: const Icon(Icons.apartment),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: const Text('Количество квартир'),
            trailing: SizedBox(
              width: 80,
              child: TextField(
                controller: _boxCountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => _commitBoxCount(),
                onEditingComplete: _commitBoxCount,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ),
          const Divider(height: 1.0),
          ListTile(
            leading: const Icon(Icons.format_list_numbered),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: const Text('Количество тарифов'),
            trailing: RadioGroup<int>(
              groupValue: metricCount,
              onChanged: (value) {
                if (value != null) {
                  settings.metricCount = value;
                  getIt<CollectionStore>().updateMetricCount(value);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 1; i <= 3; i++) ...[
                    Radio<int>(value: i),
                    Text(i.toString()),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1.0),
          ListTile(
            leading: const Icon(Icons.filter_1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: const Text('Тарифы начинаются с'),
            trailing: RadioGroup<bool>(
              groupValue: metricsStartWith1,
              onChanged: (value) {
                if (value != null) {
                  settings.metricsStartWith1 = value;
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<bool>(value: false),
                  const Text('T0'),
                  const SizedBox(width: 8),
                  Radio<bool>(value: true),
                  const Text('T1'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
