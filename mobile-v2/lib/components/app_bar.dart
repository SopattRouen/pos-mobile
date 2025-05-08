import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/model/user.dart';
import 'package:mobile/page/p5_admin/report/listing.dart';
import 'package:mobile/page/p5_admin/notification/notification.dart';
import 'package:mobile/services/service_controller.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _hasUnreadNotifications = false;
  Timer? _notificationTimer;
  final ServiceController userController = Get.find<ServiceController>();

  @override
  void initState() {
    super.initState();

    userController.load_user_profile_from_storage().then((_) {
      if (userController.userprofile.value != null &&
          userController.userprofile.value!.roles!.isNotEmpty) {
        var defaultRole = userController.userprofile.value!.roles!.firstWhere(
            (role) => role.isDefault!,
            orElse: () => userController.userprofile.value!.roles!.first);
        userController.setCurrentRole(defaultRole);
      }
    });

    ever(userController.userprofile, (_) {
      if (mounted) {
        setState(() {});
      }
    });

    _startNotificationCheck();
  }

  void _startNotificationCheck() {
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (Timer t) => _checkForUnreadNotifications(),
    );
  }

  void _checkForUnreadNotifications() async {
    try {
      final notificationResponse = await userController.getNotification();
      final bool hasUnread =
          notificationResponse.data!.any((notification) => !notification.read!);
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = hasUnread;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  void markNotificationsAsRead() {
    if (mounted) {
      setState(() {
        _hasUnreadNotifications = false;
      });
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void changeDefaultRole(RoleUser selectedRole) async {
    final userProfile = userController.userprofile.value;
    if (userProfile == null) {
      Get.snackbar("Error", "User profile not loaded.");
      return;
    }

    if (!userProfile.roles!.any((role) => role.id == selectedRole.id)) {
      Get.snackbar("Error", "User does not have the selected role.");
      return;
    }

    userProfile.roles!
        .forEach((role) => role.isDefault = role.id == selectedRole.id);
    userController.saveUserProfileToStorage(userProfile);
    userController.setCurrentRole(selectedRole);

    UI.toast(text: "${selectedRole.name}");

    if (mounted) {
      setState(() {});
    }
  }

  String getImageForRole(RoleUser role) {
    var roleImages = {
      1: 'account-star.png',
      2: 'account-cash.png',
    };
    return 'assets/images/${roleImages[role.id] ?? 'default.png'}';
  }

  // void _showRoleSelectionBottomSheet(List<RoleUser> roles) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height * 0.3,
  //         color: Colors.grey[200],
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 130),
  //               child: Container(
  //                 width: 120,
  //                 height: 5,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey,
  //                   borderRadius: BorderRadius.circular(15),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 16.0),
  //             Card(
  //               color: Colors.white,
  //               child: SizedBox(
  //                 width: MediaQuery.of(context).size.width,
  //                 height: MediaQuery.of(context).size.height * 0.2,
  //                 child: ListView.builder(
  //                   itemCount: roles.length,
  //                   shrinkWrap: true,
  //                   itemBuilder: (context, index) {
  //                     final role = roles[index];
  //                     return ListTile(
  //                       onTap: () {
  //                         changeDefaultRole(role);
  //                         Navigator.of(context).pop();
  //                       },
  //                       leading: Image(
  //                         height: 22,
  //                         image: AssetImage(getImageForRole(role)),
  //                       ),
  //                       title: Text(
  //                         role.name ?? '',
  //                         style: GoogleFonts.kantumruyPro(),
  //                       ),
  //                       trailing: role.isDefault!
  //                           ? const Icon(Icons.check, color: Colors.green)
  //                           : null,
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // var userProfile = userController.userprofile.value;
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logo/crosant.png'),
              ),
            ),
          ),
          Obx(() => Text(
                "${userController.currentRole.value.name}",
                style: GoogleFonts.kantumruyPro(
                  fontSize: 18,
                ),
              )),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        size: 26,
                        color: Color(0xFF64748B),
                      ),
                      onPressed: () {
                        Get.to(() => const Notifications(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 350))
                            ?.then((_) => markNotificationsAsRead());
                      },
                    ),
                  ),
                  if (_hasUnreadNotifications)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(
                width: 5,
              ),
              if(userController.currentRole.value.name=='អ្នកគ្រប់គ្រង')
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () {
                          Get.to(
                            () =>const DownloadPage(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(
                              milliseconds: 350,
                            ),
                          );
                        }
                        // _showRoleSelectionBottomSheet(userProfile!.roles!),
                        ),
                  ),
                ),
              
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey, height: 1.0),
      ),
    );
  }
}
