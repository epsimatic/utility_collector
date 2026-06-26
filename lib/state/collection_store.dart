import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/box_data.dart';

class CollectionStore extends ChangeNotifier {
  CollectionStore._(this._prefs, this._boxes);

  static const _storageKey = 'boxes.v1';

  final SharedPreferences _prefs;
  final List<BoxData> _boxes;

  static Future<CollectionStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final List<BoxData> boxes = List.generate(
      kBoxCount,
      (_) => const BoxData(),
    );
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (var i = 0; i < decoded.length && i < kBoxCount; i++) {
            final entry = decoded[i];
            if (entry is Map) {
              boxes[i] = BoxData.fromJson(entry.cast<String, dynamic>());
            }
          }
        }
      } catch (e) {
        debugPrint(
          'CollectionStore: failed to decode stored data, starting fresh: $e',
        );
      }
    }
    return CollectionStore._(prefs, boxes);
  }

  int get boxCount => kBoxCount;

  BoxData boxAt(int index) => _boxes[index];

  bool isFilled(int index, BoxMetric slot) {
    return _boxes[index].valueFor(slot) != null;
  }

  int get filledBoxCount => _boxes.where((b) => b.isComplete).length;

  Future<void> setMetric(
    int index,
    BoxMetric slot,
    double? value, {
    required bool clear,
  }) async {
    assert(index >= 0 && index < _boxes.length);
    final current = _boxes[index];
    final next = current.copyWithMetric(slot, value, clear: clear);
    if (next == current) return;
    _boxes[index] = next;
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    var changed = false;
    for (var i = 0; i < _boxes.length; i++) {
      if (_boxes[i] != const BoxData()) {
        _boxes[i] = const BoxData();
        changed = true;
      }
    }
    if (!changed) return;
    notifyListeners();
    await _persist();
  }

  String exportJsonString() => _encodeBoxes();

  String _encodeBoxes() => jsonEncode(_boxes.map((b) => b.toJson()).toList());

  Future<void> _persist() async {
    await _prefs.setString(_storageKey, _encodeBoxes());
  }
}
