import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/provider/global/auth_provider.dart';
import 'package:provider/provider.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://pos-v2-api.uat.camcyber.com/api/',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Initialize Dio with Interceptors
  static void setupInterceptors(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _dio.interceptors.clear(); // Clear previous interceptors

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ Inject token into requests
          String token = '';
          try {
            token = await _storage.read(key: 'token') ?? '';
          } catch (e) {
            print('Failed to read token: $e');
          }
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // ✅ Print request URL & payload in yellow
          print(
              "\x1B[33m📡 Request URL: ${options.baseUrl}${options.path}\x1B[0m");
          print(
              "\x1B[33m🔗 Full Request: ${options.method} ${options.uri}\x1B[0m");

          // ✅ Print request headers
          print("\x1B[33m📝 Headers: ${options.headers}\x1B[0m");

          // ✅ Print request body (payload) - only if it's not null
          if (options.data != null) {
            print("\x1B[33m📦 Payload: ${options.data}\x1B[0m");
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              "\x1B[36m🟢 onResponse Triggered! ${response.requestOptions.path}\x1B[0m");

          if (response.statusCode == 200) {
            try {
              print(
                  "\x1B[32m✅ SUCCESS: ${response.requestOptions.path}\x1B[0m");
            } catch (e) {
              print(
                  "\x1B[32m✅ SUCCESS: ${response.requestOptions.path}\x1B[0m");
              print(
                  "\x1B[32m📡 Response Data: ${response.data.toString()}\x1B[0m");
            }
          } else {
            print(
                "\x1B[33m⚠️ RESPONSE WARNING: ${response.statusCode} - ${response.statusMessage}\x1B[0m");
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print("\x1B[31m❌ onError Triggered: ${e.requestOptions.path}\x1B[0m");

          if (e.response != null &&
              (e.response?.statusCode == 401 ||
                  e.response?.statusCode == 403)) {
            authProvider.isLoggedIn;
          }

          if (e.response != null) {
            print(
                "\x1B[31m❌ ERROR: ${e.response?.statusCode} - ${e.response?.data}\x1B[0m");
          } else {
            print("\x1B[31m❌ Network Error: ${e.message}\x1B[0m");
          }

          return handler.next(e);
        },
      ),
    );
  }

  // Expose Dio instance
  static Dio get dio => _dio;
}
