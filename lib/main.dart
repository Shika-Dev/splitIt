import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:split_it/Core/App/app.dart';
import 'package:split_it/Core/DI/bloc_module.dart';
import 'package:split_it/Core/DI/domain_module.dart';
import 'package:split_it/Core/DI/repository_module.dart';
import 'package:split_it/Core/DI/remote_module.dart';

void main() async {
  await dotenv.load();
  RemoteModule.provide();
  RepositoryModule.provide();
  DomainModule.provide();
  BlocModule.provide();
  runApp(const SplitBillApp());
}
