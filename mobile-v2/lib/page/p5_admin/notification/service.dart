import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/notification.dart';
import 'package:http/http.dart' as http;
class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  Future<NotificationS> getNotification() async {
    final token = box.read('token');
    try {
      var response = await http.get(
        Uri.parse("${mainUrlApi}share/notifications"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return NotificationS.fromJson(data); // Parse into Notifiction object
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}