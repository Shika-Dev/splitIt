import 'package:split_it/Domain/Models/BillItemModel.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';
import 'package:split_it/Domain/Usecases/scan_bill_usecase.dart';

class ScanBillInteractor extends ScanBillUsecase {
  final AbsSplitBillRepository repository;
  ScanBillInteractor({required this.repository});

  @override
  Future<BillItemModel> getBillItems(List<String> rawOCR) =>
      repository.getBillItemModels(rawOCR);
}
