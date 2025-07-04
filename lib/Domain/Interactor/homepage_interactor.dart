import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';
import 'package:split_it/Domain/Usecases/homepage_usecase.dart';

class HomepageInteractor extends HomepageUsecase {
  final AbsSplitBillRepository repository;
  HomepageInteractor({required this.repository});

  @override
  Future<List<SummaryModel>> getAllSummary() => repository.getAllSummary();

  @override
  Future<void> deleteSummary(String id) => repository.deleteSummary(id);
}
