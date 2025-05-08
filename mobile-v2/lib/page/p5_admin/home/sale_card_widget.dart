import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/show_bottom_sheet.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/helper/date_chooser.dart';
import 'package:mobile/entity/model/dashboard.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/home/service.dart';

class SalesCardWidget extends StatefulWidget {
  @override
  _SalesCardWidgetState createState() => _SalesCardWidgetState();
}

class _SalesCardWidgetState extends State<SalesCardWidget> {
  int selectedIndex =
      0; // State to keep track of the selected index in the bottom sheet
  late Future<Dashboard> futureDashboard;
  final Service service = Service();

  // Date period titles and start dates
  final List<String> title = ['Today', 'Yesterday', 'This Week'];
  final List<DateTime Function()> start = [
    () => getStartDate('Today'),
    () => getStartDate('Yesterday'),
    () => getStartDate('This Week'),
    // () => getStartDate('This Month'),
    // () => getStartDate('3 Month Ago'),
    // () => getStartDate('6 Month Ago')
  ];

  @override
  void initState() {
    super.initState();
    updateDataRange(
        DateTime.now(), title[selectedIndex]); // Fetch dashboard data on init
  }

  // Update dashboard data based on selected date
  void updateDataRange(DateTime date, String period) {
    setState(() {
      futureDashboard = service.fetchDashboard(period);
    });
  }

  // Show the custom bottom sheet for date selection
  void _show() {
    showCustomBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: title.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Image(
                height: 22,
                image: AssetImage(dateIcons[index]),
              ),
              title: Text(
                title[index],
                style: GoogleFonts.kantumruyPro(),
              ),
              trailing: selectedIndex == index
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                // Update dashboard data with selected date range
                updateDataRange(DateTime.now(), title[index]);
                setState(() {
                  selectedIndex = index; // Update selected index
                });
                Navigator.pop(context); // Close the bottom sheet
              },
            );
          },
        );
      },
    );
  }

  Widget buildSalesCard(Dashboard dashboard) {
    final total = dashboard.statatics?.total ?? 0;
    final totalPercentageIncrease =
        dashboard.statatics?.totalPercentageIncrease ?? 0;
    final saleIncreasePreviousDay =
        dashboard.statatics?.saleIncreasePreviousDay ?? '';

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sale', style: GoogleFonts.kantumruyPro(fontSize: 18)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: _show,
                            child: Text(title[selectedIndex],
                                style: GoogleFonts.kantumruyPro()),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: _show,
                            child: const Icon(Icons.calendar_today_rounded,
                                size: 16, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  total.toDouble().toDollarCurrency(),
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF008000),
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Increase',
                      style: GoogleFonts.kantumruyPro(fontSize: 14),
                    ),
                    Text(
                      ' ${totalPercentageIncrease.toStringAsFixed(2)}% (${(double.tryParse(saleIncreasePreviousDay) ?? 0).toStringAsFixed(2)})',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 14,
                        color: const Color(0xFF008000),
                      ),
                    ),
                    Text(
                      'Compared to yesterday',
                      style: GoogleFonts.kantumruyPro(fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Dashboard>(
      future: futureDashboard,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: UI.spinKit());
        } else if (snapshot.hasError) {
          return const Text('No Data');
        } else {
          return buildSalesCard(snapshot.data!);
        }
      },
    );
  }
}
