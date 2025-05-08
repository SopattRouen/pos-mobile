import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/product.dart';
import 'package:mobile/page/p5_admin/product/product/service.dart';

class FindProduct extends StatefulWidget {
  const FindProduct({super.key});

  @override
  State<FindProduct> createState() => _FindProductState();
}

class _FindProductState extends State<FindProduct> {
  final txtWord = TextEditingController();
  final txtDate = TextEditingController();
  final txtRole = TextEditingController();
  final txttype = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<ProductData> filteredProducts = [];
  bool isLoading = false;
  bool hasSearched = false; // Track if a search has been performed

  void searchProducts() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        hasSearched = true; // Mark that a search has been triggered
      });

      try {
        // Fetch products data
        List<ProductData> allProducts = await Service.getSearch();

        // Filter products based on the entered keyword in txtWord
        String keyword = txtWord.text.toLowerCase();
        filteredProducts = allProducts.where((product) {
          return product.name!.toLowerCase().contains(keyword);
        }).toList();

        // Further filtering based on date and role (optional)
        String dateFilter = txtDate.text;
        String roleFilter = txtRole.text;

        if (dateFilter.isNotEmpty) {
          // Assuming there's a method to filter by date, adjust as necessary
          filteredProducts = filteredProducts.where((product) {
            return product.createdAt == dateFilter; // Adjust property as needed
          }).toList();
        }

        if (roleFilter.isNotEmpty) {
          // Assuming there's a method to filter by role, adjust as necessary
          filteredProducts = filteredProducts.where((product) {
            return product.creator!.name ==
                roleFilter; // Adjust property as needed
          }).toList();
        }

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          filteredProducts = []; // Clear results on error
        });
        // print('Error fetching products: $e');
      }
    }
  }

  @override
  void dispose() {
    txtWord.dispose();
    txtDate.dispose();
    txtRole.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.close),
        ),
        title: Text(
          "Search",
          style: GoogleFonts.kantumruyPro(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: searchProducts,
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: txtWord,
                  style: GoogleFonts.kantumruyPro(),
                  decoration: InputDecoration(
                    label: const Text("Keyword"),
                    labelStyle: GoogleFonts.kantumruyPro(),
                    suffixIcon: txtWord.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              txtWord.clear(); // Clear the search input
                              filteredProducts
                                  .clear(); // Clear the search results
                              hasSearched = false; // Reset search state
                              setState(
                                  () {}); // Trigger a rebuild to update suffix icon visibility
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: txtDate,
                  style: GoogleFonts.kantumruyPro(),
                  decoration: InputDecoration(
                    label: const Text("Date"),
                    labelStyle: GoogleFonts.kantumruyPro(),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: txttype,
                  style: GoogleFonts.kantumruyPro(),
                  decoration: InputDecoration(
                    label: const Text("Category"),
                    labelStyle: GoogleFonts.kantumruyPro(),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 25),
                // Keeping this field for additional input
                TextFormField(
                  controller: txtRole,
                  style: GoogleFonts.kantumruyPro(),
                  decoration: InputDecoration(
                    label: const Text("Data Entry"),
                    labelStyle: GoogleFonts.kantumruyPro(),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 25),

                // Display search results only if a search has been made
                if (hasSearched && filteredProducts.isEmpty && !isLoading)
                  Center(
                      child: Text(
                    "No Data",
                    style: GoogleFonts.kantumruyPro(),
                  )),
                if (filteredProducts.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            "${filteredProducts[index].image}", // Assuming ProductData has imageUrl
                          ),
                        ),
                        title: Text(
                          filteredProducts[index].name!,
                          style: GoogleFonts.kantumruyPro(),
                        ),
                        // subtitle: Text(
                        //   filteredProducts[index].description ?? '',
                        //   style: GoogleFonts.kantumruyPro(),
                        // ),
                        trailing:
                            Text(filteredProducts[index].unitPrice.toString()),
                      );
                    },
                  ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomElevatedButton(
              label: "Search",
              onPressed: searchProducts,
              backgroundColor: HColors.primaryColor(),
            ),
          ),
        ],
      ),
    );
  }
}
