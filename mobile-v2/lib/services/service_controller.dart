import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/cashier.dart';
import 'package:mobile/entity/model/dashboard.dart';
import 'package:mobile/entity/model/detail.dart';
import 'package:mobile/entity/model/login.dart';
import 'package:mobile/entity/model/notification.dart';
import 'package:mobile/entity/model/order.dart';
import 'package:mobile/entity/model/paginate.dart';
import 'package:mobile/entity/model/product.dart';
import 'package:mobile/entity/model/product_type_setup.dart';
import 'package:mobile/entity/model/product_type.dart';
import 'package:mobile/entity/model/statistic_product_type.dart';
import 'package:mobile/entity/model/statistic_sale.dart';
import 'package:mobile/entity/model/transaction.dart';
import 'package:mobile/entity/model/user.dart';
import 'package:mobile/page/p1_splash/splashscreen.dart';
import 'package:mobile/page/p2_welcome/welcome.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceController extends GetxController {
  final isloading = false.obs; // Observable for loading state
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage
  Rxn<UserModel> userprofile =
      Rxn<UserModel>(); // Observable for storing user profile
  //  Rx<User> userprofile = User().obs;
  Rx<RoleUser> currentRole = RoleUser().obs;

  /// Method to update the token
  Future<void> updateToken(String newToken) async {
    if (newToken.isNotEmpty) {
      token.value = newToken; // Update token in memory (RxString)
      await box.write(
          'token', newToken); // Persist the new token to local storage
      // log('Token updated: $newToken');
    } else {
      log('Error: Tried to update token with an empty value.');
    }
  }

  void setCurrentRole(RoleUser role) {
    currentRole.value = role;
    update(); // Calls GetX update to refresh UI where needed
  }

  void changeRole(RoleUser selectedRole) {
    // Update the current role
    setCurrentRole(selectedRole);
    // You may want to add other logic to handle role-specific initialization
  }

  /// Handles user login and profile setup
  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      isloading.value = true;

      // Data for login
      var data = {
        'username': username,
        'password': password,
        'platform':'Mobile',
      };

      // Sending the login request
      var response = await http.post(
        Uri.parse('${mainUrlApi}account/auth/login'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: data,
      );

      // Handling the response
      if (response.statusCode == 200) {
        final response_body = json.decode(response.body);

        // Check if token exists in the response
        if (response_body != null && response_body['token'] != null) {
          await updateToken(
              response_body['token']); // Use the updateToken method
          decode_token_and_update_profile(token.value);

          // Navigate to Dashboard
          isloading.value = false;
          UI.toast(
            text: "Success",
          );
          Get.offAll(() => const SplashScreen());
        } else {
          isloading.value = false;
          UI.toast(text: "Failed", isSuccess: false);
          log('Access token not found in response body: $response_body');
        }
      } else {
        isloading.value = false;
        UI.toast(text: "Failed", isSuccess: false);
        log('HTTP error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      isloading.value = false;
      UI.toast(text: "Failed", isSuccess: false);
      log('Login error: $e');
    }
  }

  Future<bool> updateUserRole(int roleId) async {
    final box = GetStorage();
    String? token = box.read('token'); // Retrieve token from storage

    if (token == null || token.isEmpty) {
      Get.snackbar('Error', 'Authentication token is missing or expired.');
      return false; // Early return if token is missing
    }

    try {
      var response = await http.post(
        Uri.parse('${mainUrlApi}account/auth/switch?role_id=$roleId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData.containsKey('token')) {
          String newToken = responseData['token'];
          await updateToken(
              newToken); // Use the updateToken method to save the new token
        }
        return true; // Return true on success
      } else if (response.statusCode == 500) {
        var responseData = jsonDecode(response.body);
        log('Server Error: ${responseData['message']}');
        Get.snackbar('Server Error',
            responseData['message'] ?? 'An unexpected error occurred.');
        return false;
      } else {
        log('Failed to switch role, server responded with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Exception occurred: $e');
      Get.snackbar('Error', 'An error occurred while switching the role.');
      return false;
    }
  }

  /// Decodes the token and updates the user profile
  void decode_token_and_update_profile(String token) {
    try {
      // Decode the JWT token using jwt_decoder
      Map<String, dynamic> decoded_token = JwtDecoder.decode(token);

      // Extract user data from the decoded token
      final user_data = decoded_token['user'];
      if (user_data != null) {
        // Update user profile with roles
        userprofile.value = UserModel.fromJson(user_data);
        log('User profile after login: ${userprofile.value?.toJson()}');

        // Save profile data locally
        saveUserProfileToStorage(userprofile.value!);
      } else {
        log('User data not found in token.');
      }
    } catch (e) {
      log('Error decoding token: $e');
    }
  }

  /// Saves the user profile to local storage
  Future<void> saveUserProfileToStorage(UserModel profile) async {
    // Save the profile to local storage (using your preferred method)
    await box.write('user_profile', profile.toJson());
  }

  /// Loads user profile from local storage
  Future<void> load_user_profile_from_storage() async {
    final stored_profile = box.read('user_profile');
    if (stored_profile != null) {
      userprofile.value = UserModel.fromJson(stored_profile);
      log('User profile loaded from storage: ${userprofile.value?.toJson()}');
    }
    // Simulate async operation by using Future.delayed if needed, or simply return if no delay is needed
    await Future.delayed(Duration.zero);
  }

  /// Updates the user's default role and persists the change
  Future<void> updateDefaultRole(RoleUser selectedRole) async {
    final currentUserProfile = userprofile.value;
    if (currentUserProfile == null) return;

    // Reset all roles to not default
    currentUserProfile.roles!.forEach((role) {
      role.isDefault = false;
    });

    // Set the selected role as default
    selectedRole.isDefault = true;

    // Save the updated profile
    await saveUserProfileToStorage(currentUserProfile);

    // Update the user profile in the controller
    userprofile.value = currentUserProfile;
  }

  Future<void> logout() async {
    try {
      box.remove('token'); // Remove token from local storage
      Get.offAll(() => const WelcomeScreen(),); // Navigate to login screen
      log("Success");
    } catch (e) {
      log('Error while logging out: $e'); // Log logout error
    }
  }

  // ServiceController: Ensure token is loaded from storage when app starts
  void loadTokenFromStorage() {
    final storedToken = box.read('token');
    if (storedToken != null && storedToken.isNotEmpty) {
      token.value = storedToken; // Store token in memory
      log('Token loaded from storage: $storedToken');
    } else {
      log('No token found in storage.');
    }
  }

  Future<ProductTypeSetUp?> fetchProductTypesSetUp() async {
    final token = box.read('token');
    try {
      final response = await http.get(
        Uri.parse('${mainUrlApi}admin/products/setup'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Successfully received the data, parse it
        log('Response: ${response.body}'); // Log the raw response for debugging
        return ProductTypeSetUp.fromJson(json
            .decode(response.body)); // Parse and return ProductTypeSetUp object
      } else {
        log('Failed to load product types: ${response.statusCode}');
        return null; // Return null or handle the error case
      }
    } catch (e) {
      log('Error fetching product types: $e');
      return null; // Return null in case of error
    }
  }

  // Future<Dashboard> fetchDashboard() async {
  //   final token = box.read('token'); // Retrieve token from local storage

  //   // Assuming you are using GET to fetch dashboard data
  //   var response = await http.get(
  //     Uri.parse(
  //         '${mainUrlApi}admin/dashboard'), // Corrected API endpoint for fetching dashboard data
  //     headers: {
  //       'Accept': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   log('Status Code: ${response.statusCode}');

  //   if (response.statusCode == 200) {
  //     return Dashboard.fromJson(jsonDecode(response.body));
  //   } else {
  //     // Better error handling based on status code
  //     if (response.statusCode == 401) {
  //       throw Exception(
  //           'Unauthorized: Check if the token is valid and active.');
  //     } else if (response.statusCode == 403) {
  //       throw Exception('Forbidden: Insufficient permissions.');
  //     } else if (response.statusCode == 404) {
  //       throw Exception('Not Found: The endpoint is incorrect.');
  //     } else {
  //       throw Exception(
  //           'Failed to load dashboard data with status code: ${response.statusCode}');
  //     }
  //   }
  // }
  Future<Dashboard> fetchDashboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = box.read('token'); // Retrieve token from shared preferences
    try {
      var response = await http.get(
        Uri.parse('${mainUrlApi}admin/dashboard'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Cache the response
        await prefs.setString('dashboardData', response.body);
        return Dashboard.fromJson(jsonDecode(response.body));
      } else {
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
        throw Exception('Unauthorized: Check if the token is valid and active.');
      case 403:
        throw Exception('Forbidden: Insufficient permissions.');
      case 404:
        throw Exception('Not Found: The endpoint is incorrect.');
      default:
        throw Exception('Failed to load dashboard data with status code: $statusCode');
    }
  }

  static Future<Paginate<Transaction>> fetchTransaction(
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

  static Future<List<Product>> getProducts() async {
    try {
      final box = GetStorage();
      final token = box.read('token'); // Retrieve token from local storage

      // Assuming you are using GET to fetch dashboard data
      var response = await http.get(
        Uri.parse(
            '${mainUrlApi}admin/products'), // Corrected API endpoint for fetching dashboard data
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      /// Json response body
      var jsonData = jsonDecode(response.body);
      log('${jsonData}');
      if (response.statusCode == 200) {
        Iterable json = jsonData;
        return List<Product>.from(json.map((model) => Product.fromJson(model)));
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products');
    }
  }

  static Future<Paginate<Transaction>> getCashierSales(
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

  static Future<List<Details>?> viewSale(int saleId) async {
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

  static Future<Product> fetchProducts() async {
    final box = GetStorage();
    final token = box.read('token');

    final response = await http.get(
      Uri.parse("${mainUrlApi}admin/products"),
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
      return Product.fromJson(jsonData);
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Order> getOrder() async {
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

  static Future<List<Product>> getProduct() async {
    final box = GetStorage();
    final token = box.read('token');
    final String apiUrl = '${mainUrlApi}admin/products';

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log('Status Code: ${response.statusCode}');
      var res = jsonDecode(response.body);
      log('$res');
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body)['data'];
        List<Product> product =
            body.map((dynamic item) => Product.fromJson(item)).toList();
        return product;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products');
    }
  }

  Future<List<Cashier>> fetchCashier(String week,String year) async {
    final box = GetStorage();
    final token = box.read('token');
    log("$week");
    log("$year");
    var response = await http.get(
      Uri.parse("${mainUrlApi}admin/dashboard/cashier?week=$week&year=$year"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    log("${response.statusCode}");

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      log("$jsonData");
      List<dynamic> cashiersData = jsonData['data'];
      return cashiersData
          .map<Cashier>((json) => Cashier.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load cashier data');
    }
  }

  Future<bool> storeCashierData(String cashierData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('cachedCashierData', cashierData);
  }

  Future<StatisticProductType> fetchProductTypeStatistics(String week,String year) async {
    final box = GetStorage();
    final token = box.read('token');
    var response = await http.get(
      Uri.parse("${mainUrlApi}admin/dashboard/product-type?week=$week&year=$year"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return StatisticProductType.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product type statistics');
    }
  }

  Future<StatisticSales> fetchSaleStatistics(String week,String year) async {
    final box = GetStorage();
    final token = box.read('token');
    log(week,);
    log(year);
    var response = await http.get(
      Uri.parse("${mainUrlApi}admin/dashboard/data-sale?$week=$year"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    log("${response.statusCode}");
    log(response.body);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      log("$res");
      return StatisticSales.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product type statistics');
    }
  }

  Future<List<DataProductType>> typeProduct() async {
    final box = GetStorage();
    final token = box.read('token');

    var response = await http.get(
      Uri.parse("${mainUrlApi}admin/products/types"),
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

  Future<Map<String, dynamic>> fetchAllUsers() async {
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

  Future<void> createUser(String name, List<int> roleIds, String phone,
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

  Future<void> updateProfile(
      String name, String phone, String email, String avatar) async {
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
      });

      // Make the HTTP request
      var response = await http.put(
        Uri.parse("${mainUrlApi}account/profile/update"),
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

  Future<void> updatePasswordProfile(String conPass, String pass) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.put(
        Uri.parse("${mainUrlApi}account/profile/update-password"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {"password": pass, "confirm_password": conPass},
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

  Future<bool> daleteUser(int id) async {
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

  Future<bool> createProductType(String productName) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.post(
        Uri.parse("${mainUrlApi}admin/products/types"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {"name": productName},
      );
      if (response.statusCode == 400) {
        print('Name already exists!');
        UI.toast(text: 'មិនអាចCreate', isSuccess: false);
        return false;
      }

      if (response.statusCode == 201) {
        print('Product created successfully: ${response.body}');
      } else {
        print('Failed to create product: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error creating product: $e');
      print('Stack trace: $stackTrace');
    }
    return true;
  }

  Future<void> updateProductType(String productName, int id) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      var response = await http.put(
        Uri.parse("${mainUrlApi}admin/products/types/$id"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {"name": productName},
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

  Future<bool> daleteProductType(int id) async {
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
        print('Product created successfully: ${response.body}');
      } else {
        print('Failed to create product: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error creating product: $e');
      print('Stack trace: $stackTrace');
      UI.toast(text: "មិនអាចលុបCategoryដែលមានProduct", isSuccess: false);
    }
    return true;
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

  // Update the method signature to accept a String for the image
  static Future<void> createProduct({
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
      log("${response.statusCode}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        UI.toast(text: 'Createបានជោគជ័យ'); // Success toast
        print('Product created successfully: ${data['message']}');
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

  Future<void> updateProduct(String productName, String code, String type,
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
      log("${response.statusCode}");

      if (response.statusCode == 200) {
        print('Product created successfully: ${response.body}');
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

  Future<void> deleteProduct(int id) async {
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
  Future<List<Login>> getLog() async {
    final token = box.read('token');
    try {
      var response = await http.get(
        Uri.parse("${mainUrlApi}account/profile/logs"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          List<dynamic> dataList = jsonResponse['data'];
          return dataList.map((login) => Login.fromJson(login)).toList();
        } else {
          throw Exception("API status returned failure");
        }
      } else {
        throw Exception("Failed to load log data with status code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error occurred: $e");
    }
  }
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
