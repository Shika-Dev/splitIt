class BillItemModel {
  final List<BillItem>? items;
  final num subtotal;
  final num service;
  final num tax;
  final num discount;
  final num total;
  final String billName;

  const BillItemModel({
    required this.items,
    required this.subtotal,
    required this.service,
    required this.tax,
    required this.discount,
    required this.total,
    required this.billName,
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

  BillItem copyWith({String? name, String? quantity, String? price}) =>
      BillItem(
        name: name ?? this.name,
        quantity: num.tryParse(quantity ?? '') ?? this.quantity,
        price: num.tryParse(price ?? '') ?? this.price,
      );
}
