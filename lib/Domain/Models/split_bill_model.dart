import 'package:split_it/Domain/Models/bill_model.dart';
import 'package:split_it/Domain/Models/user_model.dart';

class SplitBillModel {
  String id;
  List<UserModel> users;
  BillModel billModel;

  SplitBillModel({
    required this.id,
    required this.users,
    required this.billModel,
  });
}
