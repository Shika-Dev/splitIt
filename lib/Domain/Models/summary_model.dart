import 'package:split_it/Domain/Models/user_model.dart';

class SummaryModel {
  String id;
  String billName;
  List<UserModel> userList;
  List<SummaryItemModel> summaryList;

  SummaryModel({
    required this.id,
    required this.billName,
    required this.userList,
    required this.summaryList,
  });
}

class SummaryItemModel {
  String userId;
  num totalOwned;
  List<String> items;

  SummaryItemModel({
    required this.userId,
    required this.totalOwned,
    required this.items,
  });
}
