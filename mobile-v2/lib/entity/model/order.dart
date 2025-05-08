import 'package:mobile/entity/enum/e_variable.dart';

class Order {
  List<DataOrder>? data;

  Order({this.data});

  Order.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DataOrder>[];
      json['data'].forEach((v) {
        data!.add(DataOrder.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DataOrder {
  int? id;
  String? name;
  List<Products>? products;

  DataOrder({this.id, this.name, this.products});

  DataOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  int? id;
  int? typeId;
  String? name;
  String? image;
  double? unitPrice;
  String? code;
  Type? type; // Reference to the Type class

  Products(
      {this.id,
      this.typeId,
      this.name,
      this.image,
      this.unitPrice,
      this.code,
      this.type});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    typeId = json['type_id'];
    name = json['name'];
    image = mainUrlFile + json['image'];
    unitPrice = json['unit_price'] != null
    ? (json['unit_price'] as num).toDouble()
    : null;

    code = json['code'];
    type = json['type'] != null ? Type.fromJson(json['type']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['type_id'] = this.typeId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['unit_price'] = this.unitPrice;
    data['code'] = this.code;
    if (this.type != null) {
      data['type'] = this.type!.toJson();
    }
    return data;
  }
}

class Type {
  String? name;

  Type({this.name});

  Type.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = this.name;
    return data;
  }
}
