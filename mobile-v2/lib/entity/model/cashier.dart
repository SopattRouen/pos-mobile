import 'package:mobile/entity/enum/e_variable.dart';

class Cashier {
  int? id;
  String? avatar;
  String? name;
  double? totalAmount;
  double? percentageChange;  // Keep this as double
  List<Role>? roles;

  Cashier({
    this.id,
    this.name,
    this.avatar,
    this.totalAmount,
    this.percentageChange,
    this.roles,
  });

  Cashier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    
    if (json['avatar'] != null) {
      avatar = mainUrlFile + json['avatar'];
    }
    
    name = json['name'];
    
    // Handle conversion for totalAmount
    if (json['totalAmount'] is String) {
      totalAmount = double.tryParse(json['totalAmount']) ?? 0.0;
    } else if (json['totalAmount'] is int) {
      totalAmount = (json['totalAmount'] as int).toDouble();
    } else {
      totalAmount = json['totalAmount']?.toDouble() ?? 0.0;
    }
    
    // Handle conversion for percentageChange
    if (json['percentageChange'] is String) {
      percentageChange = double.tryParse(json['percentageChange']) ?? 0.0;
    } else if (json['percentageChange'] is int) {
      percentageChange = (json['percentageChange'] as int).toDouble();
    } else {
      percentageChange = json['percentageChange']?.toDouble() ?? 0.0;
    }
    
    // Parsing roles if they exist
    roles = json['role'] != null
        ? (json['role'] as List).map((i) => Role.fromJson(i)).toList()
        : [];
    
    print('Roles parsed: $roles');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['avatar'] = avatar;
    data['totalAmount'] = totalAmount;
    data['percentageChange'] = percentageChange;  // Ensure it’s serialized correctly
    data['role'] = roles?.map((v) => v.toJson()).toList();
    return data;
  }
}

class Role {
  int? id;
  String? name;

  Role({this.id, this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['role']['id'], // Access the nested role object
      name: json['role']['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
