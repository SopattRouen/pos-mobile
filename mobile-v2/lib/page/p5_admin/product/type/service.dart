import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/product_type.dart';
import 'package:http/http.dart' as http;
class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  Future<List<DataProductType>> get() async {
    final box = GetStorage();
    final token = box.read('token');

    var response = await http.get(
      Uri.parse("${mainUrlApi}admin/products/types/data"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  

    /// Handling the response
    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<DataProductType> productTypes = List<DataProductType>.from(
          jsonData['data'].map((data) => DataProductType.fromJson(data)),
        );
        return productTypes;
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
    }
    throw Exception('Failed to load product types');
  }
  Future<bool> dalete(int id) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.delete(
        Uri.parse("${mainUrlApi}admin/products/types/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {},
      );
      if (response.statusCode == 400) {
        UI.toast(text: "មិនអាចលុបCategoryដែលមានProduct", isSuccess: false);
        return false;
      }

      if (response.statusCode == 201) {
        UI.toast(text: 'Success');
      }else if(response.statusCode == 200){
         UI.toast(text: 'Success');
      }
       else {
        UI.toast(text: 'ប្រតិបត្តការបរាជ័យ');
      }
    } catch (e, stackTrace) {
      UI.toast(text: "$stackTrace", isSuccess: false);
    }
    return true;
  }
  Future<bool> create(String productName,String image) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.post(
        Uri.parse("${mainUrlApi}admin/products/types"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {"name": productName,"image":'data:image/jpeg;base64,$image'},
      );
      if (response.statusCode == 400) {
        UI.toast(text: 'មិនអាចCreateឬNameProductមានរួចហើយ', isSuccess: false);
        return false;
      }

      if (response.statusCode == 201) {
         UI.toast(text: 'Success');
      } else {
         UI.toast(text: 'ប្រតិបត្តការបរាជ័យ');
      }
    } catch (e, stackTrace) {
      UI.toast(text: "$stackTrace",isSuccess: false);
    }
    return true;
  }
  Future<bool> update(String productName, int id,String image) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.put(
        Uri.parse("${mainUrlApi}admin/products/types/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {"name": productName,"image":'data:image/jpeg;base64,$image'},
      );

      if (response.statusCode == 200) {
        UI.toast(text: 'Success');
      } else {
        UI.toast(text: 'ប្រតិបត្តការបរាជ័យ');
      }
    } catch (e, stackTrace) {
      UI.toast(text: '$stackTrace',isSuccess: false);     
    }
   return true;
  }

  
}