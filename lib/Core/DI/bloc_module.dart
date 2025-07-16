import 'package:get_it/get_it.dart';
import 'package:split_it/Core/Services/ocr_service.dart';
import 'package:split_it/Domain/Usecases/homepage_usecase.dart';
import 'package:split_it/Domain/Usecases/split_bill_usecase.dart';
import 'package:split_it/Domain/Usecases/summary_usecase.dart';
import 'package:split_it/Presentation/homepage/bloc/homepage_bloc.dart';
import 'package:split_it/Presentation/scan_page/bloc/scan_page_bloc.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';
import 'package:split_it/Presentation/split_bill/bloc/split_bill_bloc.dart';
import 'package:split_it/Presentation/summary_page/bloc/summary_page_bloc.dart';

class BlocModule {
  static void provide() {
    GetIt getIt = GetIt.instance;

    getIt.registerFactory<ScanPageBloc>(
      () => ScanPageBloc(
        usecase: GetIt.instance<ScanBillUsecase>(),
        ocrService: GetIt.instance<OCRService>(),
      ),
    );

    getIt.registerFactory<SplitBillBloc>(
      () => SplitBillBloc(usecase: GetIt.instance<SplitBillUsecase>()),
    );

    getIt.registerFactory<SummaryPageBloc>(
      () => SummaryPageBloc(usecase: GetIt.instance<SummaryUsecase>()),
    );

    getIt.registerFactory<HomepageBloc>(
      () => HomepageBloc(usecase: GetIt.instance<HomepageUsecase>()),
    );
  }
}
