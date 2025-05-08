import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/show_bottom_sheet.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/user.dart';
import 'package:mobile/page/p5_admin/home/home_view.dart';
import 'package:mobile/page/p5_admin/info/info_page.dart';
import 'package:mobile/page/p6_cashier/sale/listing.dart';
import 'package:mobile/page/p5_admin/sale/listing.dart';
import 'package:mobile/page/p6_cashier/pos/pos.dart';
import 'package:mobile/page/p5_admin/product/product/listing.dart';
import 'package:mobile/page/p4_account/profile.dart';
import 'package:mobile/page/p5_admin/user/listing.dart';
import 'package:mobile/services/service_controller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;
  Timer? _notificationTimer;
  final ServiceController userController = Get.find<ServiceController>();

  final icon = [
    'assets/images/switch.png',
    'assets/images/viewacc.png',
    'assets/images/info.png',
  ];
  final page = [
    ProfileView(),
    const InfoPage(),
  ];
  final text = [
    'Switch Role',
    'Account',
    'Info',
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    // Load user profile from storage and set the default role
    userController.load_user_profile_from_storage().then((_) {
      var defaultRole = userController.userprofile.value?.roles?.firstWhere(
          (role) => role.isDefault!,
          orElse: () => userController.userprofile.value!.roles!.first);
      if (defaultRole != null) {
        userController.setCurrentRole(defaultRole);
      }
    });

    // Listen for currentRole changes and refresh UI

    ever(userController.currentRole, (_) {
      // Reset to the first page whenever the role changes
      _pageController.jumpToPage(0);
      _selectedIndex = 0;
      if (mounted) {
        setState(() {}); // Triggers a rebuild for the new role's UI
      }
    });

    _startNotificationCheck();
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (!mounted) {
        t.cancel(); // Cancel the timer if the widget is no longer mounted
      } else {
        _checkForUnreadNotifications();
      }
    });
    // Ensure the controller has clients before using jumpToPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController
            .jumpToPage(0); // Replace '0' with the target page if needed
      }
    });
    Future.delayed(Duration.zero, () {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0); // Adjust the page number accordingly
      }
    });
  }

  void _startNotificationCheck() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 5),
        (Timer t) => _checkForUnreadNotifications());
  }

  void _checkForUnreadNotifications() async {
    try {
      final notificationResponse = await userController.getNotification();
      notificationResponse.data!.any((notification) => !notification.read!);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  void markNotificationsAsRead() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  // void changeDefaultRole(RoleUser selectedRole) async {
  //   final userProfile = userController.userprofile.value;
  //   if (userProfile == null) {
  //     Get.snackbar("Error", "User profile not loaded.");
  //     return;
  //   }

  //   if (!userProfile.roles!.any((role) => role.id == selectedRole.id)) {
  //     Get.snackbar("Error", "User does not have the selected role.");
  //     return;
  //   }

  //   userProfile.roles!
  //       .forEach((role) => role.isDefault = role.id == selectedRole.id);
  //   userController.saveUserProfileToStorage(userProfile);
  //   userController.setCurrentRole(selectedRole);

  //   Get.snackbar("Success", "Default role switched to ${selectedRole.name}");

  //   if (mounted) {
  //     setState(() {
  //       _pageController.jumpToPage(0);
  //       _selectedIndex = 0;
  //     });
  //   }
  // }
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
      setState(() {
        _pageController.jumpToPage(0);
        _selectedIndex = 0;
      });
    }
  }

  String getImageForRole(RoleUser role) {
    var roleImages = {
      1: 'account-star.png',
      2: 'account-cash.png',
    };
    return 'assets/images/${roleImages[role.id] ?? 'default.png'}';
  }

  void _showRoleSelectionBottomSheet(List<RoleUser> roles) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          // height: MediaQuery.of(context).size.height * 0.3,
          color: Colors.grey[200],
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 130),
                child: Container(
                  width: 120,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListView.builder(
                    itemCount: roles.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final role = roles[index];
                      return ListTile(
                        onTap: () {
                          changeDefaultRole(role);
                          Navigator.of(context).pop();
                        },
                        leading: Image(
                          height: 22,
                          image: AssetImage(getImageForRole(role)),
                        ),
                        title: Text(
                          role.name ?? '',
                          style: GoogleFonts.kantumruyPro(),
                        ),
                        trailing: role.isDefault!
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  int getOthersIndex() {
    if (userController.currentRole.value.id == 1) {
      // Assuming '1' is for a full access role
      return 4; // Index of "Other" in _defaultNavItems
    } else {
      return 2; // Index of "Other" in _restrictedNavItems
    }
  }

  @override
  Widget build(BuildContext context) {
    var userProfile = userController.userprofile.value;

    // If userProfile is null or roles are not loaded yet
    if (userProfile == null || userProfile.roles == null) {
      return UI.spinKit(); // Show loading spinner until userProfile is loaded
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: HColors.primaryColor(),
        items: userController.currentRole.value.id == 1
            ? _defaultNavItems()
            : _restrictedNavItems(),
        selectedLabelStyle: GoogleFonts.kantumruyPro(
          fontSize: 11.0,
          color: HColors.primaryColor(),
        ),
        unselectedLabelStyle: GoogleFonts.kantumruyPro(
          fontSize: 11.0,
          color: Colors.grey,
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: userController.currentRole.value.id == 1
            ? _defaultPages()
            : _restrictedPages(),
        onPageChanged: (index) => setState(() {
          _selectedIndex = index;
        }),
      ),
    );
  }

  

  List<Widget> _defaultPages() => [
        const Home(),
        const ListingTransaction(),
        const ProductPage(),
        UserList(),
        // ProfileView(),
      ];

  List<Widget> _restrictedPages() => [
        const POS(),
        const CashierListTransaction(),
        // ProfileView(),
      ];

  List<BottomNavigationBarItem> _defaultNavItems() => [
        BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? const Icon(Icons.home)
                : const Icon(Icons.home_outlined),
            label: "Home"),
        BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Image.asset('assets/images/cart2.png', height: 22)
                : const Icon(
                    Icons.shopping_cart_outlined,
                    size: 22,
                  ),
            label: "Sale"),
        BottomNavigationBarItem(
          icon: _selectedIndex == 2
              ? Image.asset('assets/images/pack.png', height: 22)
              : Image.asset('assets/images/package2.png', height: 22),
          label: "Product",
        ),
        BottomNavigationBarItem(
            icon: _selectedIndex == 3
                ? const Icon(Icons.groups_2)
                : const Icon(Icons.groups_2_outlined),
            label: "User"),
        const BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: "Other",
        ),
      ];

  List<BottomNavigationBarItem> _restrictedNavItems() => [
        const BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_rounded), label: "POS"),
        BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Image.asset('assets/images/cart2.png', height: 22)
                : const Icon(
                    Icons.shopping_cart_outlined,
                    size: 22,
                  ),
            label: "Sale"),
        const BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: "Other",
        ),
      ];

  void _onNavItemTapped(int index) {
    var userProfile = userController.userprofile.value;
    int othersIndex = getOthersIndex();
    if (index == othersIndex) {
      showCustomBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: icon.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image(
                          height: 24,
                          image: AssetImage(icon[index]),
                        ),
                        title: Text(
                          text[index],
                          style: GoogleFonts.kantumruyPro(fontSize: 16),
                        ),
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                            if (index == 0) {
                              _showRoleSelectionBottomSheet(userProfile!.roles!);
                            } else if (index==1) {
                              Get.to(
                                () => ProfileView(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 350),
                              );
                            } else {
                              Get.to(
                                () => const InfoPage(),
                                transition: Transition.downToUp,
                                duration: const Duration(milliseconds: 350),
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Version 1.0.0",
                        style: GoogleFonts.kantumruyPro(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void toggleDrawer() {
    if (!_animationController.isAnimating) {
      setState(() {
        _isDrawerOpen = !_isDrawerOpen;
      });
      if (_isDrawerOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
}
