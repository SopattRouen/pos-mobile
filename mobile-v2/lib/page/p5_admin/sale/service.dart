import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/paginate.dart';
import 'package:mobile/entity/model/transaction.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  static Future<Paginate<Transaction>> get(
      Paginate<Transaction> paginate,
      {String param = ""}) async {
    print('sales?page=${paginate.currentPage}&$param');
    final box = GetStorage();
    final token = box.read('token'); // Retrieve token from local storage

    // Assuming you are using GET to fetch dashboard data
    var response = await http.get(
      Uri.parse(
          '${mainUrlApi}admin/sales'), // Corrected API endpoint for fetching dashboard data
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    /// Json response body
    var jsonData = jsonDecode(response.body);
    try {
      if (response.statusCode == 200) {
        paginate.currentPage = jsonData["current_page"] ?? 1;
        paginate.lastPage = jsonData['last_page'] ?? 1;
        log("${response.body}");
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
  static Future<List<Transaction>> getSearch({
    int? receiptNumber,
    String? orderedAt,
    int? cashierId,
    String? platform,
  }) async {
    final box = GetStorage();
    final token = box.read('token'); // Retrieve token from local storage

    // Determine which parameter to send
    String queryParams = "";
    if (receiptNumber != null) {
      queryParams = 'key=$receiptNumber';
    } else if (orderedAt != null) {
      queryParams = 'ordered_at=$orderedAt';
    } else if (cashierId != null) {
      queryParams = 'cashier_id=$cashierId';
    } else if (platform != null) {
      queryParams = 'platform=$platform';
    }

    print('Fetching data from: $mainUrlApi' + 'admin/sales?$queryParams');

    var response = await http.get(
      Uri.parse('${mainUrlApi}admin/sales?$queryParams'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Json response body
    var jsonData = jsonDecode(response.body);
  

    List<Transaction> transactions = [];
    try {
      if (response.statusCode == 200) {
        for (var element in jsonData['data']) {
          try {
            Transaction transaction = Transaction.fromJson(element);
            transactions.add(transaction);
          } on Exception {
            continue; // Skip if data cannot be parsed into a Transaction
          }
        }
      } else {
        // Handle errors or unsuccessful status codes
        print('Failed to fetch transactions: ${response.statusCode}');
      }
    } on Exception catch (e) {
      // Handle exceptions during parsing or processing response
      print('Exception occurred: $e');
    }
    return transactions;
  }

  Future<void> downloadReceipt(int receiptNumber,context) async {
    log("$receiptNumber");
    if (!await requestStoragePermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')));
      return;
    }

    final token = box.read('token');
    final response = await http.get(
      Uri.parse(
          '${mainUrlApi}share/print/order-invoice/$receiptNumber'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        // Decode the base64 string to bytes
        final bytes = base64Decode(jsonDecode(response.body)['data']);
        // Save the decoded bytes as a file
        final file = await _saveFile(bytes,receiptNumber);
        if (file != null) {
          OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download successful!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save file')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to process downloaded data: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to download file: ${response.statusCode}')));
    }
  }
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      }

      if (await Permission.storage.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }

      if (await Permission.storage.request().isGranted) {
        return true;
      }

      // Handle Android 11+ scoped storage permission
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    }else if (Platform.isIOS) {
      // On iOS, typically no need to request storage permission
      return true;
    }

    return false;
  }

  Future<File?> _saveFile(List<int> bytes, int receiptNumber) async {
    try {
      final directory = Platform.isIOS 
        ? await getApplicationDocumentsDirectory()  // iOS
        : await getExternalStorageDirectory();      // Android
      final path =
          directory?.path ??'';
      final file = File('$path/receipt_$receiptNumber.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      // print("Error saving file: $e");
      return null;
    }
  }
  
}