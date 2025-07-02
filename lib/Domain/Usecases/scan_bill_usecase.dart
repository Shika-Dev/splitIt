import 'package:split_it/Domain/Models/BillItemModel.dart';

abstract class ScanBillUsecase {
  Future<BillItemModel> getBillItems(List<String> rawOCR);
}
