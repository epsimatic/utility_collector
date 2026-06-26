import 'package:flutter/foundation.dart';

enum BoxMetric { t0, t1, t2 }

@immutable
class BoxData {
  const BoxData({this.t0, this.t1, this.t2});

  final double? t0;
  final double? t1;
  final double? t2;

  bool get hasT0 => t0 != null;
  bool get hasT1 => t1 != null;
  bool get hasT2 => t2 != null;

  bool get isComplete => hasT0 && hasT1 && hasT2;

  int get filledCount => (hasT0 ? 1 : 0) + (hasT1 ? 1 : 0) + (hasT2 ? 1 : 0);

  double? valueFor(BoxMetric slot) => switch (slot) {
    BoxMetric.t0 => t0,
    BoxMetric.t1 => t1,
    BoxMetric.t2 => t2,
  };

  BoxData copyWithMetric(BoxMetric slot, double? value, {required bool clear}) {
    return switch (slot) {
      BoxMetric.t0 =>
        clear
            ? BoxData(t0: null, t1: t1, t2: t2)
            : BoxData(t0: value, t1: t1, t2: t2),
      BoxMetric.t1 =>
        clear
            ? BoxData(t0: t0, t1: null, t2: t2)
            : BoxData(t0: t0, t1: value, t2: t2),
      BoxMetric.t2 =>
        clear
            ? BoxData(t0: t0, t1: t1, t2: null)
            : BoxData(t0: t0, t1: t1, t2: value),
    };
  }

  Map<String, dynamic> toJson() => {'t0': t0, 't1': t1, 't2': t2};

  factory BoxData.fromJson(Map<String, dynamic> json) => BoxData(
    t0: (json['t0'] as num?)?.toDouble(),
    t1: (json['t1'] as num?)?.toDouble(),
    t2: (json['t2'] as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxData && other.t0 == t0 && other.t1 == t1 && other.t2 == t2;

  @override
  int get hashCode => Object.hash(t0, t1, t2);
}
