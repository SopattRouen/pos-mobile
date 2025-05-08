import 'dart:convert';
import 'dart:io';
import 'package:excellent_loading/excellent_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/helper/form.dart';
import 'package:mobile/entity/model/product_type_setup.dart';
import 'package:mobile/page/p5_admin/product/product/service.dart';

class CreateProduct extends StatefulWidget {
  final VoidCallback onProductCreated; // Callback to refresh the product list
  const CreateProduct({super.key, required this.onProductCreated});

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final controller = FormInput();
  File? _image;
  List<DataSetUp> productTypes = []; // Holds fetched product types
  String? selectedTypeName; // Display selected product type
  int? selectedTypeId; // Holds selected product type ID
  final Service service = Service();
  bool _isFormValid = false; // Track form validation status
  @override
  void initState() {
    super.initState();
    _loadProductTypes(); // Load product types on initialization
    _addFormListeners(); // Add listeners to the form fields
  }

  void _addFormListeners() {
    controller.txt_name.addListener(_validateForm);
    controller.txt_code.addListener(_validateForm);
    controller.txt_price.addListener(_validateForm);
    controller.txt_type.addListener(_validateForm);
  }

  //Validate //the form fields
  void _validateForm() {
    final isValid = controller.codekey.currentState?.validate() == true &&
        controller.namekey.currentState?.validate() == true &&
        controller.pricekey.currentState?.validate() == true &&
        controller.typekey.currentState?.validate() == true &&
        _image != null && // Check if an image is selected
        selectedTypeId != null; // Check if a product type is selected

    // Update the button's visibility
    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  void dispose() {
    // Remove listeners to avoid memory leaks
    controller.txt_name.removeListener(_validateForm);
    controller.txt_code.removeListener(_validateForm);
    controller.txt_price.removeListener(_validateForm);
    controller.txt_type.removeListener(_validateForm);
    super.dispose();
  }

  Future<void> _loadProductTypes() async {
    try {
      final productTypeSetUp = await service.fetchProductTypesSetUp();
      if (productTypeSetUp != null) {
        setState(() {
          productTypes = productTypeSetUp.productTypes ?? [];
        });
      } else {
        UI.toast(text: 'Failed to load product types.', isSuccess: false);
      }
    } catch (e) {
      debugPrint('Error fetching product types: $e');
      UI.toast(text: 'Error fetching product types.', isSuccess: false);
    }
  }

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
                'Take Picture',
                style: GoogleFonts.kantumruyPro(),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                'Select Image',
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

  // Show the bottom sheet to select product type
  void _showProductTypeSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          color: Colors.grey[200],
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 130),
              //   child: Container(
              //     width: 120,
              //     height: 5,
              //     decoration: BoxDecoration(
              //       color: Colors.grey,
              //       borderRadius: BorderRadius.circular(15),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: productTypes.length,
                  itemBuilder: (context, index) {
                    final type = productTypes[index];
                    final typeIdInt = int.tryParse(type.id ?? '');

                    return ListTile(
                      onTap: () {
                        if (typeIdInt == null) return;

                        setState(() {
                          selectedTypeName = type.name;
                          selectedTypeId = typeIdInt;
                          controller.txt_type.text = selectedTypeName!;
                        });

                        Navigator.of(context).pop();
                      },
                      title: Text(
                        type.name ?? '',
                        style: GoogleFonts.kantumruyPro(),
                      ),
                      trailing: selectedTypeId == typeIdInt
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmit() async {
    if (_isFormValid) {
      // Convert image to base64 string
      final bytes = await _image!.readAsBytes();
      String imageBase64 = base64Encode(bytes);

      ExcellentLoading.show(); // Show loading indicator before processing

      try {
        // Call create product service
        await Service.create(
          name: controller.txt_name.text,
          code: controller.txt_code.text,
          unitPrice: controller.txt_price.text,
          typeId: selectedTypeId!.toString(),
          imageBase64: imageBase64,
        );
        UI.toast(text: 'Success');
        widget.onProductCreated(); // Refresh the product list
      } catch (e) {
        UI.toast(text: 'Create failed');
        debugPrint('Error creating product: $e');
      } finally {
        ExcellentLoading.dismiss(); // Hide loading indicator
        Navigator.pop(context); // Return to the previous screen
      }
    } else {
      UI.toast(text: 'Please try again', isSuccess: false);
      _validateForm(); // Optional: trigger validation to show errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.close),
        ),
        title: Text(
          "Create",
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Conditionally show the button based on _isFormValid

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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                            color: Colors.grey,
                          ),
                          // width: double.infinity,
                          child: Image.asset(
                              height: mainHeight * 0.2,
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
            // Product Code Input
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.codekey,
                child: TextFormField(
                  style: GoogleFonts.kantumruyPro(),
                  controller: controller.txt_code,
                  decoration: InputDecoration(
                    label: Text(
                      "Code*",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return ("Please enter code product");
                    }
                    return null;
                  },
                ),
              ),
            ),
            // Product Name Input
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.namekey,
                child: TextFormField(
                  style: GoogleFonts.kantumruyPro(),
                  controller: controller.txt_name,
                  decoration: InputDecoration(
                    label: Text(
                      "Name*",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return ("Please name product");
                    }
                    return null;
                  },
                ),
              ),
            ),

            // Product Type Input
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.typekey,
                child: TextFormField(
                  style: GoogleFonts.kantumruyPro(),
                  controller: controller.txt_type,
                  readOnly: true, // Make it read-only
                  onTap:
                      _showProductTypeSelectionBottomSheet, // Show bottom sheet
                  decoration: InputDecoration(
                    label: Text(
                      "Category*",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  validator: (value) {
                    if (selectedTypeName == null || selectedTypeName!.isEmpty) {
                      return ("please select category");
                    }
                    return null;
                  },
                ),
              ),
            ),
            // Product Price Input
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.pricekey,
                child: TextFormField(
                  style: GoogleFonts.kantumruyPro(),
                  controller: controller.txt_price,
                  decoration: InputDecoration(
                    label: Text(
                      "Price*",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return ("Please enter price");
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
          Padding(
            padding: const EdgeInsets.all(15),
            child: CustomElevatedButton(
              label: "Done", // Your button label
              onPressed: _handleSubmit, // Your handler function
              backgroundColor:
                  HColors.primaryColor(), // Your custom background color
            ),
          ),
        ],
      ),
    );
  }
}
