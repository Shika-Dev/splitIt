import 'package:split_it/Domain/Models/summary_model.dart';

abstract class HomepageUsecase {
  Future<List<SummaryModel>> getAllSummary();
  Future<void> deleteSummary(String id);
}
