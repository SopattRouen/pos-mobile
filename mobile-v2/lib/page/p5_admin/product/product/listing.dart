import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/components/show_bottom_sheet.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/product.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/product/product/create.dart';
import 'package:mobile/page/p5_admin/product/product/delete.dart';
import 'package:mobile/page/p5_admin/product/product/find.dart';
import 'package:mobile/page/p5_admin/product/product/service.dart';
import 'package:mobile/page/p5_admin/product/product/view.dart';
import 'package:mobile/page/p5_admin/product/type/create.dart';
import 'package:mobile/page/p5_admin/product/type/listing.dart';
class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final GlobalKey<ProductViewState> _productViewState = GlobalKey();
  final GlobalKey<ProductTypeState> productTypeKey = GlobalKey();
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController?.addListener(() {
      setState(() {}); // Trigger rebuild when the tab index changes
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _refreshProductList() {
    if (_productViewState.currentState != null) {
      _productViewState.currentState!.fetchProducts();
    }
  }
  void _handleDownload() async {
    setState(() {
      isDownloading = true;
    });
    try {
      await Service().downloadReceipt(context);
      // Optionally handle a success case, such as showing a message
    } catch (e) {
      print("Download error: $e");
      // Optionally handle an error case
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  final icon = [Icons.add, Icons.download];
  final text = ['Create', 'Download'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Product",
          style: GoogleFonts.kantumruyPro(fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0C7EA5),
          labelColor: const Color(0xFF0C7EA5),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Category'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProductView(key: _productViewState),
          ProductType(
            key: productTypeKey,
          ),
        ],
      ),
      floatingActionButton: _tabController?.index == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0C7EA5),
               onPressed: isDownloading
            ? null // Disable the button while downloading
            : () {
                if (_tabController!.index == 1) {
                  Get.to(
                    () => CreateTypeProduct(
                      onTypeCreated: productTypeKey.currentState!.loadProductTypes,
                    ),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 350),
                  );
                } else {
                  showCustomBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
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
                                    () => CreateProduct(onProductCreated: _refreshProductList),
                                    transition: Transition.downToUp,
                                    duration: const Duration(milliseconds: 350),
                                  );
                                } else {
                                  _handleDownload();
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
        child: isDownloading
            ? UI.spinKit() // Show loading indicator when downloading
            : const Icon(Icons.more_horiz, color: Colors.white),
            )
          : FloatingActionButton(
              backgroundColor: const Color(0xFF0C7EA5),
              onPressed: () {
                Get.to(
                  () => CreateTypeProduct(
                    onTypeCreated:
                        productTypeKey.currentState!.loadProductTypes,
                  ),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 350),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
    );
  }
}
class ProductView extends StatefulWidget {
  const ProductView({Key? key}) : super(key: key);

  @override
  State<ProductView> createState() => ProductViewState();
}
class ProductViewState extends State<ProductView> {
  List<ProductData> products = [];
  List<Creator> create = [];
  List<ProductData> filteredProducts = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedProductType = 'All'; // Track selected product type
  String selectedCreator = 'All'; // Track selected creator

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
  setState(() {
    isLoading = true;
    hasError = false;
  });

  try {
    var productData = await Service.get();
    setState(() {
      products = productData.data ?? [];
      filteredProducts = products; // Start with all products shown

      // Populate the unique creators list
      create = products
          .map((product) => product.creator!)
          // ignore: unnecessary_null_comparison
          .where((creator) => creator !=null)
          .toSet()
          .toList();
      
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
      hasError = true;
    });
    print('Error fetching products: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: UI.spinKit());
    } else if (hasError) {
      return Center(child: UI.spinKit());
    } else {
      return buildContent(filteredProducts);
    }
  }

  Widget buildContent(List<ProductData> products) {
    return Column(
      children: [
        _widget(),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return SwipeableActionCard(
                product: product,
                onDelete: () {
                  setState(() {
                    filteredProducts.removeWhere((p) => p.id == product.id);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  final icons = [Icons.filter_list, Icons.arrow_drop_down, Icons.arrow_drop_down];
  final texts = ["", "Category", "Data Entry"];

  Widget _widget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          Wrap(
            direction: Axis.horizontal,
            children: List.generate(icons.length, (index) {
              return InkWell(
                onTap: () {
                  if (index == 1) {
                    _showBottom();
                  } else if (index == 2) {
                    _showBottomCreator();
                  } else {
                    Get.to(
                      () => const FindProduct(),
                      transition: Transition.downToUp,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25),
                  ),
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

  void _showBottom() {
    showCustomBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final productTypes = products.map((p) => p.type?.name ?? 'Unknown').toSet().toList();
        productTypes.insert(0, 'All'); // Insert "All" at the beginning

        return SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text("Category", style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: productTypes.length,
                  itemBuilder: (context, index) {
                    final productType = productTypes[index];
                    return ListTile(
                      title: Text(
                        productType,
                        style: GoogleFonts.kantumruyPro(fontSize: 14),
                      ),
                      trailing: Radio<String>(
                        value: productType,
                        groupValue: selectedProductType,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedProductType = value;
                              _filterProductsByType();
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomElevatedButton(
                    label: 'Done',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: HColors.primaryColor(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBottomCreator() {
    showCustomBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final creatorNames = create.map((c) => c.name ?? 'Unknown').toSet().toList();
        creatorNames.insert(0, 'All'); // Insert "All" at the beginning

        return SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text("Data Entry", style: GoogleFonts.kantumruyPro(fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: creatorNames.length,
                  itemBuilder: (context, index) {
                    final creator = creatorNames[index];
                    return ListTile(
                      title: Text(
                        creator,
                        style: GoogleFonts.kantumruyPro(fontSize: 14),
                      ),
                      trailing: Radio<String>(
                        value: creator,
                        groupValue: selectedCreator,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedCreator = value;
                              _filterProductsByCreator();
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomElevatedButton(
                    label: 'Done',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: HColors.primaryColor(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _filterProductsByType() {
    setState(() {
      if (selectedProductType == 'All') {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) => product.type?.name == selectedProductType).toList();
      }
    });
  }

  void _filterProductsByCreator() {
    setState(() {
      if (selectedCreator == 'All') {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) => product.creator?.name == selectedCreator).toList();
      }
    });
  }
}




class SwipeableActionCard extends StatefulWidget {
  final ProductData product;
  final Function onDelete;

  const SwipeableActionCard(
      {Key? key, required this.product, required this.onDelete})
      : super(key: key);

  @override
  _SwipeableActionCardState createState() => _SwipeableActionCardState();
}

class _SwipeableActionCardState extends State<SwipeableActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() =>
      _controller.isDismissed ? _controller.forward() : _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta! < -5) {
          _controller.forward();
        } else if (details.primaryDelta! > 10) {
          _controller.reverse();
        }
      },
      onTap: toggle,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  // Ensure this height matches the ListTile height
                  decoration: const BoxDecoration(color: Color(0xFFFF0001)),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () {
                      deleteProduct(widget.product.id!, widget.onDelete);
                      _controller.reverse();
                    },
                  ),
                ),
              ],
            ),
          ),
          SlideTransition(
            position:
                Tween<Offset>(begin: Offset.zero, end: const Offset(-0.2, 0))
                    .animate(_animation),
            child: InkWell(
              onTap: () {
                Get.to(
                  () => ViewDetailProduct(
                    typeId: widget.product.type!.id!,
                    id: widget.product.id!,
                    images: widget.product.image!,
                    name: widget.product.name!,
                    price: widget.product.unitPrice!,
                    type: widget.product.type!.name!,
                    code: widget.product.code!,
                    date: widget.product.createdAt!,
                  ),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 350),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    // height: 80,  // Set the same height here
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color:
                              Colors.grey.shade300, // Apply the color you need
                          width: 1, // Adjust the thickness of the border
                        ),
                      ),
                    ),

                    child: ListTile(
                      leading: Image.network(
                        widget.product.image ?? '',
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Image.network(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsHXrNDG5sDJWiLkS9g0GL7c_MPiFumwwFPhv9uNRu4eULdJJIQQtaPqfQt3o7QbRCTfE&usqp=CAU',
                          );
                        },
                        width: 60,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name ?? 'Unknown Product',
                            style: GoogleFonts.kantumruyPro(),
                          ),
                          Text(
                            "${widget.product.type!.name} | ${widget.product.code}",
                            style: GoogleFonts.kantumruyPro(
                                fontSize: 12, color: HColors.grey),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        widget.product.unitPrice!.toDouble().toDollarCurrency(),
                        style: GoogleFonts.kantumruyPro(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
