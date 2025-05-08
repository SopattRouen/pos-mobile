import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/sale/service.dart';
import 'package:mobile/page/p6_cashier/sale/view.dart';

class SalesDetailPage extends StatefulWidget {
  const SalesDetailPage(
      {super.key,
      this.totalPrice,
      this.date,
      this.cashier,
      this.img,
      this.code,
      this.qty,
      this.name,
      this.recieptNum,
      this.id});
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
  State<SalesDetailPage> createState() => _SalesDetailPageState();
}

class _SalesDetailPageState extends State<SalesDetailPage> {
  final service= Service() ;
  bool isLoading = false;
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
                fontSize: 18,
              
              ),
            ),
            Text(
              "#${widget.recieptNum} .",
              style: GoogleFonts.kantumruyPro(
                fontSize: 18,fontWeight: FontWeight.w500
              ),
            ),
            const Icon(Icons.phone_android_rounded)
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
                        "${widget.totalPrice}",
                        style: GoogleFonts.kantumruyPro(
                          color: Colors.green,
                          fontSize: 16,
                        
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

  void _onDownloadPressed() async {
    setState(() => isLoading = true);
    await service. downloadReceipt(
      widget.recieptNum,
      context,
    );
    setState(() => isLoading = false);
  }
}
