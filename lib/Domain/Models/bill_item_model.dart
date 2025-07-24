class BillItemModel {
  final List<BillItem>? items;
  final num subtotal;
  final num service;
  final num tax;
  final num discount;
  final num total;
  final String billName;
  final String currency;
  final String dateIssued;

  const BillItemModel({
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

class BillItem {
  final String name;
  final num quantity;
  final num price;

  const BillItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
