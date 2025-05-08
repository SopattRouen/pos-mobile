import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/page/p5_admin/report/cashier.dart';
import 'package:mobile/page/p5_admin/report/product.dart';
import 'package:mobile/page/p5_admin/report/reciept.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = [
      'assets/images/reciept.png',
      'assets/images/mdicash.png',
      'assets/images/mdipack.png',
    ];
    final text = [
      'Reciept',
      'Cashier',
      'Product',
    ];
    final pages = [
      const ReceiptDownload(),
      const CashierDownload(),
      const ProductDownload(),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          "Download sales report",
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: ListView.builder(
                itemCount: icons.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          index == 1 ? Colors.white : const Color(0xFFF4F4F5),
                    ),
                    child: ListTile(
                      onTap: () {
                        Get.to(
                          () => pages[index],
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 350,),
                        );
                      },
                      leading: Image(
                        height: 24,
                        image: AssetImage(icons[index]),
                      ),
                      title: Text(
                        text[index],
                        style: GoogleFonts.kantumruyPro(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
