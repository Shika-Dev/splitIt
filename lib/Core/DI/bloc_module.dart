import 'package:get_it/get_it.dart';
import 'package:split_it/Domain/Usecases/split_bill_usecase.dart';
import 'package:split_it/Domain/Usecases/summary_usecase.dart';
import 'package:split_it/Presentation/scan_page/bloc/scan_page_bloc.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';
import 'package:split_it/Presentation/split_bill/bloc/split_bill_bloc.dart';
import 'package:split_it/Presentation/summary_page/bloc/summary_page_bloc.dart';

class BlocModule {
  static void provide() {
    GetIt getIt = GetIt.instance;

    getIt.registerFactory<ScanPageBloc>(
      () => ScanPageBloc(usecase: GetIt.instance<ScanBillUsecase>()),
    );

    getIt.registerFactory<SplitBillBloc>(
      () => SplitBillBloc(usecase: GetIt.instance<SplitBillUsecase>()),
    );

    getIt.registerFactory<SummaryPageBloc>(
      () => SummaryPageBloc(usecase: GetIt.instance<SummaryUsecase>()),
    );
  }
}
