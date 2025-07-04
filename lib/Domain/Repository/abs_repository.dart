import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Domain/Models/split_bill_model.dart';
import 'package:split_it/Domain/Models/summary_model.dart';

abstract class AbsSplitBillRepository {
  Future<BillItemModel> getBillItemModels(List<String> rawOcr);
  Future<String> createSplitBillEntity(BillItemModel billItem);
  Future<SplitBillModel> getBillDetail(String id);
  Future<void> deleteBill(String id);
  Future<String> createSummary(SummaryModel model);
  Future<SummaryModel> getSummary(String id);
}
