import 'package:mobile/entity/model/product.dart';

class POS {
  int? id;
  String? name;
  List<Product>? products;

  POS({this.id, this.name, this.products});

  POS.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['products'] != null) {
      products = List<Product>.from(
          json['products'].map((product) => Product.fromJson(product)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  get tabs => name;
}
