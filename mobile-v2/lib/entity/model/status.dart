class Status {
  int? id;
  String? name;
  String? color;
  String? createdAt;
  String? updatedAt;

  Status({this.id, this.name, this.color, this.createdAt, this.updatedAt});

  Status.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    color = json['color'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['color'] = color;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}