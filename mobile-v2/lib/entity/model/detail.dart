import 'package:mobile/entity/enum/e_variable.dart';

class Details {
  int? id;
  double? unitPrice;
  int? qty;
  Productss? product;

  Details({
    this.id,
    this.unitPrice,
    this.qty,
    this.product,
  });

  Details.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unitPrice = json['unit_price'] != null
    ? (json['unit_price'] as num).toDouble()
    : null;

    qty = json['qty'];
    product =
        json['product'] != null ? Productss.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unit_price'] = unitPrice;
    data['qty'] = qty;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}

class Productss {
  int? id;
  String? name;
  String? code;
  String? image;
  ProductsType? type;

  Productss({
    this.id,
    this.name,
    this.code,
    this.image,
    this.type,
  });

  Productss.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    image = mainUrlFile + json['image'];
    type = json['type'] != null ? ProductsType.fromJson(json['type']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['image'] = image;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    return data;
  }
}

class ProductsType {
  String? name;

  ProductsType({this.name});

  ProductsType.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}
