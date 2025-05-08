import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/detail.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/sale/service.dart'as admin;

import 'service.dart';


class CashierSalesDetail extends StatefulWidget {
  const CashierSalesDetail({
    super.key,
    this.totalPrice,
    this.date,
    this.cashier,
    this.img,
    this.code,
    this.qty,
    this.name,
    this.recieptNum,
    this.id,
  });
  final totalPrice;
  final date;
  final cashier;
  final img;
  final code;
  final qty;
  final name;
  final recieptNum;
  final id;

  @override
  State<CashierSalesDetail> createState() => _CashierSalesDetailState();
}


class _CashierSalesDetailState extends State<CashierSalesDetail> {
  bool isLoading = false;
   final service=admin. Service() ;
   void _onDownloadPressed() async {
    setState(() => isLoading = true);
    await service.downloadReceipt(
      widget.recieptNum,
      context,
    );
    setState(() => isLoading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Reciept Number ",
              style: GoogleFonts.kantumruyPro(
                fontSize: 16,
                
              ),
            ),
            Text(
              "#${widget.recieptNum}",
              style: GoogleFonts.kantumruyPro(
                fontSize: 16,
                
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.close)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
        ),
         actions: [
          isLoading?UI.spinKit():
          IconButton(
            onPressed:_onDownloadPressed,
            icon: const Icon(Icons.download,color: Colors.blueGrey,),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Sales",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${(widget.totalPrice)}",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 16,
                          color: HColors.green,
                          
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.date.toString().toDateDividerStandardMPWT(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cashier",
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Text(
                            "${widget.cashier}",
                            style: GoogleFonts.kantumruyPro(),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage("${widget.img}"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey[200],
            ),
            DetailSale(
              saleId: widget.id,
            ),
          ],
        ),
      ),
    );
  }
}

class DetailSale extends StatelessWidget {
  final int saleId;

  const DetailSale({
    super.key,
    required this.saleId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Details>?>(
      future: Service.view(saleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final saleDetailsList = snapshot.data;

          if (saleDetailsList == null || saleDetailsList.isEmpty) {
            return const Center(child: Text('No sale data found.'));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: saleDetailsList.length,
            itemBuilder: (context, index) {
              final saleDetails = saleDetailsList[index];
              final product = saleDetails.product;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  // decoration: BoxDecoration(
                                  //   // color: Colors.grey[200],
                                  //   borderRadius: BorderRadius.circular(10),
                                  // ),
                                  child: product?.image != null
                                      ? Image.network(
                                          height: 50,
                                          '${product!.image}', // Ensure correct image path
                                        )
                                      : const Icon(Icons.image_not_supported),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text(
                                      product?.name ?? "N/A",
                                      style: GoogleFonts.kantumruyPro(),
                                    ),
                                    Text(
                                      '${product?.type?.name} | ${product?.code ?? "N/A"}',
                                      style: GoogleFonts.kantumruyPro(
                                        color: Colors.blueGrey
                                      ),
                                    ),
                                   
                                    Text(
                                      saleDetails.unitPrice!
                                          .toDouble()
                                          .toDollarCurrency(),
                                      style: GoogleFonts.kantumruyPro(
                                        // color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'x ${saleDetails.qty}',
                                  style: GoogleFonts.kantumruyPro(),
                                ),
                                Text(
                                  (saleDetails.qty! * saleDetails.unitPrice!)
                                      .toDouble()
                                      .toDollarCurrency(),
                                  style: GoogleFonts.kantumruyPro(
                                    // color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey[200],
                  ),
                ],
              );
            },
          );
        }
        return const Center(child: Text('No data available.'));
      },
    );
  }
}
