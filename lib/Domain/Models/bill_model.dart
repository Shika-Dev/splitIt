class BillModel {
  final List<BillElementModel>? items;
  final num subtotal;
  final num service;
  final num tax;
  final num discount;
  final num total;
  final String billName;
  final String currency;
  final String dateIssued;

  const BillModel({
    required this.items,
    required this.subtotal,
    required this.service,
    required this.tax,
    required this.discount,
    required this.total,
    required this.billName,
    required this.currency,
    required this.dateIssued,
  });
}

class BillElementModel {
  final String name;
  final num quantity;
  final num price;
  final List<String> userIds;

  const BillElementModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.userIds,
  });
}
