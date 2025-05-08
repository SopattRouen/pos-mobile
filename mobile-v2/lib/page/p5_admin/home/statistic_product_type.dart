
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
import 'package:mobile/components/pei_chart.dart'; // Ensure this path is correct
import 'package:mobile/components/show_bottom_sheet.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/statistic_product_type.dart';
import 'package:mobile/page/p5_admin/home/service.dart';

class ProductTypeStats extends StatefulWidget {
  final Function(DateTime, DateTime) onUpdate;

  const ProductTypeStats({Key? key, required this.onUpdate}) : super(key: key);

  @override
  _ProductTypeStatsState createState() => _ProductTypeStatsState();
}

class _ProductTypeStatsState extends State<ProductTypeStats> {
  int selectedIndex = 0;
  late Future<StatisticProductType> future; // Initialize future
  final Service service = Service();
  final List<String> title = ['This Week', 'This Month', '3 Month Ago', '6 Month Ago'];
 @override
  void initState() {
    super.initState();
    // Initialize the future with the default selection
    future = service.fetchProductTypeStatistics(title[selectedIndex]);
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
      future = service.fetchProductTypeStatistics(period);
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
                  'Statistic Category',
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: _show,
                    child: Row(
                      children: [
                        Text(title[selectedIndex], style: GoogleFonts.kantumruyPro()),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          FutureBuilder<StatisticProductType>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('No Data',style: GoogleFonts.kantumruyPro(),));
              } else {
                return Donut(period: title[selectedIndex], data: snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }
}

class Donut extends StatefulWidget {
  final String period;
  final StatisticProductType data;

  const Donut({super.key, required this.period, required this.data});

  @override
  DonutState createState() => DonutState();
}

class DonutState extends State<Donut> {
  late Service statisticService;
  List<DonutPieData> data = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    statisticService = Service();
    updateData(widget.period);
  }

  void fetchData(String period) async {
    try {
      var stats = await statisticService.fetchProductTypeStatistics(period);
      setState(() {
        data = List.generate(
          stats.labels!.length,
          (index) => DonutPieData(
            stats.labels![index],
            stats.data![index],
            _getColor(index),
          ),
        );
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        // Consider using Flutter Toast or Snackbars to notify user of the error visually
        print('Failed to fetch product type statistics: $e');
      });
    }
  }

  @override
  void didUpdateWidget(Donut oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  Color _getColor(int index) {
    final double hue = (index * 137.5) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.6).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return DonutPie(
      data: data,
      title: 'Product Types',
    );
  }
}

class Indicator extends StatelessWidget {
  final bool isActive;
  const Indicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: isActive ? 12.0 : 8.0,
      height: isActive ? 12.0 : 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? HColors.primaryColor() : Colors.black,
      ),
    );
  }
}
