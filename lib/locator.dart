import 'package:get_it/get_it.dart';

import 'state/app_settings.dart';
import 'state/collection_store.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<AppSettings>(await AppSettings.load());
  getIt.registerSingleton<CollectionStore>(await CollectionStore.load());
}
