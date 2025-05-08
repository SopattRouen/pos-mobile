class Dashboard {
  Statistics? statatics;
  String? message;

  Dashboard({this.statatics, this.message});

  Dashboard.fromJson(Map<String, dynamic> json) {
    final dashboard = json['dashboard'];
    statatics = dashboard != null && dashboard['statistic'] != null
        ? Statistics.fromJson(dashboard['statistic'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      'statistic': statatics?.toJson(),
      'message': message,
    };
  }
}
class Statistics {
  int? totalProduct;
  int? totalProductType;
  int? totalUser;
  int? totalOrder;
  double? total;
  double? totalPercentageIncrease;
  String? saleIncreasePreviousDay;

  Statistics({
    this.totalProduct,
    this.totalProductType,
    this.totalUser,
    this.totalOrder,
    this.total,
    this.totalPercentageIncrease,
    this.saleIncreasePreviousDay,
  });

  Statistics.fromJson(Map<String, dynamic> json) {
    totalProduct = json['totalProduct'];
    totalProductType = json['totalProductType'];
    totalUser = json['totalUser'];
    totalOrder = json['totalOrder'];
    total = (json['total'] as num?)?.toDouble();
    totalPercentageIncrease = (json['totalPercentageIncrease'] as num?)?.toDouble();
    saleIncreasePreviousDay = json['saleIncreasePreviousDay'];
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProduct': totalProduct,
      'totalProductType': totalProductType,
      'totalUser': totalUser,
      'totalOrder': totalOrder,
      'total': total,
      'totalPercentageIncrease': totalPercentageIncrease,
      'saleIncreasePreviousDay': saleIncreasePreviousDay,
    };
  }
}
