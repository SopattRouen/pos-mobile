import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:excellent_loading/excellent_loading.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/page/p5_admin/product/type/service.dart';

class CreateTypeProduct extends StatefulWidget {
  final VoidCallback onTypeCreated; // Callback to refresh the product list
  const CreateTypeProduct({super.key, required this.onTypeCreated});

  @override
  State<CreateTypeProduct> createState() => _CreateTypeProductState();
}

class _CreateTypeProductState extends State<CreateTypeProduct> {
  final TextEditingController _controller = TextEditingController();
  File? _image;

  void _handleSubmit() async {
    String productName = _controller.text.trim();
    if (_image == null || productName.isEmpty) {
      UI.toast(
          text: 'សូមបំពេញព័ត៍មានឲ្យបានត្រឹមត្រូវទាំងរូបភាពនឹងNameProduct.',
          isSuccess: false);
      return;
    }

    final bytes = await _image!.readAsBytes();
    String imageBase64 = base64Encode(bytes);

    ExcellentLoading.show(); // Show loading indicator
    try {
      var newProductType = await Service().create(productName, imageBase64);
      widget.onTypeCreated(); // Invoke the callback to refresh the list
      Navigator.pop(context, newProductType);
      UI.toast(text: 'Createជោគជ័យ');
    } catch (e) {
      UI.toast(text: 'មិនអាចCreate: $e', isSuccess: false);
    } finally {
      ExcellentLoading.dismiss(); // Hide loading indicator
    }
  }

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
                'ថតរូប',
                style: GoogleFonts.kantumruyPro(),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                'ជ្រើសរើសរូបភាព',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.close),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'CreateCategory',
          style: GoogleFonts.kantumruyPro(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.check),
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                            color: Colors.grey,
                          ),
                          // width: double.infinity,
                          child: Image.asset(
                              height: mainHeight * 0.3,
                              'assets/images/Image Placeholder.png'),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Container(
                          height: 200,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
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
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                style: GoogleFonts.kantumruyPro(),
                controller: _controller,
                decoration: InputDecoration(
                    labelText: 'Category*',
                    labelStyle: GoogleFonts.kantumruyPro()),
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
            backgroundColor:
                HColors.primaryColor(), // Your custom background color
          ),
        ],
      ),

      // floatingActionButton: CustomElevatedButton(label: "Done", onPressed: _handleSubmit,backgroundColor: HColors.primaryColor(),),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
