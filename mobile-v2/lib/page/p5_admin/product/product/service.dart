import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/product.dart';
import 'package:mobile/entity/model/product_type_setup.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  static Future<Product> get() async {
  final box = GetStorage();
  final token = box.read('token');

  final uri = Uri.parse('${mainUrlApi}admin/products').replace(queryParameters: {
    'page': '1',
    'sort_by': 'created_at',
    'order': 'desc',
    'limit':'50',
  });

  final response = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  log("${response.statusCode}");
  log(response.body);

  if (response.statusCode == 200) {
    return Product.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load products');
  }
}


  static Future<List<ProductData>> getSearch({
    String? keyword,
    String? date,
    String? role,
  }) async {
    final box = GetStorage();
    final token = box.read('token');

    // Build the URL with optional parameters
    final StringBuffer urlBuffer = StringBuffer("${mainUrlApi}admin/products");
    List<String> queryParams = [];

    if (keyword != null && keyword.isNotEmpty) {
      queryParams.add("search=$keyword");
    }
    if (date != null && date.isNotEmpty) {
      queryParams.add("date=$date");
    }
    if (role != null && role.isNotEmpty) {
      queryParams.add("role=$role");
    }

    if (queryParams.isNotEmpty) {
      urlBuffer.write("?" + queryParams.join("&"));
    }

    final response = await http.get(
      Uri.parse(urlBuffer.toString()),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    log("${response.statusCode}");
    log('Response body: ${response.body}'); // Log the response body

    if (response.statusCode == 200) {
      // Check if response contains a 'data' key
      var jsonData = json.decode(response.body);

      // If the response has a 'data' key that contains the list
      if (jsonData['data'] != null && jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map((product) => ProductData.fromJson(product))
            .toList();
      } else {
        throw Exception('Invalid response format: no products found.');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<void> create({
    required String name,
    required String code,
    required String unitPrice,
    required String typeId,
    required String imageBase64, // Now expects a base64 string
  }) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.post(
        Uri.parse("${mainUrlApi}admin/products"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'name': name,
          'code': code,
          'unit_price': unitPrice,
          'type_id': typeId,
          'image':
              'data:image/jpeg;base64,$imageBase64', // Pass the Base64 string
        },
      );
      // log("${response.statusCode}");

      if (response.statusCode == 201) {
        jsonDecode(response.body);
        UI.toast(text: 'Createបានជោគជ័យ'); // Success toast
        // print('Product created successfully: ${data['message']}');
        // Additional logics as needed
      } else {
        final data = jsonDecode(response.body);
        // Handle other statuses
        UI.toast(
          text: '${data['message']}',
          isSuccess: false,
        ); // Success toast
      }
    } catch (e, stackTrace) {
      print('Error creating product: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> update(String productName, String code, String type,
      String price, int id, String image) async {
    try {
      final token = box.read('token');
      var response = await http.put(
        Uri.parse("${mainUrlApi}admin/products/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          "name": productName,
          "code": code,
          "type_id": type,
          "unit_price": price,
          "image": 'data:image/jpeg;base64,$image',
        },
      );
      // log("${response.statusCode}");

      if (response.statusCode == 200) {
        // print('Product created successfully: ${response.body}');
        UI.toast(text: 'ProductបានUpdateដោយជោគជ័យ'); // Success toast
      } else {
        print('Failed to create product: ${response.body}');

        UI.toast(
            text: 'ការUpdateProductបានបរាជ័យ',
            isSuccess: false); // Success toast
      }
    } catch (e, stackTrace) {
      print('Error creating product: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> delete(int id) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.delete(
        Uri.parse("${mainUrlApi}admin/products/$id"),
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

  Future<ProductTypeSetUp?> fetchProductTypesSetUp() async {
  final token = box.read('token');

  try {
    final response = await http.get(
      Uri.parse('${mainUrlApi}admin/products/setup-data'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      log("Success response: ${response.body}");
      final data = json.decode(response.body);
      return ProductTypeSetUp.fromJson(data);
    } else {
      log("Failed to load product types. Status code: ${response.statusCode}");
      log("Response body: ${response.body}");
      return null;
    }
  } catch (e, stackTrace) {
    log('Error fetching product types: $e');
    log('Stack trace: $stackTrace');
    return null;
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
      Uri.parse('${mainUrlApi}share/report/generate-product-report?report_type=PDF'),
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
    } else if (Platform.isIOS) {
      // On iOS, typically no need to request storage permission
      return true;
    }

    return false;
  }

  Future<File?> _saveFile(List<int> bytes) async {
    try {
      final directory = Platform.isIOS
          ? await getApplicationDocumentsDirectory() // iOS
          : await getExternalStorageDirectory(); // Android
      final path = directory?.path ?? '';
      final file = File('$path/receipt.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print("Error saving file: $e");
      return null;
    }
  }
}
