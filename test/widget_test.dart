import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:utility_collector/main.dart';
import 'package:utility_collector/state/collection_store.dart';

void main() {
  testWidgets('Overview screen shows 106 boxes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await CollectionStore.load();
    await tester.pumpWidget(UtilityCollectorApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Квартиры'), findsOneWidget);
    expect(find.text('0 / 106'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
