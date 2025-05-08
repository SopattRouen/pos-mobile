import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/pei_chart.dart';
import 'package:mobile/components/show_bottom_sheet.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/statistic_sale.dart';
import 'package:mobile/page/p5_admin/home/service.dart';

class ChartApp extends StatefulWidget {
  final String period;

  const ChartApp({Key? key, required this.period,})
      : super(key: key);

  @override
  ChartAppState createState() => ChartAppState();
}

class ChartAppState extends State<ChartApp> {
  List<ChartData> data = [];
  bool isLoading = false;

  @override
  void didUpdateWidget(ChartApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if startDate or endDate has changed
    if (oldWidget.period != widget.period) {
      updateData(widget.period);
    }
  }

  void updateData(String period) {
    setState(() {
      isLoading = true;
    });
    fetchData(period);
  }

  @override
  void initState() {
    super.initState();
    updateData(widget.period);
  }

  void fetchData(String period) async {
    try {
      var stats = await Service()
          .fetchSaleStatistics(period);
      setState(() {
        data = stats.labels != null && stats.labels!.isNotEmpty
            ? List.generate(
                stats.labels!.length,
                (index) => ChartData(
                    stats.labels![index], stats.data![index].toDouble()),
              )
            : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        // Consider using Flutter Toast or Snackbars to notify user of the error visually
        print('Failed to fetch sales statistics: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? UI.spinKit()
        : data.isNotEmpty
            ? StatisticChat(data: data)
            : Text(
                "No Data",
                style: GoogleFonts.kantumruyPro(),
              );
  }
}

class SalesStatsWidget extends StatefulWidget {
  final Function(DateTime, DateTime) onUpdate;

  const SalesStatsWidget({Key? key, required this.onUpdate}) : super(key: key);

  @override
  _SalesStatsWidgetState createState() => _SalesStatsWidgetState();
}

class _SalesStatsWidgetState extends State<SalesStatsWidget> {
  int selectedIndex = 0;
  late Future<StatisticSales> future; // Initialize future
  final Service service = Service();
  final List<String> title = ['This Week', 'This Month', '3 Month Ago', '6 Month Ago'];
  @override
  void initState() {
    super.initState();
    // Initialize the future with the default selection
    future = service.fetchSaleStatistics(title[selectedIndex]);
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
                image: AssetImage(dateIconsType[index]),
              ),
              title: Text(
                title[index],
                style: GoogleFonts.kantumruyPro(),
              ),
              trailing: selectedIndex == index
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                updateData(title[index]);
                setState(() {
                  selectedIndex = index;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
  void updateData(String period) {
    setState(() {
      future = service.fetchSaleStatistics(period);
      // Here you may want to call widget.onUpdate with the appropriate date range if necessary
    });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Sale Statistic',
                  style: GoogleFonts.kantumruyPro(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
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
                        Text(title[selectedIndex],
                            style: GoogleFonts.kantumruyPro()),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            _show();
                          },
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Pass startDate and endDate to ChartApp here with UniqueKey to force rebuild
          ChartApp(
            key: UniqueKey(), period:title[selectedIndex] , // Rebuilds ChartApp with each date update
            
          ),
        ],
      ),
    );
  }

  // Widget buildDateSelectionBottomSheet(BuildContext context) {
  //   return SizedBox(
  //     height: MediaQuery.of(context).size.height * 0.4,
  //     child: Padding(
  //       padding: const EdgeInsets.all(10),
  //       child: ListView.builder(
  //         itemCount: title.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           return ListTile(
  //             leading: const Icon(Icons.date_range),
  //             title: Text(title[index], style: GoogleFonts.kantumruyPro()),
  //             trailing: selectedIndex == index
  //                 ? const Icon(Icons.check, color: Colors.green)
  //                 : null,
  //             onTap: () {
  //               Navigator.pop(context);
  //               DateTime newStartDate = getStartDate(title[index]);
  //               DateTime newEndDate = getEndDate(title[index]);
  //               setState(() {
  //                 startDate = newStartDate;
  //                 endDate = newEndDate;
  //                 selectedIndex = index;
  //               });
  //               widget.onUpdate(
  //                   newStartDate, newEndDate); // Optional for other uses
  //             },
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
}

class DateUtils {
  // Function to calculate the ISO week number
  static int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = getWeekNumber(DateTime(date.year - 1, 12, 31));
    } else if (woy == 53 && (DateTime(date.year, 12, 31).weekday < 4)) {
      woy = 1;
    }
    return woy;
  }

  // Format the date for API as week and year
  static Map<String, String> formatWeekYear(DateTime date) {
    return {
      'week': getWeekNumber(date).toString(),
      'year': date.year.toString(),
    };
  }
}
