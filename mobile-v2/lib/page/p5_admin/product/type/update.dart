import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/page/p5_admin/product/type/service.dart';

class UpdateProductType extends StatefulWidget {
  final itemId;
  final itemName;
  final image;
  const UpdateProductType({super.key, this.itemId, this.itemName, this.image});

  @override
  State<UpdateProductType> createState() => _UpdateProductTypeState();
}

class _UpdateProductTypeState extends State<UpdateProductType> {
  final TextEditingController _controller = TextEditingController();
  final Service service = Service();
  File? _image;
  String? _imageBase64; // For sending to the API
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.itemName;
    if (widget.image != null) {
      // Load existing image into _image if you want to display it
    }
  }

  void _handleSubmit() async {
    String productName = _controller.text.trim();
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      if (productName.isNotEmpty) {
        if (_image != null) {
          final bytes = await _image!.readAsBytes();
          _imageBase64 = base64Encode(bytes);
        }
        // If no new image is picked, _imageBase64 remains null, we assume backend uses the old image
        try {
          await Service().update(productName, widget.itemId, _imageBase64!);
           Navigator.pop(context, true); // Return true to indicate success
        } catch (e) {
          print(e);
          UI.toast(text: 'សូមបញ្ចូលរូបភាព.', isSuccess: false);
          isLoading = false;
        }
      } else {
        UI.toast(text: 'សូមបញ្ចូលName.', isSuccess: false);
        isLoading = false;
      }
    }
    setState(() {
      isLoading = false;
    });
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
          _imageBase64 = null; // Clear previous base64 if picking a new image
        });
      }
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
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.close),
        ),
        title: Text(
          'UpdateCategory',
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _handleSubmit,
            icon: isLoading
                ? UI.spinKit()
                : const Icon(Icons.check)
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
                          ),
                          // width: double.infinity,
                          child: Image.network(
                              height: mainHeight * 0.2, '${widget.image}'),
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
                controller: _controller,
                style: GoogleFonts.kantumruyPro(),
                decoration: InputDecoration(
                    labelText: 'Category*',
                    labelStyle: GoogleFonts.kantumruyPro()
                    // hintText: '${widget.itemName}',
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
