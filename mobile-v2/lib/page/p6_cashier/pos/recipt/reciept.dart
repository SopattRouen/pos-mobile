

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/sale/service.dart';
import 'package:mobile/page/p6_cashier/pos/controller/cart_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class ReceiptWidget extends StatefulWidget {
  final double totalPrice;
  final String buyerName;
  final String receiptNumber;
  final String date;
  final List<ItemInfoData> items;

  ReceiptWidget({
    super.key,
    required this.totalPrice,
    required this.buyerName,
    required this.receiptNumber,
    required this.date,
    required this.items,
  });

  @override
  State<ReceiptWidget> createState() => _ReceiptWidgetState();
}

class _ReceiptWidgetState extends State<ReceiptWidget> {
  final ScreenshotController screenshotController = ScreenshotController();
  bool isLoading = false;
    // Define the receipt variable globally within the state
  int? receipt;

  @override
  void initState() {
    super.initState();
    // Safely parsing the receipt number
    receipt = int.tryParse(widget.receiptNumber);

    // Check if the receipt is valid
    if (receipt == null) {
      // Handle invalid receipt number (optional, show an error, return, etc.)
      print("Invalid receipt number");
      return; // Early return if receipt is invalid
    }
  }

  final service = Service();

  // The function for downloading the receipt
  void _onDownloadPressed() async {
    setState(() => isLoading = true);
    try {
      await service.downloadReceipt(receipt!, context);  // Using `receipt!` since we check it is not null
    } catch (e) {
      // Handle any errors during the download
      print("Error downloading receipt: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


//   Future<void> _captureAndSaveScreenshot(BuildContext context) async {
//   try {
//     final Uint8List? image = await screenshotController.capture();

//     if (image != null) {
//       // Request permissions if on Android
//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         if (!status.isGranted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Storage permission denied.')),
//           );
//           return;
//         }
//       }

//       // final result = await ImageGallerySaver.saveImage(
//       //   image,
//       //   quality: 100,
//       //   name: 'screenshot_${DateTime.now().millisecondsSinceEpoch}',
//       // );

//       if (result['isSuccess'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Screenshot saved to gallery!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to save screenshot.')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to capture receipt.')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error: $e')),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Screenshot(
            controller: screenshotController,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildIcon(),
                const SizedBox(height: 15),
                _buildTitle(),
                const SizedBox(height: 20),
                receiptSummary(),
                const SizedBox(height: 20),
                actionButtons(context, widget.receiptNumber),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: confirmButton(context),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF0C7EA5),
        borderRadius: BorderRadius.circular(50),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.done,
        color: Colors.white,
        size: 35,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Done',
      style: GoogleFonts.kantumruyPro(fontSize: 24),
    );
  }

  Widget receiptSummary() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description),
                Text(
                  widget.totalPrice.toDouble().toDollarCurrency(),
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            InfoRow(title: 'Cashier', value: widget.buyerName),
            InfoRow(title: 'Reciept', value: widget.receiptNumber),
            InfoRow(title: 'Date', value: widget.date),
            const Divider(),
            for (var item in widget.items)
              ItemInfo(
                name: item.name,
                quantity: 'x${item.quantity}',
                price: double.parse(item.price).toDollarCurrency(),
                total: (item.quantity * double.parse(item.price))
                    .toDollarCurrency(),
              ),
          ],
        ),
      ),
    );
  }

  Widget actionButtons(BuildContext context, String orderId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        isLoading?UI.spinKit():
        _buildActionButton(
          
          icon: Icons.print,
          onPressed:_onDownloadPressed
        ),
        _buildActionButton(
          icon: Icons.download_rounded,
          onPressed: () async {
            // await _captureAndSaveScreenshot(context);
          },
        ),
        _buildActionButton(
          icon: Icons.share,
          onPressed: () {
            // Implement share functionality here
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade300.withOpacity(0.5),
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  Widget confirmButton(BuildContext context) {
    final cartProvider = Get.find<CartController>();

    return Padding(
      padding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF0C7EA5),
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            cartProvider.products.clear();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Text(
            'Order Again',
            style: GoogleFonts.kantumruyPro(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.kantumruyPro(fontSize: 16)),
          Text(value, style: GoogleFonts.kantumruyPro(fontSize: 16)),
        ],
      ),
    );
  }
}

class ItemInfo extends StatelessWidget {
  final String name;
  final String quantity;
  final String price;
  final String total;

  const ItemInfo({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.kantumruyPro(fontSize: 16)),
              Text(price, style: GoogleFonts.kantumruyPro(fontSize: 16)),
            ],
          ),
          Column(
            children: [
              Text(quantity, style: GoogleFonts.kantumruyPro(fontSize: 16)),
              Text(total, style: GoogleFonts.kantumruyPro(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemInfoData {
  final String name;
  final int quantity;
  final String price;

  ItemInfoData({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
