import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/detail.dart';
import 'package:mobile/entity/model/paginate.dart';
import 'package:mobile/entity/model/transaction.dart';
class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  Future<void> dalete(int id) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.delete(
        Uri.parse("${mainUrlApi}admin/sales/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {},
      );

      if (response.statusCode == 201) {
        print('Product created successfully: ${response.body}');
      } else {
        print('Failed to create product: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error creating product: $e');
      print('Stack trace: $stackTrace');
    }
  }
  static Future<Paginate<Transaction>> get(
      Paginate<Transaction> paginate,
      {String param = ""}) async {
    print('sales?page=${paginate.currentPage}&$param');
    final box = GetStorage();
    final token = box.read('token'); // Retrieve token from local storage

    // Assuming you are using GET to fetch dashboard data
    var response = await http.get(
      Uri.parse(
          '${mainUrlApi}cashier/sales'), // Corrected API endpoint for fetching dashboard data
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    /// Json response body
    var jsonData = jsonDecode(response.body);
    log('${jsonData}');
    try {
      if (response.statusCode == 200) {
        paginate.currentPage = jsonData["current_page"] ?? 1;
        paginate.lastPage = jsonData['last_page'] ?? 1;

        /// Clear data
        if (paginate.currentPage == 1) {
          paginate.data = [];
        }

        /// Add Transaction into obj
        for (var element in jsonData['data']) {
          try {
            Transaction transaction = Transaction.fromJson(element);
            paginate.data!.add(transaction);
          } on Exception {
            continue;
          }
        }
      } else {}
    } on Exception {
      // paginate.currentPage = page;
    }
    return paginate;
  }
  static Future<List<Details>?> view(int saleId) async {
    log("${saleId}");
    try {
      final response = await http.get(
        Uri.parse('${mainUrlApi}cashier/sales/$saleId/view'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${GetStorage().read('token')}',
        },
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        List<dynamic> detailsJson = data['data']['details'];

        // Parse the list of details
        List<Details> saleDetails = detailsJson
            .map((detailJson) => Details.fromJson(detailJson))
            .toList();

        return saleDetails;
      } else {
        log('Failed to load sale data: ${data['message'] ?? response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }
}
