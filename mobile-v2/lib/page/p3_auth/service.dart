import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/model/user.dart';
import 'package:mobile/page/p1_splash/splashscreen.dart';

class AuthService {
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
      UI.toast(text: "error",isSuccess: false);
    }
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
        'platform': 'Mobile',
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
          // log('Access token not found in response body: $response_body');
        }
      } else {
        isloading.value = false;
        UI.toast(text: "Failed", isSuccess: false);
        // log('HTTP error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      isloading.value = false;
      UI.toast(text: "Failed", isSuccess: false);
      // log('Login error: $e');
    }
  }

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
      UI.toast(text: "User not Found");
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
}
