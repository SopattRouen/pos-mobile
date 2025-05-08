import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class Service {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
   Future<void> downloadReceipt(String startDate, String endDate,context,String url) async {
    if (!await requestStoragePermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')));
      return;
    }

    final token = box.read('token');
    final response = await http.get(
      Uri.parse(
          '$mainUrlApi$url?startDate=$startDate&endDate=$endDate'),
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
        final file = await _saveFile(bytes, endDate);
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

  Future<File?> _saveFile(List<int> bytes, String endDate) async {
    try {
      final directory = Platform.isIOS 
        ? await getApplicationDocumentsDirectory()  // iOS
        : await getExternalStorageDirectory();      // Android
      final path =
          directory?.path ??'';
      final file = File('$path/receipt_$endDate.pdf');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print("Error saving file: $e");
      return null;
    }
  }
}