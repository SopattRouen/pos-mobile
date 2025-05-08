import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/order.dart';

class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  static Future<Order> get() async {
    final box = GetStorage();
    final token = box.read('token');

    final response = await http.get(
      Uri.parse("${mainUrlApi}cashier/ordering/products"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    log("${response.statusCode}");
    var res = jsonDecode(response.body);
    log('$res');

    if (response.statusCode == 200) {
      // Correctly parse the JSON response
      var jsonData = json.decode(response.body);
      return Order.fromJson(jsonData);
    } else {
      throw Exception('Failed to load product order');
    }
  }
}
