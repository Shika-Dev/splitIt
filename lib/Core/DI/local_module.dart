import 'package:get_it/get_it.dart';
import 'package:split_it/Data/Datasources/Local/local_datasources.dart';

class LocalModule {
  static void provide() {
    GetIt getIt = GetIt.instance;
    getIt.registerSingleton<LocalDatasources>(LocalDatasources());
  }
}
