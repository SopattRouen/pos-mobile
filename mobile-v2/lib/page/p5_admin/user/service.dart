import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/paginate.dart';
import 'package:mobile/entity/model/transaction.dart';
import 'package:mobile/entity/model/user.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  Future<Map<String, dynamic>> get() async {
    final token = box.read('token');
    try {
      final response = await http.get(
        Uri.parse("${mainUrlApi}admin/users"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log("${response.statusCode}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log("${data}");

        // Verify data format
        if (data != null && data['data'] is List) {
          List<DataUser> users = (data['data'] as List)
              .map((userJson) => DataUser.fromJson(userJson))
              .toList();
          return {
            'users': users,
          };
        } else {
          throw Exception('Invalid data format. Expected a List.');
        }
      } else {
        throw Exception(
            'Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }
  Future<bool> delete(int id) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.delete(
        Uri.parse("${mainUrlApi}admin/users/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {},
      );
      if (response.statusCode == 400) {
        UI.toast(text: "មិនអាចលុបUser", isSuccess: false);
        return false;
      }

      if (response.statusCode == 201) {
        print('លុបបានជោគជ័យ: ${response.body}');
      } else {
        print('Failed to create product: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error creating product: $e');
      print('Stack trace: $stackTrace');
      UI.toast(text: "មិនអាចលុបUser", isSuccess: false);
    }
    return true;
  }
  static Future<Paginate<Transaction>> getSales(
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
  Future<void> daleteSales(int id) async {
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
   Future<void> updateUser(String name, List<int> roleIds, String phone,
      String email, String avatar, int id) async {
    log(name);
    final box = GetStorage();
    final token = box.read('token');

    try {
      // Encode the body as JSON
      String body = jsonEncode({
        "name": name,
        "phone": phone,
        "email": email,
        "avatar": "data:image/jpeg;base64,$avatar",
        "role_ids": roleIds,
      });

      // Make the HTTP request
      var response = await http.put(
        Uri.parse("${mainUrlApi}admin/users/$id"),
        headers: {
          'Content-Type':
              'application/json', // Ensure the content type is application/json
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      log("Response status code: ${response.statusCode}");

      if (response.statusCode == 400) {
        log("$name, $phone, $email, $avatar,");
        log("${roleIds.toString()}");
        UI.toast(text: 'មិនអាចUpdateព័ត៍មាន', isSuccess: false);
        var data = jsonDecode(response.body);
        log("${data['message']}");
      } else if (response.statusCode == 201) {
        log('Userត្រូវបានUpdateដោយជោគជ័យ: ${response.body}');
        UI.toast(text: 'Userត្រូវបានUpdateដោយជោគជ័យ');
      } else {
        log('User: ${response.body}');
        UI.toast(
          text: 'Updateព័ត៍មានUserបានជោគជ័យ',
        );
      }
    } catch (e, stackTrace) {
      log('Error creating User');
      log('Stack trace: $stackTrace');
      UI.toast(text: 'Error occurred while creating user', isSuccess: false);
    }
  }
  Future<void> updatePassword(int id, String conPass) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.put(
        Uri.parse("${mainUrlApi}admin/users/update-password/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {"confirm_password": conPass},
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
  Future<void> create(String name, List<int> roleIds, String phone,
      String email, String pass, String avatar) async {
    log(name);
    final box = GetStorage();
    final token = box.read('token');

    try {
      // Encode the body as JSON
      String body = jsonEncode({
        "name": name,
        "role_ids": roleIds,
        "phone": phone,
        "email": email,
        "password": pass,
        "avatar": "data:image/jpeg;base64,$avatar",
      });

      // Make the HTTP request
      var response = await http.post(
        Uri.parse("${mainUrlApi}admin/users"),
        headers: {
          'Content-Type':
              'application/json', // Ensure the content type is application/json
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      log("Response status code: ${response.statusCode}");

      if (response.statusCode == 400) {
        log("$name, $phone, $email, $avatar, $pass");
        log("${roleIds.toString()}");
        UI.toast(text: 'មិនអាចCreateUser', isSuccess: false);
        var data = jsonDecode(response.body);
        log("${data['message']}");
      } else if (response.statusCode == 201) {
        log('Userត្រូវបានCreateដោយជោគជ័យ: ${response.body}');
        UI.toast(text: 'Userត្រូវបានCreateដោយជោគជ័យ');
      } else {
        log('Failed to create User: ${response.body}');
        UI.toast(text: 'Failed to create User', isSuccess: false);
      }
    } catch (e, stackTrace) {
      log('Error creating User');
      log('Stack trace: $stackTrace');
      UI.toast(text: 'Error occurred while creating user', isSuccess: false);
    }
  }
  Future<void> downloadReceipt(context) async {
    if (!await requestStoragePermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')));
      return;
    }

    final token = box.read('token');
    final response = await http.get(
      Uri.parse(
          '${mainUrlApi}share/report/cashier'),
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
        final file = await _saveFile(bytes);
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

  Future<File?> _saveFile(List<int> bytes) async {
    try {
      final directory = Platform.isIOS 
        ? await getApplicationDocumentsDirectory()  // iOS
        : await getExternalStorageDirectory();      // Android
      final path =
          directory?.path ??'';
      final file = File('$path/receipt.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print("Error saving file: $e");
      return null;
    }
  }

}