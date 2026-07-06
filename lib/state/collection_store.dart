import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locator.dart';
import '../models/box_data.dart';
import 'app_settings.dart';

class CollectionStore extends ChangeNotifier {
  CollectionStore._(this._prefs, this._boxes);

  static const _storageKey = 'boxes.v1';

  final SharedPreferences _prefs;
  final List<BoxData> _boxes;

  static Future<CollectionStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = getIt<AppSettings>();
    final boxCount = settings.boxCount;
    final metricCount = settings.metricCount;
    final raw = prefs.getString(_storageKey);
    final List<BoxData> boxes = List.generate(
      boxCount,
      (_) => BoxData(metricCount: metricCount),
    );
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (var i = 0; i < decoded.length && i < boxCount; i++) {
            final entry = decoded[i];
            if (entry is Map) {
              final loaded = BoxData.fromJson(entry.cast<String, dynamic>());
              if (loaded.metricCount == metricCount) {
                boxes[i] = loaded;
              } else {
                final values = <double?>[];
                for (var m = 0; m < metricCount; m++) {
                  values.add(m < loaded.metricCount ? loaded.valueAt(m) : null);
                }
                boxes[i] = BoxData(values: values);
              }
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

  int get boxCount => getIt<AppSettings>().boxCount;

  BoxData boxAt(int index) => _boxes[index];

  bool isFilled(int index, int slot) {
    return _boxes[index].valueAt(slot) != null;
  }

  int get filledBoxCount =>
      _boxes.take(boxCount).where((b) => b.isComplete).length;

  Future<void> setMetric(
    int index,
    int slot,
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
    final metricCount = getIt<AppSettings>().metricCount;
    var changed = false;
    for (var i = 0; i < boxCount; i++) {
      if (_boxes[i] != BoxData(metricCount: metricCount)) {
        _boxes[i] = BoxData(metricCount: metricCount);
        changed = true;
      }
    }
    if (!changed) return;
    notifyListeners();
    await _persist();
  }

  Future<void> resizeBoxes(int newCount) async {
    if (newCount == boxCount) return;
    while (_boxes.length < newCount) {
      final metricCount = getIt<AppSettings>().metricCount;
      _boxes.add(BoxData(metricCount: metricCount));
    }
    notifyListeners();
    await _persist();
  }

  Future<void> updateMetricCount(int newMetricCount) async {
    var changed = false;
    for (var i = 0; i < _boxes.length; i++) {
      final box = _boxes[i];
      if (box.metricCount != newMetricCount) {
        final values = <double?>[];
        for (var m = 0; m < newMetricCount; m++) {
          values.add(m < box.metricCount ? box.valueAt(m) : null);
        }
        _boxes[i] = BoxData(values: values);
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
