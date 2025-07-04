import 'package:split_it/Domain/Models/split_bill_model.dart';
import 'package:split_it/Domain/Models/summary_model.dart';

abstract class SplitBillUsecase {
  Future<SplitBillModel> getBillDetail(String id);
  Future<void> deleteBill(String id);
  Future<String> createSummary(SummaryModel model);
}
