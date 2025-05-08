

class Token {
  bool success=false;
  String? message;   // Message from API
  String? accessToken; // Token string

  Token({this.accessToken, this.message,this.success=false,});

  Token.fromJson(Map<String, dynamic> json) {
    accessToken = json['token'];
    message = json['message'];
    // Remove user as it's not in the response
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = accessToken;
    data['message'] = message; // Include message if needed
    return data;
  }
}
