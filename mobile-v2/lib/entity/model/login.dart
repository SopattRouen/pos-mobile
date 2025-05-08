// Model for each login action
class Login {
   int? id;
   String? action;
   String? details;
   String? ipAddress;
   String? browser;
   String? os;
   String? platform;
   DateTime? timestamp;

  Login({
     this.id,
     this.action,
     this.details,
     this.ipAddress,
     this.browser,
     this.os,
     this.platform,
     this.timestamp,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      id: json['id'],
      action: json['action'],
      details: json['details'],
      ipAddress: json['ip_address'],
      browser: json['browser'],
      os: json['os'],
      platform: json['platform'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}