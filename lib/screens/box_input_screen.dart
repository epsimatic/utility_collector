import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/box_data.dart';
import '../state/collection_store.dart';

class BoxInputScreen extends StatefulWidget {
  const BoxInputScreen({super.key, required this.store, this.initialIndex = 0});

  final CollectionStore store;
  final int initialIndex;

  @override
  State<BoxInputScreen> createState() => _BoxInputScreenState();
}

class _BoxInputScreenState extends State<BoxInputScreen> {
  late int _index;
  late final Map<BoxMetric, TextEditingController> _controllers;
  final Map<BoxMetric, FocusNode> _focusNodes = {
    for (final s in BoxMetric.values) s: FocusNode(),
  };

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.store.boxCount - 1);
    _controllers = {
      for (final slot in BoxMetric.values)
        slot: TextEditingController(
          text: _format(widget.store.boxAt(_index).valueFor(slot)),
        ),
    };
  }

  String _format(double? v) {
    if (v == null) return '';
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toString();
  }

  void _commitField(BoxMetric slot) {
    final text = _controllers[slot]!.text.trim();
    if (text.isEmpty) {
      widget.store.setMetric(_index, slot, null, clear: true);
      return;
    }
    final parsed = double.tryParse(text);
    if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
      return;
    }
    widget.store.setMetric(_index, slot, parsed, clear: false);
  }

  void _commitAll() {
    for (final slot in BoxMetric.values) {
      _commitField(slot);
    }
  }

  void _goto(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.store.boxCount) return;
    if (newIndex == _index) return;
    _commitAll();
    setState(() {
      _index = newIndex;
      for (final slot in BoxMetric.values) {
        _controllers[slot]!.text = _format(
          widget.store.boxAt(_index).valueFor(slot),
        );
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPrev = _index > 0;
    final canNext = _index < widget.store.boxCount - 1;
    final boxNumber = _index + 1;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
              Text("Электричество", style: theme.textTheme.headlineSmall),
              Card(
                color: theme.colorScheme.surfaceDim,
                clipBehavior: Clip.hardEdge,
                child: Column(
                  spacing: 8.0,
                  children: [
                    if (keyboardOpen) SizedBox.shrink(),
                    if (!keyboardOpen)
                      Image.asset("assets/electricity_meter.jpeg"),
                    for (final slot in BoxMetric.values)
                      _MetricField(
                        label: "Расход ${slot.name.toUpperCase()}",
                        controller: _controllers[slot]!,
                        focusNode: _focusNodes[slot]!,
                        onCommit: () => _commitField(slot),
                      ),
                    SizedBox(height: 0.0),
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
