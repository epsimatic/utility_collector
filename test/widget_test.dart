import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:utility_collector/locator.dart';
import 'package:utility_collector/main.dart';

void main() {
  testWidgets('Overview screen shows 106 boxes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    await tester.pumpWidget(const UtilityCollectorApp());
    await tester.pumpAndSettle();

    expect(find.text('Сбор счётчиков'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
