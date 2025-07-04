import 'package:get_it/get_it.dart';
import 'package:split_it/Domain/Interactor/scan_bill_interactor.dart';
import 'package:split_it/Domain/Interactor/split_bill_interactor.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';
import 'package:split_it/Domain/Usecases/split_bill_usecase.dart';

class DomainModule {
  static void provide() {
    GetIt getIt = GetIt.instance;
    getIt.registerSingleton<ScanBillUsecase>(
      ScanBillInteractor(repository: GetIt.instance<AbsSplitBillRepository>()),
    );

    getIt.registerSingleton<SplitBillUsecase>(
      SplitBillInteractor(repository: GetIt.instance<AbsSplitBillRepository>()),
    );
  }
}
