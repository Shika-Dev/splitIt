import 'package:split_it/Data/Datasources/Local/Entities/split_bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_entity.dart';
import 'package:split_it/Data/Datasources/Local/local_datasources.dart';
import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';
import 'package:split_it/Data/Mapper/mapper.dart';
import 'package:split_it/Domain/Models/bill_item_model.dart';
import 'package:split_it/Domain/Models/split_bill_model.dart';
import 'package:split_it/Domain/Models/summary_model.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';

class SplitBillRepositoryImpl extends AbsSplitBillRepository {
  final RemoteDatasources remoteDatasources;
  final LocalDatasources localDatasource;
  SplitBillRepositoryImpl({
    required this.remoteDatasources,
    required this.localDatasource,
  });

  @override
  Future<BillItemModel> getBillItemModels(List<String> rawOcr) async {
    try {
      var response = await remoteDatasources.cleanOCRText(rawOcr);
      return Mapper.toBillItemModel(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createSplitBillEntity(BillItemModel billItem) async {
    try {
      SplitBillEntity splitBillEntity = Mapper.toSplitBillEntity(billItem);
      return await localDatasource.createOrUpdateSplitBill(splitBillEntity);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SplitBillModel> getBillDetail(String id) async {
    try {
      final entity = await localDatasource.getSplitBill(id);
      return Mapper.toSplitBillModel(entity);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteBill(String id) async {
    try {
      await localDatasource.deleteBill(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createSummary(SummaryModel model) async {
    try {
      SummaryEntity entity = Mapper.toSummaryEntity(model);
      return await localDatasource.createSummary(entity);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SummaryModel> getSummary(String id) async {
    try {
      final entity = await localDatasource.getSummary(id);
      return Mapper.toSummaryModel(entity);
    } catch (e) {
      rethrow;
    }
  }
}
