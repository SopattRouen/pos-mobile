class ProductTypeSetUp {
  List<DataSetUp>? productTypes;
  List<DataSetUp>? users;

  ProductTypeSetUp({this.productTypes, this.users});

  factory ProductTypeSetUp.fromJson(Map<String, dynamic> json) {
    return ProductTypeSetUp(
      productTypes: (json['productTypes'] as List<dynamic>?)
          ?.map((item) => DataSetUp.fromJson(item))
          .toList(),
      users: (json['users'] as List<dynamic>?)
          ?.map((item) => DataSetUp.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productTypes != null)
        'productTypes': productTypes!.map((v) => v.toJson()).toList(),
      if (users != null) 'users': users!.map((v) => v.toJson()).toList(),
    };
  }
}

class DataSetUp {
  String? id; // Changed from int? to String?
  String? name;

  DataSetUp({this.id, this.name});

  factory DataSetUp.fromJson(Map<String, dynamic> json) {
    return DataSetUp(
      id: json['id']?.toString(), // Ensure id is always a string
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
  return {
    if (id != null && int.tryParse(id!) != null) 'id': id,
    'name': name,
  };
}

}
