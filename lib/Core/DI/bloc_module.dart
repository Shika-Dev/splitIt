import 'package:get_it/get_it.dart';
import 'package:split_it/Presentation/scan_page/bloc/scan_page_bloc.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';

class BlocModule {
  static void provide() {
    GetIt getIt = GetIt.instance;
    getIt.registerSingleton<ScanPageBloc>(
      ScanPageBloc(usecase: GetIt.instance<ScanBillUsecase>()),
    );
  }
}
