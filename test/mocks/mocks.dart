import 'package:mockito/annotations.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';
import 'package:split_it/Domain/Usecases/homepage_usecase.dart';
import 'package:split_it/Domain/Usecases/split_bill_usecase.dart';
import 'package:split_it/Domain/Usecases/summary_usecase.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';
import 'package:split_it/Data/Repository/split_bill_repository.dart';
import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';
import 'package:split_it/Data/Datasources/Local/local_datasources.dart';

@GenerateMocks([
  ScanBillUsecase,
  HomepageUsecase,
  SplitBillUsecase,
  SummaryUsecase,
  AbsSplitBillRepository,
  SplitBillRepositoryImpl,
  RemoteDatasources,
  LocalDatasources,
])
void main() {}
