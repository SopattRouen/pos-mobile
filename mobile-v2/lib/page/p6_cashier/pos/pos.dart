import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/app_bar.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/model/order.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p6_cashier/pos/controller/cart_controller.dart';
import 'package:mobile/page/p6_cashier/pos/cart.dart';
import 'package:mobile/page/p6_cashier/pos/service.dart';

class POS extends StatefulWidget {
  const POS({Key? key}) : super(key: key);

  @override
  State<POS> createState() => _POSState();
}

class _POSState extends State<POS> with SingleTickerProviderStateMixin {
  late Future<Order> productsFuture;
  TabController? tabController;
  bool isLoading = true;
  String selectedTab = '';

  @override
  void initState() {
    super.initState();
    Get.put(CartController()); // Initialize the CartController
    productsFuture = Service.get();
    productsFuture.then((order) {
      setState(() {
        final productTypes = order.data!
            .expand((orderItem) => orderItem.products!)
            .map((product) => product.type?.name)
            .where((type) => type != null)
            .toSet()
            .toList();

        // Initialize TabController only if there are product types
        if (productTypes.isNotEmpty) {
          tabController = TabController(
            length: productTypes.length,
            vsync: this,
          );
          selectedTab = productTypes[0] ?? ''; // Set default selected tab
        }
        isLoading = false;
      });
    }).catchError((error) {
      log('Error loading products: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return UI.spinKit();
    } else {
      return FutureBuilder<Order>(
        future: productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return UI.spinKit();
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }
          if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          final products =
              snapshot.data!.data!.expand((order) => order.products!).toList();
          return Stack(
            children: [
              buildContent(products), // Main content with product list
              buildFloatingBar(
                  Get.find<CartController>()), // Floating bar for cart
            ],
          );
        },
      );
    }
  }

  Widget buildContent(List<Products> products) {
    final productTypes = products.map((e) => e.type?.name).toSet().toList();

    if (selectedTab.isEmpty && productTypes.isNotEmpty) {
      selectedTab = productTypes[0] ?? ''; // Default to the first tab
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          if (tabController != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBar(
                tabAlignment: TabAlignment.center,
                controller: tabController,
                isScrollable: true,
                dividerHeight: 0,
                onTap: (index) {
                  setState(() {
                    selectedTab = productTypes[index] ?? '';
                  });
                },
                tabs: productTypes.map((type) {
                  bool isSelected = selectedTab == type;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 8),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: const Color(0xFF0C7EA5),
                                borderRadius: BorderRadius.circular(10),
                              )
                            : BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                        child: Text(
                          type!,
                          style: GoogleFonts.kantumruyPro(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                indicatorColor: Colors.transparent,
                labelPadding: const EdgeInsets.all(0),
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black,
              ),
            ),
          if (tabController != null)
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: productTypes.map((productType) {
                  final filteredProducts = products
                      .where((product) => product.type?.name == productType)
                      .toList();
                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return buildProductCard(product: product);
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildProductCard({required Products product}) {
    final CartController cartController = Get.find<CartController>();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey.shade300),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    product.image ??
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsHXrNDG5sDJWiLkS9g0GL7c_MPiFumwwFPhv9uNRu4eULdJJIQQtaPqfQt3o7QbRCTfE&usqp=CAU',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name ?? '',
                    style: GoogleFonts.kantumruyPro(),
                  ),
                  Text(
                    '${product.type!.name!} ' '| ${product.code}',
                    style: GoogleFonts.kantumruyPro(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.unitPrice!.toDouble().toDollarCurrency(),
                    style: GoogleFonts.kantumruyPro(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Obx(() {
              int count = cartController.products[product] ?? 0;
              return count == 0
                  ? InkWell(
                      onTap: () {
                        cartController.addProduct(product);
                        log('Added product: ${product.name}, Code: ${product.code}, Price: ${product.unitPrice}');
                      },
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.blueGrey,
                        size: 25,
                      ),
                    )
                  : Row(
                      children: [
                        InkWell(
                          onTap: () {
                            cartController.removeProduct(product);
                            log('Removed product: ${product.name}, Code: ${product.code}, Price: ${product.unitPrice}');
                          },
                          child: const Icon(
                            CupertinoIcons.minus_circled,
                            color: Colors.blueGrey,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text("$count"),
                        const SizedBox(
                          width: 8,
                        ),
                        InkWell(
                          onTap: () {
                            cartController.addProduct(product);
                            log('Added product: ${product.name}, Code: ${product.code}, Price: ${product.unitPrice}');
                          },
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.blueGrey,
                            size: 25,
                          ),
                        ),
                      ],
                    );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildFloatingBar(CartController cartController) {
    return Obx(() {
      if (cartController.products.isEmpty) {
        return const SizedBox.shrink();
      }

      return Positioned(
        bottom: 10,
        left: 10,
        right: 10,
        child: GestureDetector(
          onTap: () {
            Get.to(() => CartScreen(
                  products: cartController.products,
                ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0C7EA5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${cartController.products.values.fold(0, (sum, qty) => sum + qty)}',
                    style: GoogleFonts.kantumruyPro(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Cart', // "Your package" in Khmer
                  style: GoogleFonts.kantumruyPro(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  cartController.products.keys
                      .fold(
                        0.0,
                        (sum, product) =>
                            sum +
                            (product.unitPrice ?? 0) *
                                cartController.products[product]!,
                      ).toDollarCurrency(),
                  style: GoogleFonts.kantumruyPro(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
