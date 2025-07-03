import 'package:split_it/Data/Datasources/Remote/Responses/deepseek_response.dart';
import 'package:split_it/Domain/Models/BillItemModel.dart';

class Mapper {
  static BillItemModel toBillItemModel(DeepseekResponse response) {
    try {
      return BillItemModel(
        items:
            response.items
                ?.map(
                  (e) => BillItem(
                    name: e.name ?? '',
                    quantity: e.quantity ?? 0,
                    price: e.price ?? 0,
                  ),
                )
                .toList() ??
            [],
        subtotal: response.subtotal ?? 0,
        service: response.service ?? 0,
        tax: response.tax ?? 0,
        discount: response.discount ?? 0,
        total: response.total ?? 0,
        billName: response.billName ?? '',
      );
    } catch (e) {
      throw Exception('Something went wrong when mapping the data');
    }
  }
}
