import 'package:split_it/Domain/Models/split_bill_model.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';
import 'package:split_it/Domain/Usecases/split_bill_usecase.dart';

class SplitBillInteractor extends SplitBillUsecase {
  final AbsSplitBillRepository repository;
  SplitBillInteractor({required this.repository});

  @override
  Future<SplitBillModel> getBillDetail(String id) =>
      repository.getBillDetail(id);

  @override
  Future<void> deleteBill(String id) => repository.deleteBill(id);

  @override
  Future<void> createSummary(SummaryModel model) =>
      repository.createSummary(model);
}
