import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/page/p5_admin/user/service.dart';
import 'package:excellent_loading/excellent_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/entity/helper/form.dart';
import 'package:mobile/page/p5_admin/user/controller/user_controller.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.roleID,
    required this.avatar,
    required this.userID,
    required this.date,
  });
  final String name;
  final String email;
  final String phone;
  final int roleID;
  final String avatar;
  final int userID;
  final String date;

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final controller = FormInput();
  File? _image;

  // List of roles for selection
  final List<Map<String, dynamic>> roles = [
    {'id': 1, 'name': 'អ្នកគ្រប់គ្រង'}, // Admin
    {'id': 2, 'name': 'Cashier'}, // Cashier
  ];

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

  // Function to show role selection in a bottom sheet
  Future<void> _showRoleSelectionSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ជ្រើសរើសRole',
                style: GoogleFonts.kantumruyPro(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return ListTile(
                    title: Text(
                      role['name'],
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedRoleId = role['id']; // Update selected role
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    selected: selectedRoleId == role['id'],
                    trailing: selectedRoleId == role['id']
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmit() async {
    ExcellentLoading.show(); // Show the loading indicator

    // Get updated input values
    String updatedName = controller.txt_name.text.trim().isEmpty
        ? widget.name
        : controller.txt_name.text.trim();
    String updatedPhone = controller.txt_price.text.trim().isEmpty
        ? widget.phone
        : controller.txt_price.text.trim();
    String updatedEmail = controller.txt_type.text.trim().isEmpty
        ? widget.email
        : controller.txt_type.text.trim();

    // Handle image conversion: use selected image or fallback to avatar URL
    String imageBase64;
    if (_image != null) {
      // Convert the picked image to base64
      final bytes = await _image!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    } else {
      // Convert the avatar URL to base64 if no new image is selected
      final response = await HttpClient().getUrl(Uri.parse(widget.avatar));
      final bytes =
          await consolidateHttpClientResponseBytes(await response.close());
      imageBase64 = base64Encode(bytes);
    }

    try {
      // Call updateUser service with the correct data
      final service = Service();
      await service.updateUser(
        updatedName,
        [selectedRoleId!], // Pass the selected roleId as a list
        updatedPhone,
        updatedEmail,
        imageBase64,
        widget.userID,
      );
      // Update the UserController with the new data
      Get.find<UserController>().updateUser(
        updatedName: updatedName,
        updatedEmail: updatedEmail,
        updatedPhoneNumber: updatedPhone,
        updatedDate: widget.date,
        updatedRole: selectedRoleId == 1 ? 'អ្នកគ្រប់គ្រង' : 'Cashier',
        updatedProfilePic: imageBase64,
        updatedUserId: widget.userID,
      );
      log(updatedName);
    } catch (e) {
      return;
    } finally {
      ExcellentLoading.dismiss(); // Dismiss the loading indicator
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize controller fields with data
    controller.txt_name.text = widget.name;
    controller.txt_price.text = widget.phone;
    controller.txt_type.text = widget.email;

    // Initialize selected role based on the user's current role ID
    selectedRoleId = widget.roleID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.close)),
        title: Text(
          "Updateព័ត៍មាន",
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _handleSubmit),
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
                            backgroundImage: NetworkImage(widget.avatar)),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.grey[300],
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
                              color: Colors.grey[300],
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
                      "Name*",
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                      ),
                    ),
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

            // Role Selection with Bottom Sheet
            Padding(
              padding: const EdgeInsets.all(25),
              child: GestureDetector(
                onTap: _showRoleSelectionSheet, // Trigger the bottom sheet
                child: AbsorbPointer(
                  // AbsorbPointer makes the field non-editable so that it acts like a button
                  child: TextFormField(
                    style: GoogleFonts.kantumruyPro(),
                    decoration: InputDecoration(
                      labelText: 'Role*',
                      labelStyle: GoogleFonts.kantumruyPro(),
                      // hintText: selectedRoleId == 2 ? 'Cashier' : 'អ្នកគ្រប់គ្រង',
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text:
                          selectedRoleId == 1 ? 'អ្នកគ្រប់គ្រង' : 'Cashier',
                    ),
                  ),
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
                      "Phone*",
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                      ),
                    ),
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
                    "អ៊ីម៉ែល*",
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 12,
                    ),
                  )),
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Divider(), // Adds a divider at the top of the bottom navigation bar
          CustomElevatedButton(
            label: "Done", // Your button label
            onPressed: _handleSubmit, // Your handler function
            backgroundColor: HColors.primaryColor(), // Your custom background color
          ),
        ],
      ),
    );
  }
}
