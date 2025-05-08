import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:excellent_loading/excellent_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/components/show_bottom_sheet.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/user.dart';
import 'package:mobile/page/p5_admin/user/create.dart';
import 'package:mobile/page/p5_admin/user/update_password.dart';
import 'package:mobile/page/p5_admin/user/view.dart';
import 'package:mobile/page/p5_admin/user/find_user/find.dart';
import 'package:mobile/page/p5_admin/user/service.dart';
import 'package:mobile/page/p5_admin/report/service.dart' as report;

final icons = [
  Icons.filter_list,
  Icons.arrow_drop_down,
];
final texts = ['', 'Role'];

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> with TickerProviderStateMixin {
  List<DataUser> _users = [];
  List<DataUser> _filteredUsers = [];
  bool _isLoading = true;
  final Map<int, AnimationController> _controllers = {};
  final Map<int, Animation<Offset>> _animations = {};
  late TabController _tabController;
  bool isDownloading = false;
  bool isLoading = false;
  final services = report.Service();

  final icon = [Icons.add, Icons.download];
  final text = ['Create', 'Download'];
  String selectedTab = 'All';
 void _onDownloadPressed(context) async {
  String url = 'share/report/generate-cashier-report';
  setState(() => isLoading = true);

  try {
    await services.downloadReceipt('', '', context, url);
  } catch (e) {
    // Optionally handle the error
    print("Download error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to download report.")),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _tabController =
        TabController(length: SingingCharacter.values.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterUsersByRole(SingingCharacter.values[_tabController.index]
            .toString()
            .split('.')
            .last);
      }
    });
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await Service().get();
      if (!mounted) return;

      setState(() {
        _users = data['users'];
        _isLoading = false;
        _filterUsersByRole(selectedTab); // Default to "All" users
      });

      // Initialize animation controllers
      for (var i = 0; i < _users.length; i++) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );
        _controllers[i] = controller;
        _animations[i] = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0),
        ).animate(controller);
      }
    } catch (error) {
      print('Error fetching users: $error');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filterUsersByRole(String role) {
    setState(() {
      if (role == 'All') {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users
            .where((user) =>
                user.role!.any((r) => r.role?.name!.toLowerCase() == role))
            .toList();
      }
    });
  }

  void _showBottom() {
    showCustomBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final roleNames = _users
            .expand((user) => user.role!.map((role) => role.role!.name))
            .toSet()
            .toList()
          ..insert(0, 'All'); // Inserts "All" at the beginning
        return SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text("Role",
                          style: GoogleFonts.kantumruyPro(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: roleNames.length,
                  itemBuilder: (context, index) {
                    final roleName = roleNames[index];
                    return ListTile(
                      title: Text(
                        roleName!,
                        style: GoogleFonts.kantumruyPro(fontSize: 14),
                      ),
                      trailing: Radio<String>(
                        value: roleName,
                        groupValue: selectedTab,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedTab = value;
                              _filterUsersByRole(value.toLowerCase());
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
                const Divider(),
                CustomElevatedButton(
                  label: 'Done',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: HColors.primaryColor(),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleAnimation(int index) {
    final controller = _controllers[index];
    if (controller != null) {
      controller.isDismissed ? controller.forward() : controller.reverse();
    }
  }

  void _deleteUser(DataUser user) async {
    final service = Service();

    await AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.warning,
      body: Center(
        child: Text(
          'តើអ្នកពិតជាចង់លុបពិតមែនទេ?',
          style: GoogleFonts.kantumruyPro(),
        ),
      ),
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        UI.spinKit();
        bool isDeleted = await service.delete(user.id!);
        if (isDeleted) {
          setState(() {
            _users.removeWhere((item) => item.id == user.id);
            UI.toast(text: "Deleted User");
            ExcellentLoading.dismiss();
          });
        } else {
          UI.toast(text: "Can not Delete User", isSuccess: false);
        }
      },
    ).show();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  // void _handleDownload() async {
  //   setState(() {
  //     isDownloading = true;
  //   });
  //   try {
  //     await Service().downloadReceipt(context);
  //     // Optionally handle a success case, such as showing a message
  //   } catch (e) {
  //     print("Download error: $e");
  //     // Optionally handle an error case
  //   } finally {
  //     setState(() {
  //       isDownloading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          'User',
          style: GoogleFonts.kantumruyPro(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                showCustomBottomSheet(
                  context: context,
                  builder: (context) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: icon.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(icon[index]),
                          title: Text(
                            text[index],
                            style: GoogleFonts.kantumruyPro(fontSize: 16),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (index == 0) {
                              Get.to(
                                () => const CreateUser(),
                                transition: Transition.downToUp,
                                duration: const Duration(milliseconds: 350),
                              );
                            } else {
                              if (isLoading) {
                                // Optionally show loading indicator or do nothing
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AlertDialog(
                                    content: UI.spinKit(),
                                  ),
                                );
                              } else {
                                _onDownloadPressed(context);
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
              child: isLoading
                  ? UI.spinKit() // Show loading indicator when downloading
                  : Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child:
                          const Icon(Icons.more_horiz, color: Colors.blueGrey),
                    ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _widget(),
            _isLoading
                ? UI.spinKit()
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          "No User",
                          style: GoogleFonts.kantumruyPro(),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          //                       final userRole = (user.role?.isNotEmpty == true)
                          // ? (user.role!.first.role?.name ?? 'No Role')
                          // : 'No Role';
                          String getUserRole(DataUser user) {
                            if (user.role?.isNotEmpty == true) {
                              return user.role!.first.role?.name ?? 'Admin';
                            }
                            return 'Admin';
                          }

                          final userRole = getUserRole(user);

                          return GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              if (details.primaryDelta! < -5) {
                                _toggleAnimation(index);
                              } else if (details.primaryDelta! > 10) {
                                _toggleAnimation(index);
                              }
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .stretch, // Make buttons stretch to match the row
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0C7EA5),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.lock,
                                              color: Colors.white),
                                          onPressed: () {
                                            Get.to(
                                              () => UpdatePassword(id: user.id),
                                              transition: Transition.downToUp,
                                              duration: const Duration(
                                                  milliseconds: 350),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        // Adjust width for buttons
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.white),
                                          onPressed: () {
                                            _deleteUser(
                                                user); // Trigger delete logic
                                            _controllers[user.id!]?.reverse();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SlideTransition(
                                  position: _animations[index]!,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(
                                        () => ViewUser(
                                          date: user.createdAt!,
                                          email: user.email!,
                                          name: user.name!,
                                          phoneNumber: user.phone!,
                                          role: userRole,
                                          profilePic: user.avatar!,
                                          userId: user.id!,
                                        ),
                                        transition: Transition.rightToLeft,
                                        duration:
                                            const Duration(milliseconds: 400),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade100,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              backgroundImage: user.avatar !=
                                                      null
                                                  ? NetworkImage(user.avatar!)
                                                  : null,
                                              child: user.avatar == null
                                                  ? const Icon(Icons.person)
                                                  : null,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.name ?? 'Unknown User',
                                                  style: GoogleFonts
                                                      .kantumruyPro(),
                                                ),
                                                Text(
                                                  userRole,
                                                  style:
                                                      GoogleFonts.kantumruyPro(
                                                          color: HColors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 190,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(user.phone ?? 'No Phone',
                                                    style: GoogleFonts
                                                        .kantumruyPro(
                                                            color:
                                                                HColors.grey)),
                                                Text(user.email ?? 'No Email',
                                                    style: GoogleFonts
                                                        .kantumruyPro(
                                                            color:
                                                                HColors.grey)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  _widget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      child: Row(
        children: [
          Wrap(
            direction: Axis.horizontal,
            children: List.generate(2, (index) {
              return InkWell(
                onTap: () {
                  if (index == 1) {
                    _showBottom();
                  } else {
                    Get.to(() => const FindUser(),
                        transition: Transition.downToUp);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(25)),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        texts[index],
                        style: GoogleFonts.kantumruyPro(),
                      ),
                      Icon(icons[index]),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
