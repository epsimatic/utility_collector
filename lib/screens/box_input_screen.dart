import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';

import '../locator.dart';
import '../state/app_settings.dart';
import '../state/collection_store.dart';

class BoxInputScreen extends WatchingStatefulWidget {
  const BoxInputScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<BoxInputScreen> createState() => _BoxInputScreenState();
}

class _BoxInputScreenState extends State<BoxInputScreen> {
  late int _index;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    final store = getIt<CollectionStore>();
    final metricCount = getIt<AppSettings>().metricCount;
    _index = widget.initialIndex.clamp(0, store.boxCount - 1);
    _controllers = List.generate(
      metricCount,
      (i) =>
          TextEditingController(text: _format(store.boxAt(_index).valueAt(i))),
    );
    _focusNodes = List.generate(metricCount, (_) => FocusNode());
  }

  String _format(double? v) {
    if (v == null) return '';
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toString();
  }

  void _commitField(int slot) {
    final store = getIt<CollectionStore>();
    final text = _controllers[slot].text.trim();
    if (text.isEmpty) {
      store.setMetric(_index, slot, null, clear: true);
      return;
    }
    final parsed = double.tryParse(text);
    if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
      return;
    }
    store.setMetric(_index, slot, parsed, clear: false);
  }

  void _commitAll() {
    final metricCount = getIt<AppSettings>().metricCount;
    for (var slot = 0; slot < metricCount; slot++) {
      _commitField(slot);
    }
  }

  void _goto(int newIndex) {
    final store = getIt<CollectionStore>();
    final metricCount = getIt<AppSettings>().metricCount;
    if (newIndex < 0 || newIndex >= store.boxCount) return;
    if (newIndex == _index) return;
    _commitAll();
    setState(() {
      _index = newIndex;
      for (var slot = 0; slot < metricCount; slot++) {
        _controllers[slot].text = _format(store.boxAt(_index).valueAt(slot));
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = getIt<CollectionStore>();
    final metricCount = watchPropertyValue((AppSettings s) => s.metricCount);
    final metricLabel = getIt<AppSettings>().metricLabel;
    final theme = Theme.of(context);
    final canPrev = _index > 0;
    final canNext = _index < store.boxCount - 1;
    final boxNumber = _index + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Квартира')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: IconButton.filled(
                      iconSize: 32,
                      onPressed: canPrev ? () => _goto(_index - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$boxNumber',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton.filled(
                      iconSize: 32,
                      onPressed: canNext ? () => _goto(_index + 1) : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Счётчики", style: theme.textTheme.headlineSmall),
              Card(
                color: theme.colorScheme.surfaceDim,
                child: Column(
                  spacing: 8.0,
                  children: [
                    const SizedBox.shrink(),
                    for (var slot = 0; slot < metricCount; slot++)
                      _MetricField(
                        label: 'Расход ${metricLabel(slot)}',
                        controller: _controllers[slot],
                        focusNode: _focusNodes[slot],
                        onCommit: () => _commitField(slot),
                      ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  const _MetricField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onCommit,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        onChanged: (_) => onCommit(),
        onSubmitted: (_) {
          onCommit();
          FocusScope.of(context).nextFocus();
        },
        onEditingComplete: onCommit,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
