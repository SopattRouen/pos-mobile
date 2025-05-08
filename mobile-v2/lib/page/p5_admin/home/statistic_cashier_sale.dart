

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/pei_chart.dart';
import 'package:mobile/components/show_bottom_sheet.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/helper/date_chooser.dart';
import 'package:mobile/entity/model/cashier.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/home/service.dart';

class CashierSection extends StatefulWidget {
  @override
  _CashierSectionState createState() => _CashierSectionState();
}

class _CashierSectionState extends State<CashierSection> {
  int selectedIndex = 0; // State variable to track the selected icon
  int _selectedIndex = 0;
  late Future<List<Cashier>> futureCashier;
  // DateTime startDate = DateTime.now();
  // DateTime endDate = DateTime.now();

  final Service service = Service();

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
    // futureCashier =
    //     service.fetchCashier(formatDate(startDate), formatDate(endDate));
    updateDataRange(DateTime.now(), title[selectedIndex]) ;// Fetch dashboard data on init
  }

  void updateDataRange(DateTime date, String period) {
    setState(() {
      futureCashier =
          service.fetchCashier(period);
    });
  }

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
              trailing: _selectedIndex == index
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                // Update dashboard data with selected date range
                updateDataRange(DateTime.now(), title[index]);
                setState(() {
                  _selectedIndex = index; // Update selected index
                });
                Navigator.pop(context); // Close the bottom sheet
              },
            );
          },
        );
      },
    );
  }

  // Function to set the selected index
  void _onIconTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Color _getColor(int index) {
    final double hue = (index * 137.5) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.6).toColor();
  }

  // Function to return the corresponding widget based on selected index
  Widget _getContentByIndex(int index) {
    switch (index) {
      case 0:
        return FutureBuilder<List<Cashier>>(
          future: futureCashier,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("No Data",style: GoogleFonts.kantumruyPro(),);
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return UI.spinKit();
              }
              return buildCashierList(snapshot.data!);
            }
            return UI.spinKit(); // Better for user feedback
          },
        );
      case 1:
        return FutureBuilder<List<Cashier>>(
          future: futureCashier,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              var pieData = snapshot.data!
                  .map((cashier) => DonutPieData(
                        '${cashier.name} (${NumberFormat.decimalPattern().format(cashier.totalAmount)})',
                        cashier.totalAmount!,
                        _getColor(snapshot.data!
                            .indexOf(cashier)), // Ensure unique colors
                      ))
                  .toList();
              return DonutPie(data: pieData, title: "Cashiers");
            }
            return UI.spinKit();
          },
        );
      case 2:
        return FutureBuilder<List<Cashier>>(
          future: futureCashier,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              var chartData = snapshot.data!
                  .map((cashier) => ChartData(
                        cashier.name!,
                        cashier.totalAmount!,
                      ))
                  .toList();
              return StatisticChat(data: chartData);
            }
            return UI.spinKit();
          },
        );
      default:
        return Text(
          "No Data",
          style: GoogleFonts.kantumruyPro(),
        );
    }
  }

  Widget buildCashierList(List<Cashier> cashiers) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cashiers.length,
      itemBuilder: (context, index) {
        var cashier = cashiers[index];
        var roleNames =
            cashier.roles?.map((role) => role.name).join(', ') ?? "No roles";
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            title: Text(
              cashier.name ?? "Unknown",
              style: GoogleFonts.kantumruyPro(),
            ),
            subtitle: Text(
              roleNames,
              style: GoogleFonts.kantumruyPro(fontSize: 11),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                  cashier.avatar ?? 'https://example.com/default-avatar.png'),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cashier.totalAmount!.toDollarCurrency(),
                  style: GoogleFonts.kantumruyPro(fontSize: 14),
                ),
                Text(
                  "(${cashier.percentageChange!.toDouble()}%)",
                  style: GoogleFonts.kantumruyPro(color: Colors.green),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cashier',
                  style: GoogleFonts.kantumruyPro(fontSize: 18),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.list,
                        color: selectedIndex == 0
                            ? HColors.primaryColor()
                            : const Color(0xFF64748B),
                      ),
                      onPressed: () => _onIconTap(0),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.pie_chart,
                        color: selectedIndex == 1
                            ? HColors.primaryColor()
                            : const Color(0xFF64748B),
                      ),
                      onPressed: () => _onIconTap(1),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.bar_chart,
                        color: selectedIndex == 2
                            ? HColors.primaryColor()
                            : const Color(0xFF64748B),
                      ),
                      onPressed: () => _onIconTap(2),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      _show();
                      
                    },
                    child: Row(
                      children: [
                        Text(title[_selectedIndex], style: GoogleFonts.kantumruyPro()),
                        const SizedBox(width: 5),
                        const Icon(Icons.calendar_today_rounded,
                            size: 16, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _getContentByIndex(selectedIndex),
        ],
      ),
    );
  }
}