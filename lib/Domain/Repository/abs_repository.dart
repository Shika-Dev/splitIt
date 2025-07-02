import 'package:split_it/Domain/Models/BillItemModel.dart';

abstract class AbsSplitBillRepository {
  Future<BillItemModel> getBillItemModels(List<String> rawOcr);
}
