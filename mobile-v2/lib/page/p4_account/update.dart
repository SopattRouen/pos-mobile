import 'dart:convert';
import 'dart:io';

import 'package:excellent_loading/excellent_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/helper/form.dart';
import 'package:mobile/services/service_controller.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
  });
  final String name;
  final String email;
  final String phone;
  final String avatar;

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final controller = FormInput();
  File? _image;

  // List of roles for selection
  final List<Map<String, dynamic>> roles = [
    {'id': 1, 'name': 'អ្នកគ្រប់គ្រង'},
    {'id': 2, 'name': 'Cashier'},
  ];
  @override
  void initState() {
    super.initState();

    // Initialize controller fields with data
    controller.txt_name.text = widget.name;
    controller.txt_price.text = widget.phone;
    controller.txt_type.text = widget.email;
  }

  int? selectedRoleId;

  // Pick an image either from camera or gallery
  Future<void> _pickImage() async {
    final pickedFile = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(
                "ថតរូប",
                style: GoogleFonts.kantumruyPro(),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                "ជ្រើសរើសរូបភាព",
                style: GoogleFonts.kantumruyPro(),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      final imageFile = await ImagePicker().pickImage(source: pickedFile);
      if (imageFile != null) {
        setState(() {
          _image = File(imageFile.path);
        });
      }
    }
  }

  void _handleSubmit() async {
    ExcellentLoading.show(); // Show the loading indicator

    String updatedName = controller.txt_name.text.trim().isEmpty
        ? widget.name
        : controller.txt_name.text.trim();
    String updatedPhone = controller.txt_price.text.trim().isEmpty
        ? widget.phone
        : controller.txt_price.text.trim();
    String updatedEmail = controller.txt_type.text.trim().isEmpty
        ? widget.email
        : controller.txt_type.text.trim();

    // Determine role ID from user selection or fallback to widget.roleID
    // List<int> roleIds = selectedRoleId == null
    //     ? (widget.roleID == 1 ? [1, 2] : [2])
    //     : (selectedRoleId == 1 ? [1, 2] : [2]);

    // Handle image conversion: use selected image or fallback to avatar URL
    String imageBase64;
    if (_image != null) {
      // Convert the picked image to base64
      final bytes = await _image!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    } else {
      // Convert the avatar URL to base64 if no new image is selected
      final response =
          await HttpClient().getUrl(Uri.parse("$mainUrlFile${widget.avatar}"));
      final bytes =
          await consolidateHttpClientResponseBytes(await response.close());
      imageBase64 = base64Encode(bytes);
    }

    try {
      // Call updateUser service with the correct data
      final service = ServiceController();
      await service.updateProfile(
        updatedName,
        updatedPhone,
        updatedEmail,
        imageBase64,
      );
      await service.logout();
      // Update the UserController with the new data
      // Get.find<UserController>().updateUser(
      //   updatedName: updatedName,
      //   updatedEmail: updatedEmail,
      //   updatedPhoneNumber: updatedPhone,
      //   updatedDate: widget.date, // Assuming date is unchanged
      //   updatedRole: selectedRoleId == 1
      //       ? 'អ្នកគ្រប់គ្រង'
      //       : 'Cashier', // Adjust as needed
      //   updatedProfilePic:
      //       imageBase64, // Adjust depending on image update logic
      //   updatedUserId: widget.userID,
      // );
      // log(updatedName);
    } catch (e) {
      return;
    } finally {
      ExcellentLoading.dismiss(); // Dismiss the loading indicator
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(Icons.close)),
        title: Text(
          "Update Account",
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _handleSubmit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 55,
                          backgroundImage: widget.avatar.isEmpty
                              ? const AssetImage('assets/images/avatar.png')
                              : NetworkImage(
                                  "$mainUrlFile${widget.avatar}",
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.grey[400],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: FileImage(_image!),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.grey[400],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            // Product Name Input
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.namekey,
                child: TextFormField(
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 14,
                  ),
                  controller: controller.txt_name,
                  decoration: InputDecoration(
                    label: Text(
                      "Name",
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                      ),
                    ),

                    // border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return ("សូមបញ្ចូលNameUser");
                    }
                    return null;
                  },
                ),
              ),
            ),

            // Phone Input
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.pricekey,
                child: TextFormField(
                  controller: controller.txt_price,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    label: Text(
                      "Phone",
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                      ),
                    ),
                    // border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return ("សូមបញ្ចូលPhone");
                    }
                    return null;
                  },
                ),
              ),
            ),
            // Email Input
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.typekey,
                child: TextFormField(
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 14,
                  ),
                  controller: controller.txt_type,
                  decoration: InputDecoration(
                    label: Text(
                      "អ៊ីម៉ែល",
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                      ),
                    ),
                    // border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return ("សូមបញ្ចូលអ៊ីម៉ែល");
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Container(
      //   height: 50,
      //   margin: const EdgeInsets.all(10),
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       shape: RoundedRectangleBorder(
      //         borderRadius:
      //             BorderRadius.circular(8.0), // Set the border radius here
      //       ),
      //       backgroundColor: HColors.primaryColor(),
      //       // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      //       textStyle: GoogleFonts.kantumruyPro(color: Colors.white),
      //     ),
      //     onPressed: _handleSubmit,
      //     child: const Center(
      //       child: Text(
      //         'Done',
      //         style: TextStyle(color: Colors.white),
      //       ),
      //     ),
      //   ),
      // ),
      floatingActionButton: CustomElevatedButton(
        label: 'Done',
        onPressed: _handleSubmit,
        backgroundColor: HColors.primaryColor(),
      ),
      floatingActionButtonLocation:FloatingActionButtonLocation.centerFloat,
    );
  }
}
