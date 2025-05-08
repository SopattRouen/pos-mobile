import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/product/product/update.dart';
import 'package:mobile/page/p5_admin/user/view.dart';

class ViewDetailProduct extends StatefulWidget {
  final String images;
  final String name;
  final double price;
  final String type;
  final String code;
  final String date;
  final int id;
  final int typeId;
  const ViewDetailProduct(
      {super.key,
      required this.images,
      required this.name,
      required this.price,
      required this.type,
      required this.code,
      required this.date,
      required this.id, required this.typeId});

  @override
  State<ViewDetailProduct> createState() => _ViewDetailProductState();
}

class _ViewDetailProductState extends State<ViewDetailProduct>with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        
      });
    }

    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.name,
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF0C7EA5),
            labelColor: const Color(0xFF0C7EA5),
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'Sale'),
            ],
          ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: [
            DetailWidget(widget: widget),
            const CaashierViewListTransaction(),
          ],
        ),
    );
  }
}

class DetailWidget extends StatefulWidget {
  const DetailWidget({
    super.key,
    required this.widget,
  });

  final ViewDetailProduct widget;

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15,),
          Center(
            child: Stack(
              children: [
                Card(
                  color: Colors.grey[200],
                  elevation: 0,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  //   side: BorderSide(color: Colors.grey.shade200),
                  // ),
                  child: Image.network(
                    height: mainHeight * 0.2,
                    widget.widget.images,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: ()async {
                         bool? updated = await Get.to(() => UpdateProduct(
                itemId: widget.widget.id,
                itemName: widget.widget.name,
                price: widget.widget.price.toString(),
                image: widget.widget.images,
                code: widget.widget.code,
                type: widget.widget.type,
                typeId: widget.widget.typeId,
              ));
              if (updated != null && updated) {
                setState(() {});  // Refresh the UI to reflect the updated data
              }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Card(
              color: Colors.white,
              elevation: 2,
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(10),
              //   side: BorderSide(color: Colors.grey.shade200),
              // ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.drive_file_rename_outline_sharp,color: HColors.grey,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('Name',style: Fonts.regular(),)
                            ],
                          ),
                          Text(
                            widget.widget.name,
                            style: Fonts.regular()
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.tag,color: HColors.grey,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('Code',style:Fonts.regular(),)
                            ],
                          ),
                          Text(
                            widget.widget.code,
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                              // color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.dashboard,color: HColors.grey,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('Category',style: Fonts.regular(),)
                            ],
                          ),
                          Text(
                            widget.widget.type,
                            style: Fonts.regular()
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.discount,color: HColors.grey,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('Price',style:Fonts.regular(),)
                            ],
                          ),
                          Text(
                            widget.widget.price.toDouble().toDollarCurrency(),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                              // color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,color: HColors.grey,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('Date',style:Fonts.regular(),)
                            ],
                          ),
                          Text(
                            widget.widget.date.toDateYYYYMMDD(),
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                              // color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
