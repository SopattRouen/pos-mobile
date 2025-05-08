import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/login.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/entity/model/user.dart';
import 'package:mobile/page/p2_welcome/welcome.dart';

class AccountService {
  final token = ''.obs; // Observable for storing token
  final box = GetStorage(); // GetStorage instance for local storage\
  Rxn<UserModel> userprofile =
      Rxn<UserModel>(); // Observable for storing user profile
  //  Rx<User> userprofile = User().obs;
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
        throw Exception(
            "Failed to load log data with status code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error occurred: $e");
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
        // log('User profile after login: ${userprofile.value?.toJson()}');

        // Save profile data locally
        saveUserProfileToStorage(userprofile.value!);
      } else {
        UI.toast(text: "User Not Found",isSuccess: false);
      }
    } catch (e) {
     
     UI.toast(text: "Error",isSuccess: false);
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
      // log('User profile loaded from storage: ${userprofile.value?.toJson()}');
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

  Future<void> logout() async {
    try {
      box.remove('token'); // Remove token from local storage
      Get.offAll(
        () => const WelcomeScreen(),
      ); // Navigate to login screen
      // log("Success");
      UI.toast(text: "Success");
    } catch (e) {
      // log('Error while logging out: $e'); // Log logout error
    }
  }
}
