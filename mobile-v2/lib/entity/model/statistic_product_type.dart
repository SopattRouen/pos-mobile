class StatisticProductType {
  List<String>? labels;
  List<double>? data; // Changed to List<double> for numerical operations

  StatisticProductType({this.labels, this.data});

  StatisticProductType.fromJson(Map<String, dynamic> json) {
    labels = json['labels'].cast<String>();
    data = json['data']?.map<double>((x) => double.parse(x.toString())).toList(); // Handling numeric conversion
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['labels'] = this.labels;
    data['data'] = this.data;
    return data;
  }
}
