import 'package:split_it/Data/Datasources/Remote/remote_datasources.dart';
import 'package:split_it/Data/Mapper/mapper.dart';
import 'package:split_it/Domain/Models/BillItemModel.dart';
import 'package:split_it/Domain/Repository/abs_repository.dart';

class SplitBillRepositoryImpl extends AbsSplitBillRepository {
  final RemoteDatasources remoteDatasources;
  SplitBillRepositoryImpl({required this.remoteDatasources});

  @override
  Future<BillItemModel> getBillItemModels(List<String> rawOcr) async {
    try {
      var response = await remoteDatasources.cleanOCRText(rawOcr);
      return Mapper.toBillItemModel(response);
    } catch (e) {
      rethrow;
    }
  }
}
