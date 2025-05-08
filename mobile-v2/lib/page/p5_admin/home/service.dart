import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/cashier.dart';
import 'package:mobile/entity/model/dashboard.dart';
import 'package:mobile/entity/model/statistic_product_type.dart';
import 'package:mobile/entity/model/statistic_sale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  Future<Dashboard> fetchDashboard(String period) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = box.read('token'); // Retrieve token from shared preferences

    try {
      // log("$period"); // Log the selected period

      // Create a map for query parameters
      Map<String, String> queryParameters = {};

      // Add query parameters based on the selected period
      if (period == 'Today') {
        queryParameters['today'] =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
        log(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      } else if (period == 'Yesterday') {
        queryParameters['yesterday'] = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(Duration(days: 1)));
        log(DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(Duration(days: 1))));
      } else if (period == 'This Week') {
        // This week - get the start of the current week (Monday)
        int daysSinceMonday = DateTime.now().weekday - DateTime.monday;
        queryParameters['thisWeek'] = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(Duration(days: daysSinceMonday)));
      }

      final uri = Uri.parse('${mainUrlApi}admin/dashboard').replace(
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      var response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Cache the response
        await prefs.setString('dashboardData', response.body);
        log("${response.body}");
        return Dashboard.fromJson(jsonDecode(response.body));
      } else {
          log("${response.body}");
        return _handleError(response.statusCode);
      }
    } catch (e) {
      var cachedData = prefs.getString('dashboardData');
      if (cachedData != null) {
        return Dashboard.fromJson(jsonDecode(cachedData));
      } else {
        rethrow; // Ensure that no data case is handled by re-throwing the exception
      }
    }
  }

  Dashboard _handleError(int statusCode) {
    switch (statusCode) {
      case 401:
        throw Exception(
            'Unauthorized: Check if the token is valid and active.');
      case 403:
        throw Exception('Forbidden: Insufficient permissions.');
      case 404:
        throw Exception('Not Found: The endpoint is incorrect.');
      default:
        throw Exception(
            'Failed to load dashboard data with status code: $statusCode');
    }
  }

  Future<List<Cashier>> fetchCashier(String period) async {
    final box = GetStorage();
    final token = box.read('token');
    // log("${response.statusCode}");
    // log("$period"); // Log the selected period
    Map<String, String> queryParameters = {};

    // Add query parameters based on the selected period
    if (period == 'Today') {
      queryParameters['today'] =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      log(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    } else if (period == 'Yesterday') {
      queryParameters['yesterday'] = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      log(DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1))));
    } else if (period == 'This Week') {
      // This week - get the start of the current week (Monday)
      int daysSinceMonday = DateTime.now().weekday - DateTime.monday;
      queryParameters['thisWeek'] = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: daysSinceMonday)));
    }

    final uri = Uri.parse('${mainUrlApi}admin/dashboard/cashier').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    var response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      // log("$jsonData");
      List<dynamic> cashiersData = jsonData['data'];
      return cashiersData
          .map<Cashier>((json) => Cashier.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load cashier data');
    }
  }

  Future<StatisticProductType> fetchProductTypeStatistics(String period) async {
    final box = GetStorage();
    final token = box.read('token');
    // var response = await http.get(
    //   Uri.parse("${mainUrlApi}admin/dashboard/product-type?week=$week&year=$year"),
    //   headers: {
    //     'Accept': 'application/json',
    //     'Authorization': 'Bearer $token',
    //   },
    // );
    // log("$period"); // Log the selected period
    Map<String, String> queryParameters = {};
    DateTime now = DateTime.now();
    // Add query parameters based on the selected period
    if (period == 'This Week') {
      // This week - get the start of the current week (Monday)
      int daysSinceMonday = DateTime.now().weekday - DateTime.monday;
      
      queryParameters['thisWeek'] = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: daysSinceMonday)));
          // log(DateFormat('yyyy-MM-dd')
          // .format(DateTime.now().subtract(Duration(days: daysSinceMonday))));
    } else if (period == 'This Month') {
      // This month - get the first day of the current month
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      queryParameters['thisMonth'] =
          DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    } else if (period == '3 Month Ago') {
      // 3 months ago - get the first day of the month three months ago
      DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
      queryParameters['threeMonthAgo'] =
          DateFormat('yyyy-MM-dd').format(threeMonthsAgo);
    } else if (period == '6 Month Ago') {
      // 6 months ago - get the first day of the month six months ago
      DateTime sixMonthsAgo = DateTime(now.year, now.month - 6, 1);
      queryParameters['sixMonthAgo'] =
          DateFormat('yyyy-MM-dd').format(sixMonthsAgo);
    }
    final uri = Uri.parse('${mainUrlApi}admin/dashboard/product-type').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    // log("${uri}");

    var response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // log("${response.body}");
    if (response.statusCode == 200) {
      return StatisticProductType.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product type statistics');
    }
  }

  Future<StatisticSales> fetchSaleStatistics(String period) async {
    final box = GetStorage();
    final token = box.read('token');
    // log(week,);
    // log(year);
    // log("$period"); // Log the selected period
    Map<String, String> queryParameters = {};
    DateTime now = DateTime.now();
    // Add query parameters based on the selected period
    if (period == 'This Week') {
      // This week - get the start of the current week (Monday)
      int daysSinceMonday = DateTime.now().weekday - DateTime.monday;
      
      queryParameters['thisWeek'] = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: daysSinceMonday)));
          // log(DateFormat('yyyy-MM-dd')
          // .format(DateTime.now().subtract(Duration(days: daysSinceMonday))));
    } else if (period == 'This Month') {
      // This month - get the first day of the current month
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      queryParameters['thisMonth'] =
          DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    } else if (period == '3 Month Ago') {
      // 3 months ago - get the first day of the month three months ago
      DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
      queryParameters['threeMonthAgo'] =
          DateFormat('yyyy-MM-dd').format(threeMonthsAgo);
    } else if (period == '6 Month Ago') {
      // 6 months ago - get the first day of the month six months ago
      DateTime sixMonthsAgo = DateTime(now.year, now.month - 6, 1);
      queryParameters['sixMonthAgo'] =
          DateFormat('yyyy-MM-dd').format(sixMonthsAgo);
    }
    final uri = Uri.parse('${mainUrlApi}admin/dashboard/data-sale').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    // log("${uri}");

    var response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      // var res = jsonDecode(response.body);
      // log("$res");
      return StatisticSales.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product type statistics');
    }
  }
}
