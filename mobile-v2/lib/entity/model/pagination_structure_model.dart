/// Represents a paginated API response structure with generic result type
class PaginationStructure<T> {
  /// Number of items per page
  final int limit;

  /// Page offset (starting from 0 or 1 depending on API)
  final int offset;

  /// Total number of items available
  final int total;

  /// List of results with generic type T
  final List<T> results;

  PaginationStructure({
    required this.limit,
    required this.offset,
    required this.total,
    required this.results,
  });

  /// Creates a PaginationStructure from JSON with a custom result parser
  factory PaginationStructure.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) resultFromJson,
  }) {
    return PaginationStructure<T>(
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      total: json['total'] as int,
      results: (json['results'] as List<dynamic>)
          .map((item) => resultFromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts the PaginationStructure to JSON with a custom result serializer
  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(T) resultToJson,
  }) {
    return {
      'limit': limit,
      'offset': offset,
      'total': total,
      'results': results.map((item) => resultToJson(item)).toList(),
    };
  }
}

// Example usage with a sample Result class:
/*
class EventResult {
  final int id;
  final DateTime startDatetime;
  final DateTime endDatetime;

  EventResult({
    required this.id,
    required this.startDatetime,
    required this.endDatetime,
  });

  factory EventResult.fromJson(Map<String, dynamic> json) {
    return EventResult(
      id: json['id'] as int,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime: DateTime.parse(json['end_datetime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
    };
  }
}

void main() {
  // Sample JSON
  String jsonString = '''
  {
    "limit": 50,
    "offset": 1,
    "total": 12,
    "results": [
      {
        "id": 11,
        "start_datetime": "2025-04-08T00:00:00.000Z",
        "end_datetime": "2025-04-10T00:00:00.000Z"
      }
    ]
  }
  ''';

  // Parse JSON with specific type
  final pagination = PaginationStructure<EventResult>.fromJson(
    jsonDecode(jsonString),
    resultFromJson: (json) => EventResult.fromJson(json),
  );

  // Access values with type safety
  print(pagination.limit);         // 50
  print(pagination.offset);        // 1
  print(pagination.total);         // 12
  print(pagination.results[0].id); // 11
  print(pagination.results[0].startDatetime); // 2025-04-08...

  // Convert back to JSON
  final json = pagination.toJson(
    resultToJson: (result) => result.toJson(),
  );
  print(jsonEncode(json));
}
*/
