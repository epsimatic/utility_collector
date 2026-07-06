import 'package:flutter/foundation.dart';

import '../constants.dart';

@immutable
class BoxData {
  BoxData({int? metricCount, List<double?>? values})
    : _values = values ?? List.filled(metricCount ?? kDefaultMetricCount, null);

  final List<double?> _values;

  int get metricCount => _values.length;

  double? valueAt(int index) => _values[index];

  bool get isComplete => _values.any((v) => v != null);
  bool get isEmpty => _values.every((v) => v == null);

  String status(String Function(int) label) {
    final filled = [
      for (var i = 0; i < _values.length; i++)
        if (_values[i] != null && _values[i] != 0) label(i),
    ];
    return filled.isEmpty ? 'Не заполнено' : filled.join(', ');
  }

  BoxData copyWithMetric(int index, double? value, {required bool clear}) {
    final next = List<double?>.of(_values);
    next[index] = clear ? null : value;
    return BoxData(values: next);
  }

  Map<String, dynamic> toJson() => {'metrics': _values};

  factory BoxData.fromJson(Map<String, dynamic> json) {
    final raw = json['metrics'] as List?;
    if (raw == null) return BoxData();
    return BoxData(
      values: raw.map((e) => e == null ? null : (e as num).toDouble()).toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxData &&
          other._values.length == _values.length &&
          List.generate(
            _values.length,
            (i) => other._values[i] == _values[i],
          ).every((e) => e);

  @override
  int get hashCode => Object.hashAll(_values);
}
