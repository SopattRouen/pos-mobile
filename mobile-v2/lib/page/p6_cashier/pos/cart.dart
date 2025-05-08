import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/entity/model/order.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p6_cashier/pos/pos_cart_review.dart';
import 'package:mobile/page/p6_cashier/pos/controller/cart_controller.dart';
import 'package:mobile/services/service_controller.dart';

class CartScreen extends StatefulWidget {
  final Map<Products, int> products;

  const CartScreen({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late DateTime currentDateTime;
  late String formattedDate;
  String cashierName =
      'Unknown Cashier'; // Add a variable to hold the cashier's name
  final ServiceController userController = Get.find<ServiceController>();
  Map<Products, bool> productClickState =
      {}; // Track the click state for products

  @override
  void initState() {
    super.initState();
    // Load the user's profile when the widget is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.load_user_profile_from_storage();
      setState(() {
        cashierName =
            userController.userprofile.value!.name ?? 'Unknown Cashier';
      });
    });

    // Get the current date and time
    currentDateTime = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime);

    // Initialize the product click state
    widget.products.forEach((product, _) {
      productClickState[product] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      Future.delayed(Duration.zero,
          () => Get.back()); // Delay navigation to avoid immediate call
      return const SizedBox(); // Return an empty widget to avoid rendering issues
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Cart",
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // buildCashierInfo(), // Display cashier info
          buildProductList(),
          buildCheckoutSection(),
        ],
      ),
    );
  }

  // Widget to display cashier information at the top
  // Widget buildCashierInfo() {
  //   return Padding(
  //     padding: const EdgeInsets.all(10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Text(
  //           "Total Sales:${widget.products.entries.fold(0, (sum, entry) => sum + (entry.key.unitPrice ?? 0) * entry.value).toDouble().toDollarCurrency()}",
  //           style: GoogleFonts.kantumruyPro(
  //             fontSize: 16,
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         Text(
  //           'Cashier: $cashierName', // "Cashier: [cashierName]" in Khmer
  //           style: GoogleFonts.kantumruyPro(
  //             fontSize: 16,
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         Text(
  //           'Date: ${formattedDate.toDateDividerStandardMPWT()}', // "Date: [formattedDate]" in Khmer
  //           style: GoogleFonts.kantumruyPro(
  //             fontSize: 16,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildProductList() {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products.keys.elementAt(index);
          final quantity = widget.products[product]!;
          return buildCartItem(product, quantity, index);
        },
      ),
    );
  }

  Widget buildCartItem(Products product, int quantity, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey.shade300),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.network(product.image ?? '', width: 80, height: 80),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.name}',
                      style: GoogleFonts.kantumruyPro(),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${product.code}',
                      style: GoogleFonts.kantumruyPro(fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(product.unitPrice!.toDouble().toDollarCurrency(),
                        style: GoogleFonts.kantumruyPro(color: Colors.green)),
                  ],
                ),
              ],
            ),
            buildQuantitySelector(product, quantity),
            buildDeleteButton(product),
          ],
        ),
      ),
    );
  }

  Widget buildQuantitySelector(Products product, int quantity) {
    return GestureDetector(
      onTap: () {
        setState(() {
          productClickState[product] =
              !productClickState[product]!; // Toggle the click state
        });
      },
      child: Container(
        width: 80,
        // height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.black),
        ),
        alignment: Alignment.center,
        child: productClickState[product]!
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (quantity > 1) {
                          widget.products[product] = quantity - 1;
                        } else {
                          // widget.products.remove(product);
                          // Get.find<CartController>().removeProduct(product);
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text(
                          //         'អ្នកបានលុបProduct'), // "Product removed" in Khmer
                          //   ),
                          // );
                        }
                      });
                    },
                    child: const Icon(
                      CupertinoIcons.minus_circle,
                      color: Colors.blueGrey,
                      size: 25,
                    ),
                  ),
                  Text('$quantity'),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.products[product] = quantity + 1;
                      });
                    },
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.blueGrey,
                      size: 25,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget buildDeleteButton(Products product) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        setState(() {
          Get.find<CartController>().removeProduct(product);
          widget.products.remove(product);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('អ្នកបានលុបProduct'), // "Product removed" in Khmer
            ),
          );
        });
      },
    );
  }

  Widget buildCheckoutSection() {
    return Column(
      children: [
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ' Total',
                style: GoogleFonts.kantumruyPro(fontSize: 14),
              ), // "Total" in Khmer
              Text(
                widget.products.entries
                    .fold(
                        0.0,
                        (sum, entry) =>
                            sum + (entry.key.unitPrice ?? 0) * entry.value)
                    .toDouble()
                    .toDollarCurrency(), // Total price calculation
                style:
                    GoogleFonts.kantumruyPro(fontSize: 18, color: Colors.green),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(25),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CartReview(
                      products: widget.products,
                      currentDateTime: formattedDate,
                      cashierName:
                          cashierName, // Pass the cashier name to CartReview
                    );
                  },
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF0C7EA5),
                borderRadius: BorderRadius.circular(50),
              ),
              alignment: Alignment.center,
              child: Text(
                'Review', // "Review before checkout" in Khmer

                style: GoogleFonts.kantumruyPro(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
