import 'package:get_it/get_it.dart';
import 'package:split_it/Data/Datasources/Local/local_datasources.dart';
import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';
import 'package:split_it/Data/Repository/split_bill_repository.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';

class RepositoryModule {
  static void provide() {
    GetIt getIt = GetIt.instance;
    getIt.registerSingleton<AbsSplitBillRepository>(
      SplitBillRepositoryImpl(
        remoteDatasources: GetIt.instance<RemoteDatasources>(),
        localDatasource: GetIt.instance<LocalDatasources>(),
      ),
    );
  }
}
