class DeepseekResponse {
  final List<BillItemResponse>? items;
  final num? subtotal;
  final num? service;
  final num? tax;
  final num? discount;
  final num? total;
  final String? billName;
  final String? currency;
  final String? dateIssued;

  DeepseekResponse({
    this.items,
    this.subtotal,
    this.service,
    this.tax,
    this.discount,
    this.total,
    this.billName,
    this.currency,
    this.dateIssued,
  });

  factory DeepseekResponse.fromJson(Map<String, dynamic> json) {
    return DeepseekResponse(
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => BillItemResponse.fromJson(e))
                .toList()
          : null,
      subtotal: json['subtotal'],
      service: json['service'],
      tax: json['tax'],
      discount: json['discount'],
      total: json['total'],
      billName: json['bill_name'],
      currency: json['currency'],
      dateIssued: json['date_issued'],
    );
  }
}

class BillItemResponse {
  final String? name;
  final num? quantity;
  final num? price;

  BillItemResponse({this.name, this.quantity, this.price});

  factory BillItemResponse.fromJson(Map<String, dynamic> json) {
    return BillItemResponse(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}
