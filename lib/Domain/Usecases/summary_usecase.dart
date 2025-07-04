import 'package:split_it/Domain/Models/summary_model.dart';

abstract class SummaryUsecase {
  Future<SummaryModel> getSummary(String id);
}
