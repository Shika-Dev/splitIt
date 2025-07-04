import 'package:hive/hive.dart';
import 'package:split_it/Data/Datasources/Local/Entities/split_bill_entity.dart';
import 'package:split_it/Data/Datasources/Local/Entities/summary_entity.dart';

class LocalDatasources {
  Box<SplitBillEntity> splitBillBox = Hive.box<SplitBillEntity>('splitBillBox');
  Box<SummaryEntity> summaryBox = Hive.box<SummaryEntity>('summaryBox');

  Future<String> createOrUpdateSplitBill(SplitBillEntity splitBill) async {
    try {
      await splitBillBox.put(splitBill.id, splitBill);
      return splitBill.id;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<SplitBillEntity> getSplitBill(String id) async {
    try {
      final enitity = splitBillBox.get(id);
      if (enitity != null) {
        return enitity;
      } else {
        throw Exception("Bill not found");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteBill(String id) async {
    try {
      await splitBillBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete the Bill');
    }
  }

  Future<String> createSummary(SummaryEntity summary) async {
    try {
      await summaryBox.put(summary.id, summary);
      return summary.id;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<SummaryEntity> getSummary(String id) async {
    try {
      final entity = summaryBox.get(id);
      if (entity != null) {
        return entity;
      } else {
        throw Exception("Summary not found");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
