import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';
import 'package:split_it/Domain/Usecases/summary_usecase.dart';

class SummaryInteractor extends SummaryUsecase {
  final AbsSplitBillRepository repository;
  SummaryInteractor({required this.repository});

  @override
  Future<SummaryModel> getSummary(String id) => repository.getSummary(id);
}
