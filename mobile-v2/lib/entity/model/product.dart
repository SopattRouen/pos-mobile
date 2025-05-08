import 'package:mobile/entity/enum/e_variable.dart';

class Product {
  String? status;
  List<ProductData>? data;
  Pagination? pagination;

  Product({this.status, this.data, this.pagination});

  Product.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <ProductData>[];
      json['data'].forEach((v) {
        data!.add(ProductData.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  get name => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class ProductData {
  int? id;
  String? code;
  String? name;
  String? image;
  double? unitPrice; // ✅ make sure this is `double?`
  String? createdAt;
  TypeData? type;
  Creator? creator;

  ProductData(
      {this.id,
      this.code,
      this.name,
      this.image,
      this.unitPrice,
      this.createdAt,
      this.type,
      this.creator});

  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    image = mainUrlFile + json['image'];
    unitPrice = json['unit_price'] != null
        ? (json['unit_price'] as num).toDouble()
        : null;

    createdAt = json['created_at'];
    type = json['type'] != null ? TypeData.fromJson(json['type']) : null;
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['image'] = image;
    data['unit_price'] = unitPrice;
    data['created_at'] = createdAt;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    return data;
  }
}

class TypeData {
  int? id;
  String? name;

  TypeData({this.id, this.name});

  TypeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Creator {
  int? id;
  String? name;
  String? avatar;

  Creator({this.id, this.name, this.avatar});

  Creator.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? totalPages;
  int? totalItems;

  Pagination({
    this.currentPage,
    this.perPage,
    this.totalPages,
    this.totalItems,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    perPage = json['perPage'];
    totalPages = json['totalPages'];
    totalItems = json['totalItems'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['currentPage'] = currentPage;
    data['perPage'] = perPage;
    data['totalPages'] = totalPages;
    data['totalItems'] = totalItems;
    return data;
  }
}
