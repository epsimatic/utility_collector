import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._(this._prefs);

  static const _boxCountKey = 'settings.boxCount';
  static const _metricCountKey = 'settings.metricCount';
  static const _startWith1Key = 'settings.metricsStartWith1';

  final SharedPreferences _prefs;

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings._(prefs);
  }

  int get boxCount => _prefs.getInt(_boxCountKey) ?? kDefaultBoxCount;

  set boxCount(int value) {
    if (value == boxCount) return;
    _prefs.setInt(_boxCountKey, value);
    notifyListeners();
  }

  int get metricCount => _prefs.getInt(_metricCountKey) ?? kDefaultMetricCount;

  set metricCount(int value) {
    if (value == metricCount) return;
    _prefs.setInt(_metricCountKey, value);
    notifyListeners();
  }

  bool get metricsStartWith1 =>
      _prefs.getBool(_startWith1Key) ?? kDefaultMetricsStartWith1;

  set metricsStartWith1(bool value) {
    if (value == metricsStartWith1) return;
    _prefs.setBool(_startWith1Key, value);
    notifyListeners();
  }

  String metricLabel(int index) => 'T${index + (metricsStartWith1 ? 1 : 0)}';
}
