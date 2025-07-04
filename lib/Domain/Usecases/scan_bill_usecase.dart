import 'package:split_it/Domain/Models/bill_item_model.dart';

abstract class ScanBillUsecase {
  Future<BillItemModel> getBillItems(List<String> rawOCR);
  Future<String> saveBill(BillItemModel model);
}
