import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/role_user.dart';

class User {
  int? id;
  String? name;
  String? email;
  String? avatar;
  String? phone;
  String? token;
  String? password;
  RoleUsers? role;
  User(
      {this.id,
      this.name,
      this.email,
      this.avatar,
      this.phone,
      this.token,
      this.password});

  User.fromJson(Map<String, dynamic> data) {
    switch (data['role'].toString().toLowerCase()) {
      case "admin":
        role = RoleUsers.admin;
        break;
      case "cashier":
        role = RoleUsers.cashier;
        break;
    }
    var json = data['user'];
    id = json['id'];
    name = json['name'];
    email = json['email'];
    if (json['avatar'] != null) {
      avatar = "$mainUrlFile${json['avatar']}";
    }
    phone = json['phone'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = phone;
    data['password'] = password;
    return data;
  }
}
class Users {
  List<DataUser>? data;
  Pagination? pagination;

  Users({this.data, this.pagination});

  Users.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DataUser>[];
      json['data'].forEach((v) {
        data!.add(DataUser.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class DataUser {
  int? id;
  String? name;
  String? avatar;
  String? phone;
  String? email;
  int? isActive;
  String? createdAt;
  List<Role>? role;

  DataUser({
    this.id,
    this.name,
    this.avatar,
    this.phone,
    this.email,
    this.isActive,
    this.createdAt,
    this.role,
  });

  DataUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = mainUrlFile + json['avatar'];
    phone = json['phone'];
    email = json['email'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    if (json['role'] != null) {
      role = <Role>[];
      json['role'].forEach((v) {
        role!.add(Role.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['avatar'] = avatar;
    data['phone'] = phone;
    data['email'] = email;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    if (role != null) {
      data['role'] = role!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Role {
  int? id;
  int? roleId;
  Roles? role;

  Role({this.id, this.roleId, this.role});

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roleId = json['role_id'];
    role = json['role'] != null ? new Roles.fromJson(json['role']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role_id'] = this.roleId;
    if (this.role != null) {
      data['role'] = this.role!.toJson();
    }
    return data;
  }
}

class Roles {
  int? id;
  String? name;

  Roles({this.id, this.name});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
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
    currentPage = json['current_page'];
    perPage = json['per_page'];
    totalPages = json['total_pages'];
    totalItems = json['total_items'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['per_page'] = perPage;
    data['total_pages'] = totalPages;
    data['total_items'] = totalItems;
    return data;
  }
}

class UserModel {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? avatar;
  List<RoleUser>? roles;

  UserModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.avatar,
    this.roles,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    if (json['avatar'] != null) {
      avatar = json['avatar'];
    } else {
      avatar = null;
    } // Prepend base URL
    if (json['roles'] != null) {
      roles = <RoleUser>[];
      json['roles'].forEach((v) {
        roles!.add(RoleUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['avatar'] = avatar;
    if (roles != null) {
      data['roles'] = roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phone: $phone, email: $email, avatar: $avatar, roles: $roles)';
  }
}

class RoleUser {
  int? id;
  String? name;
  String? slug;
  bool? isDefault;

  RoleUser({this.id, this.name, this.slug, this.isDefault});

  RoleUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    isDefault = json['is_default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['is_default'] = isDefault;
    return data;
  }

  RoleUser copyWith({bool? isDefault}) {
    return RoleUser(
      id: this.id,
      name: this.name,
      slug: this.slug,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'RoleUser(id: $id, name: $name, slug: $slug, isDefault: $isDefault)';
  }
}
