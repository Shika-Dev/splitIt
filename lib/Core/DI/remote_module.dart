import 'package:get_it/get_it.dart';
import 'package:split_it/Data/Datasources/Remote/network/dio.dart';
import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';

class RemoteModule {
  static void provide() {
    GetIt getIt = GetIt.instance;
    getIt.registerSingleton<NetworkCall>(NetworkCall());
    getIt.registerSingleton<RemoteDatasources>(
      RemoteDatasources(networkCall: GetIt.I<NetworkCall>()),
    );
  }
}
