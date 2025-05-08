import 'package:get/get.dart';

class UserController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var date = ''.obs;
  var role = ''.obs;
  var profilePic = ''.obs;
  var userId = 0.obs;

  void updateUser({
    required String updatedName,
    required String updatedEmail,
    required String updatedPhoneNumber,
    required String updatedDate,
    required String updatedRole,
    required String updatedProfilePic,
    required int updatedUserId,
  }) {
    name.value = updatedName;
    email.value = updatedEmail;
    phoneNumber.value = updatedPhoneNumber;
    date.value = updatedDate;
    role.value = updatedRole;
    profilePic.value = updatedProfilePic;
    userId.value = updatedUserId;
  }
}
