class StatisticSales {
  List<String>? labels;
  List<double>? data;

  StatisticSales({this.labels, this.data});

  StatisticSales.fromJson(Map<String, dynamic> json) {
    labels = List<String>.from(json['labels']);
    data = (json['data'] as List).map((e) => (e as num).toDouble()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'labels': labels,
      'data': data,
    };
  }
}
