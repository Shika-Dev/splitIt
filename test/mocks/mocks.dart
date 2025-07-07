import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:split_it/Data/Datasources/Remote/network/dio.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';
import 'package:split_it/Domain/Usecases/homepage_usecase.dart';
import 'package:split_it/Domain/Usecases/split_bill_usecase.dart';
import 'package:split_it/Domain/Usecases/summary_usecase.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';
import 'package:split_it/Data/Repository/split_bill_repository.dart';
import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';
import 'package:split_it/Data/Datasources/Local/local_datasources.dart';
import 'package:split_it/Presentation/scan_page/bloc/scan_page_bloc.dart';

@GenerateNiceMocks([
  MockSpec<ScanBillUsecase>(),
  MockSpec<HomepageUsecase>(),
  MockSpec<SplitBillUsecase>(),
  MockSpec<SummaryUsecase>(),
  MockSpec<AbsSplitBillRepository>(),
  MockSpec<SplitBillRepositoryImpl>(),
  MockSpec<RemoteDatasources>(),
  MockSpec<LocalDatasources>(),
  MockSpec<Box>(),
  MockSpec<Dio>(),
  MockSpec<Response>(),
  MockSpec<NetworkCall>(),
  MockSpec<ScanPageBloc>(),
])
void main() {}
