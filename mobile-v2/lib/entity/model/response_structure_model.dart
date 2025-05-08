/// Represents the structure of an API response with generic data type
class ResponseStructure<T> {
  /// HTTP status code of the response
  final int statusCode;

  /// Success indicator (1 for success, typically 0 for failure)
  final int success;

  /// Message object containing translations
  final Message message;

  /// Generic data payload
  final T data;

  ResponseStructure({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  /// Creates a ResponseStructure from JSON with a custom data parser
  factory ResponseStructure.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) dataFromJson,
  }) {
    return ResponseStructure<T>(
      statusCode: json['status_code'] as int,
      success: json['success'] as int,
      message: json['message'],
      data: dataFromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Converts the ResponseStructure to JSON with a custom data serializer
  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(T) dataToJson,
  }) {
    return {
      'status_code': statusCode,
      'success': success,
      'message': message.toJson(),
      'data': dataToJson(data),
    };
  }
}

/// Represents a bilingual message structure
class Message {
  /// Khmer language message
  final String kh;

  /// English language message
  final String en;

  Message({
    required this.kh,
    required this.en,
  });

  /// Creates a Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      kh: json['name_kh'] as String,
      en: json['name_en'] as String,
    );
  }

  /// Converts the Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'kh': kh,
      'en': en,
    };
  }
}

// Example usage with a sample Data class:
/*
class SampleData {
  final int id;
  final String name;

  SampleData({required this.id, required this.name});

  factory SampleData.fromJson(Map<String, dynamic> json) {
    return SampleData(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

void main() {
  // Sample JSON
  String jsonString = '''
  {
    "status_code": 200,
    "success": 1,
    "message": {
      "kh": "ជោគជ័យ",
      "en": "Success"
    },
    "data": {
      "id": 1,
      "name": "example"
    }
  }
  ''';

  // Parse JSON with specific type
  final response = ResponseStructure<SampleData>.fromJson(
    jsonDecode(jsonString),
    dataFromJson: (json) => SampleData.fromJson(json),
  );
  
  // Access values with type safety
  print(response.statusCode);     // 200
  print(response.message.en);     // "Success"
  print(response.data.id);        // 1
  print(response.data.name);      // "example"
  
  // Convert back to JSON
  final json = response.toJson(
    dataToJson: (data) => data.toJson(),
  );
  print(jsonEncode(json));
}
*/
