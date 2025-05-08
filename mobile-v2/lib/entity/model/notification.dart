import 'package:mobile/entity/model/cashier.dart';

class NotificationS {
  List<NotificationData>? data;

  NotificationS({this.data});

  NotificationS.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(new NotificationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationData {
  int? id;
  String? receiptNumber;
  double? totalPrice;
  String? orderedAt;
  Cashier? cashier;
  bool? read;

  NotificationData(
      {this.id,
      this.receiptNumber,
      this.totalPrice,
      this.orderedAt,
      this.cashier,
      this.read});

 NotificationData.fromJson(Map<String, dynamic> json) {
  id = json['id'];
  receiptNumber = json['receipt_number'];
  
  // Handle both int and double types
  var price = json['total_price'];
  if (price is int) {
    totalPrice = price.toDouble();
  } else if (price is double) {
    totalPrice = price;
  } else {
    totalPrice = null;
  }

  orderedAt = json['ordered_at'];
  cashier = json['cashier'] != null ? Cashier.fromJson(json['cashier']) : null;
  read = json['read'];
}


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['receipt_number'] = this.receiptNumber;
    data['total_price'] = this.totalPrice;
    data['ordered_at'] = this.orderedAt;
    if (this.cashier != null) {
      data['cashier'] = this.cashier!.toJson();
    }
    data['read'] = this.read;
    return data;
  }
}

// class Cashier {
//   int? id;
//   String? name;
//   String? avatar;

//   Cashier({this.id, this.name, this.avatar});

//   Cashier.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     avatar = json['avatar'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['avatar'] = this.avatar;
//     return data;
//   }
// }