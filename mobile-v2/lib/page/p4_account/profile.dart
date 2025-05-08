import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/model/login.dart';
import 'package:mobile/entity/model/user.dart';
import 'package:mobile/page/p4_account/service.dart';
import 'package:mobile/page/p4_account/update.dart';
import 'package:mobile/page/p4_account/update_password.dart';

class ProfileView extends StatefulWidget {
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  final AccountService userController = Get.find<AccountService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        userController.load_user_profile_from_storage();
      }
    });

    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Icon> icons = [
      const Icon(Icons.edit),
      const Icon(Icons.lock_outline),
      const Icon(Icons.logout, color: Colors.red),
    ];
    final List<String> texts = [
      'Update Account',
      'Update Password',
      'Logout',
    ];
    final List<Widget> pages = [
      UpdateProfile(
        name: userController.userprofile.value?.name ?? 'N/A',
        email: userController.userprofile.value?.email ?? 'noemail@example.com',
        phone: userController.userprofile.value?.phone ?? 'No Phone',
        avatar: userController.userprofile.value?.avatar?.isEmpty ?? true
            ? ''
            : userController.userprofile.value!.avatar!,
      ),
      const UpdatePasswordProfile(),
    ];

    return Obx(() {
      final userProfile = userController.userprofile.value;
      log('User after login and display on profile view: ${userProfile?.toJson() ?? 'null'}');

      if (userProfile == null) {
        return Scaffold(
          body: Center(
            child: UI.spinKit(),
          ),
        );
      }

      String avatarUrl = userProfile.avatar != null
          ? userProfile.avatar!
          : 'assets/images/avatar.png';

      // log('Avatar URL: $avatarUrl');

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          title: Text(
            "Account",
            style: GoogleFonts.kantumruyPro(fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  _showSettingsMenu(context, icons, texts, pages);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.more_horiz),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF0C7EA5),
            labelColor: const Color(0xFF0C7EA5),
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'Login'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileInfo(userProfile, avatarUrl),
            _buildLogInfo(),
          ],
        ),
      );
    });
  }

  Widget _buildProfileInfo(UserModel userProfile, String avatarUrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 55,
            backgroundImage:userProfile.avatar!=null? NetworkImage("https://file-v4-api.uat.camcyber.com/$avatarUrl"):AssetImage(avatarUrl),
            // child:
            //     avatarUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
          ),
          const SizedBox(height: 16),
          Text(
            userProfile.name ?? 'Unknown User',
            style: GoogleFonts.kantumruyPro(fontSize: 24),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.phone_android_sharp,
                      color: Colors.blueGrey,
                    ),
                    title: Text(
                      "Phone",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                    trailing: Text(
                      userProfile.phone ?? 'No Phone',
                      style: GoogleFonts.kantumruyPro(fontSize: 14),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.email,
                      color: Colors.blueGrey,
                    ),
                    title: Text(
                      "Email",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                    trailing: Text(
                      userProfile.email ?? 'No Email',
                      style: GoogleFonts.kantumruyPro(fontSize: 14),
                    ),
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.calendar_today_outlined),
                  //   title: Text("Date",style: GoogleFonts.kantumruyPro(),),
                  //   trailing: Text(
                  //     userProfile. ?? 'No Email',
                  //     style: GoogleFonts.kantumruyPro(fontSize: 14),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogInfo() {
    final service = AccountService();
    return FutureBuilder<List<Login>>(
      future: service.getLog(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: UI.spinKit());
        } else if (snapshot.hasError) {
          return Center(child: UI.spinKit());
        } else if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var log = snapshot.data![index];
                    Icon icon;
                    // Determine the icon based on the platform
                    if (log.platform!.toLowerCase().contains('mobile')) {
                      icon =
                          const Icon(Icons.phone_android_sharp); // Mobile icon
                    } else {
                      icon = const Icon(
                          Icons.desktop_mac_outlined); // Desktop icon
                    }
                    return Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300))),
                      child: ListTile(
                        leading: icon, // Use the determined icon

                        title: Text(
                          log.ipAddress!,
                          style: GoogleFonts.kantumruyPro(),
                        ),
                        trailing: Text(
                          DateFormat('dd-MM-yyyy hh:mm a')
                              .format(log.timestamp!),
                          style: GoogleFonts.kantumruyPro(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text("No data available"));
        }
      },
    );
  }

  void _showSettingsMenu(
    BuildContext context,
    List<Icon> icons,
    List<String> texts,
    List<Widget> pages,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: icons.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: icons[index],
                title: Text(
                  texts[index],
                  style: GoogleFonts.kantumruyPro(fontSize: 16),
                ),
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context);
                    if (index == 2) {
                      userController.logout();
                    } else {
                      Get.to(
                        () => pages[index],
                        transition: Transition.downToUp,
                        duration: const Duration(milliseconds: 350),
                      );
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}
