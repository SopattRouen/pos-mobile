import 'package:mobile/entity/model/cashier.dart';
import 'package:mobile/entity/model/detail.dart';

class Transaction {
  int? id;
  int? receiptNumber;
  int? cashierId;
  double? totalPrice;
  double? totalReceived;
  String? platform;
  String? orderedAt;
  Cashier? cashier;
  List<Details>? details;

  Transaction({
    this.id,
    this.receiptNumber,
    this.cashierId,
    this.totalPrice,
    this.totalReceived,
    this.orderedAt,
    this.cashier,
    this.details,
    this.platform,
  });

  Transaction.fromJson(Map<String, dynamic> json) {
  id = _parseInt(json['id']);
  receiptNumber = _parseInt(json['receipt_number']);
  cashierId = _parseInt(json['cashier_id']);
  totalPrice = _parseDouble(json['total_price']);
  totalReceived = _parseDouble(json['total_received']);
  orderedAt = json['ordered_at'];
  platform = json['platform'];

  cashier = json['cashier'] != null ? Cashier.fromJson(json['cashier']) : null;
  if (json['details'] != null) {
    details = List<Details>.from(
      json['details'].map((x) => Details.fromJson(x)),
    );
  }
}


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['receipt_number'] = receiptNumber;
    data['cashier_id'] = cashierId;
    data['total_price'] = totalPrice;
    data['total_received'] = totalReceived;
    data['ordered_at'] = orderedAt;
    data['platform'] = platform;
    if (cashier != null) data['cashier'] = cashier!.toJson();
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
