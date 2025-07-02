import 'package:get_it/get_it.dart';
import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';

class RemoteModule {
  static void provide() {
    GetIt getIt = GetIt.instance;
    getIt.registerSingleton<RemoteDatasources>(RemoteDatasources());
  }
}
