
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/floating_button.dart';

import 'package:mobile/entity/enum/e_ui.dart';

import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/helper/date_chooser.dart';
import 'package:mobile/page/p5_admin/report/service.dart';

import 'package:intl/intl.dart';
import 'package:mobile/components/show_bottom_sheet.dart'; // Ensure this path is correct

class ReceiptDownload extends StatefulWidget {
  const ReceiptDownload({super.key});

  @override
  _ReceiptDownloadState createState() => _ReceiptDownloadState();
}

class _ReceiptDownloadState extends State<ReceiptDownload> {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final services =Service();
  int selectedIndex = -1;
  bool isLoading = false;
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(Icons.close)),
        title: Text('Downloadរបាយការណ៍លក់',
            style: GoogleFonts.kantumruyPro(fontSize: 18)),
        centerTitle: true,
        actions: [
          isLoading
              ? UI.spinKit()
              : IconButton(
                  onPressed: _onDownloadPressed,
                  icon: const Icon(Icons.download),
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
                  controller: controller,
                  style: GoogleFonts.kantumruyPro(),
                  validator: (value) => value == null || value.isEmpty
                      ? 'សូមជ្រើសរើសDate'
                      : null,
                  decoration: InputDecoration(
                    label: Text('Date', style: GoogleFonts.kantumruyPro()),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () => showCustomBottomSheet(
                        context: context,
                        builder: _buildBottomSheet,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          CustomElevatedButton(label: "Download", onPressed: _onDownloadPressed,backgroundColor: HColors.primaryColor(),),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: title.length,
          itemBuilder: (context, index) {
            DateTime startDate = getStartDate(title[index]);
            DateTime endDate = getEndDate(title[index]);
            return ListTile(
              leading: Image.asset(calendar[index], height: 24),
              title: Text(title[index], style: GoogleFonts.kantumruyPro()),
              trailing: selectedIndex == index
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  controller.text =
                      formatDates(title[index], startDate, endDate);
                });
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  void _onDownloadPressed() async {
    String url='share/report/sale';
    if (!formKey.currentState!.validate()) return;
    DateTime startDate = getStartDate(title[selectedIndex]);
    DateTime endDate = getEndDate(title[selectedIndex]);
    setState(() => isLoading = true);
    await services. downloadReceipt(
      DateFormat('yyyy-MM-dd').format(startDate),
      DateFormat('yyyy-MM-dd').format(endDate),
      context,
      url
    );
    setState(() => isLoading = false);
  }

  
}
