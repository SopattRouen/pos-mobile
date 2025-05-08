import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/model/product_type.dart'; // Assuming this is your model file
import 'package:mobile/page/p5_admin/product/type/create.dart';
import 'package:mobile/page/p5_admin/product/type/update.dart';
import 'package:mobile/page/p5_admin/product/type/service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mobile/entity/enum/e_ui.dart';

class ProductType extends StatefulWidget {
  const ProductType({super.key});

  @override
  State<ProductType> createState() => ProductTypeState();
}

class ProductTypeState extends State<ProductType>
    with TickerProviderStateMixin {
  late Future<List<DataProductType>> productTypesFuture;
  // final GlobalKey<ProductTypeState> _productTypeState = GlobalKey();

  List<DataProductType> productTypes = [];
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final Map<int, AnimationController> _controllers =
      {}; // Map to store controllers per item
  final Map<int, Animation<Offset>> _animations =
      {}; // Map to store animations per item

  @override
  void initState() {
    super.initState();
    loadProductTypes();
  }
  //  void _refreshProductList() {
  //   if (_productTypeState.currentState != null) {
  //     _productTypeState.currentState!.loadProductTypes();
  //   }
  // }

  Future<void> loadProductTypes() async {
    final Service controller = Service();
    try {
      productTypes = await controller.get();
      setState(() {
        // Initialize AnimationControllers for each product type
        for (var productType in productTypes) {
          final controller = AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          );
          _controllers[productType.id!] = controller;
          _animations[productType.id!] =
              Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0))
                  .animate(controller);
        }
      });
    } catch (error) {
      UI.toast(text: 'No Data', isSuccess: false);
    }
  }

  void deleteProduct(DataProductType productType) async {
    final Service service = Service();
    try {
      // Try to delete the product, and if successful, remove it immediately
      bool isDeleted = await service.dalete(productType.id!);

      if (isDeleted) {
        // Remove from the local list immediately
        setState(() {
          productTypes.removeWhere((item) => item.id == productType.id);
          UI.toast(text: 'លុបCategoryបានដោយជោគជ័យ');
        });
      }
    } catch (error) {
      UI.toast(text: 'Error: $error', isSuccess: false);
    }
  }

  void toggleAnimation(int id) {
    final controller = _controllers[id];
    if (controller != null) {
      controller.isDismissed ? controller.forward() : controller.reverse();
    }
  }

  // Navigate to the CreateTypeProduct page and handle the result
  void _createNewProductType() async {
    final newProductType = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTypeProduct(
          onTypeCreated: loadProductTypes,
        ),
      ),
    );

    if (newProductType != null) {
      // Add the new product type to the list and initialize animations
      setState(() {
        productTypes.add(newProductType);

        final controller = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );
        _controllers[newProductType.id!] = controller;
        _animations[newProductType.id!] =
            Tween<Offset>(begin: Offset.zero, end: const Offset(-0.4, 0))
                .animate(controller);
      });

      UI.toast(text: 'CreateCategoryបានដោយជោគជ័យ');
    }
  }

  @override
  void dispose() {
    // Dispose of all the animation controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
        physics: const ClampingScrollPhysics(),
        controller: refreshController,
        enablePullDown: true,
        footer: const ClassicFooter(),
        header: const ClassicHeader(),
        onRefresh: () async {
          await loadProductTypes();
          refreshController.refreshCompleted();
        },
        onLoading: () async {
          await loadProductTypes();
          refreshController.loadComplete();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: productTypes.isNotEmpty
                  ? ListView.builder(
                      itemCount: productTypes.length,
                      itemBuilder: (context, index) {
                        var productType = productTypes[index];
                        return GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            if (details.primaryDelta! < -5) {
                              toggleAnimation(productType.id!);
                            } else if (details.primaryDelta! > 10) {
                              toggleAnimation(productType.id!);
                            }
                          },
                          child: Stack(
                            children: [
                              // Action buttons for edit and delete
                              Positioned.fill(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height:
                                          60, // Set the height manually to match ListTile
                                      width: 60,
                                      decoration: const BoxDecoration(
                                          color: Colors.blue),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white),
                                        onPressed: () async {
                                          // Open the update page and refresh the list on return if needed
                                          bool? result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateProductType(
                                                      itemId: productType.id,
                                                      itemName:
                                                          productType.name,
                                                      image: productType.image,
                                                    )),
                                          );
                                          if (result == true) {
                                            loadProductTypes();
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      height:
                                          60, // Set the height manually to match ListTile
                                      width: 60,
                                      decoration: const BoxDecoration(
                                          color: Colors.red),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.white),
                                        onPressed: () {
                                          deleteProduct(productType);
                                          _controllers[productType.id!]
                                              ?.reverse();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Product item
                              SlideTransition(
                                position: _animations[productType.id!]!,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade100,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8),
                                        leading: Image(
                                          height: 22,
                                          image: NetworkImage(
                                              "${productType.image}"),
                                        ),
                                        title: Text(
                                          productType.name ?? 'Category Name',
                                          style: GoogleFonts.kantumruyPro(),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Image(
                                              image: AssetImage(
                                                'assets/images/package2.png',
                                              ),
                                              height: 22,
                                            ),
                                            Text(
                                              '${productType.nOfProducts}',
                                              style: GoogleFonts.kantumruyPro(),
                                            ),
                                          ],
                                        ),
                                        onTap: () {},
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('No data available')),
            ),
          ],
        ),
      ),
    );
  }
}
