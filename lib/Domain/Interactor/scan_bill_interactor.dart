import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';

class ScanBillInteractor extends ScanBillUsecase {
  final AbsSplitBillRepository repository;
  ScanBillInteractor({required this.repository});

  @override
  Future<BillItemModel> getBillItems(List<String> rawOCR) =>
      repository.getBillItemModels(rawOCR);

  @override
  Future<String> saveBill(BillItemModel model) =>
      repository.createSplitBillEntity(model);
}
