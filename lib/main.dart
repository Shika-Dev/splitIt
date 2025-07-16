import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:split_it/Core/App/app.dart';
import 'package:split_it/Core/DI/bloc_module.dart';
import 'package:split_it/Core/DI/core_module.dart';
import 'package:split_it/Core/DI/domain_module.dart';
import 'package:split_it/Core/DI/local_module.dart';
import 'package:split_it/Core/DI/repository_module.dart';
import 'package:split_it/Core/DI/remote_module.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/bill_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/split_bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_item_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/user_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //env initialization
  await dotenv.load();

  //Hive Initialization
  await Hive.initFlutter();
  Hive.registerAdapter<UserEntity>(UserEntityAdapter());
  Hive.registerAdapter<BillItemEntity>(BillItemEntityAdapter());
  Hive.registerAdapter<BillEntity>(BillEntityAdapter());
  Hive.registerAdapter<SplitBillEntity>(SplitBillEntityAdapter());
  Hive.registerAdapter<SummaryItemEntity>(SummaryItemEntityAdapter());
  Hive.registerAdapter<SummaryEntity>(SummaryEntityAdapter());
  await Hive.openBox<SplitBillEntity>('splitBillBox');
  await Hive.openBox<SummaryEntity>('summaryBox');

  //Dependencies Injector
  CoreModule.provide();
  RemoteModule.provide();
  LocalModule.provide();
  RepositoryModule.provide();
  DomainModule.provide();
  BlocModule.provide();

  runApp(const SplitBillApp());
}
