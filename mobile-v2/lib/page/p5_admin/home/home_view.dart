import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mobile/components/app_bar.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/cashier.dart';
import 'package:mobile/entity/model/dashboard.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/home/sale_card_widget.dart';
import 'package:mobile/page/p5_admin/home/service.dart';
import 'package:mobile/page/p5_admin/home/statistic_cashier_sale.dart';
import 'package:mobile/page/p5_admin/home/statistic_product_type.dart';
import 'package:mobile/page/p5_admin/home/statistic_sale_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Dashboard> futureDashboard;
  late Future<List<Cashier>> futureCashier;

  final Service service = Service();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    futureDashboard =
        service.fetchDashboard(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    // futureCashier = service.fetchCashier();
  }

  @override
  Widget build(BuildContext context) {
    //  var userProfile = userController.userprofile.value;
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Carousel Slider for both cards
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: false,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: true,
                      enlargeCenterPage: false,
                      autoPlayInterval: const Duration(seconds: 3),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: [
                      // First card widget: Sales Card
                      SalesCardWidget(),
                      // Second card widget: Dashboard grid from API data
                      buildDashboardGrid(),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          2,
                          (index) =>
                              Indicator(isActive: _currentIndex == index)),
                    ),
                  ),
                ],
              ),
            ),
            // Indicator for the Carousel Slider

            const SizedBox(height: 10),

            // Other widgets below the carousel...
            CashierSection(),
            const SizedBox(height: 10),
            // ProductTypeStats widget integration
            ProductTypeStats(
              onUpdate: (startDate, endDate) {
                DonutState? donut =
                    context.findAncestorStateOfType<DonutState>();
                if (donut != null) {
                  // Convert DateTime to String before passing it to updateData
                  String formattedStartDate =
                      DateFormat('yyyy-MM-dd').format(startDate);

                  donut.updateData(formattedStartDate); // Adjust this if needed
                } else {
                  print("DonutState not found in the tree");
                }
              },
            ),

            const SizedBox(height: 10),
            // buildSalesStats(context),

            // SalesStatsWidget(
            //   onUpdate: (week, year) {
            //     // Obtain ChartAppState and call updateData
            //     ?context.findAncestorStateOfType<ChartAppState>().updateData(week, year);
            //   },
            // ), // Widget for date selection
            SalesStatsWidget(
              onUpdate: (startDate, endDate) {
                // Find the ChartAppState and call updateData
                ChartAppState? chartAppState =
                    context.findAncestorStateOfType<ChartAppState>();
                if (chartAppState != null) {
                  String formattedStartDate =
                      DateFormat('yyyy-MM-dd').format(startDate);

                  chartAppState.updateData(formattedStartDate);
                } else {
                  print("ChartAppState not found in the tree");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDashboardGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(color: Colors.white),
      child: FutureBuilder<Dashboard>(
        future: futureDashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return createDashboardGrid(snapshot.data!.statatics);
            } else if (snapshot.hasError) {
              return const Text("Error loading dashboard data");
            }
          }
          return UI.spinKit();
        },
      ),
    );
  }
//   Widget buildDashboardGrid() {
//   return Container(
//     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//     width: MediaQuery.of(context).size.width,
//     decoration: const BoxDecoration(color: Colors.white),
//     child: FutureBuilder<ConnectivityResult>(
//       future: Connectivity().checkConnectivity(),
//       builder: (context, connectivitySnapshot) {
//         if (connectivitySnapshot.connectionState == ConnectionState.done) {
//           if (connectivitySnapshot.data != ConnectivityResult.none) {
//             // There's a network connection, proceed to check dashboard data
//             return FutureBuilder<Dashboard>(
//               future: futureDashboard,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   if (snapshot.hasData) {
//                     return createDashboardGrid(snapshot.data!.statatics);
//                   } else if (snapshot.hasError) {
//                     return const Text("Error loading dashboard data");
//                   }
//                 }
//                 // Show loading spinner when the connection is waiting or active
//                 return const CircularProgressIndicator();
//               },
//             );
//           } else {
//             // No internet connection, show reload button
//             return Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Attempt to reload the data
//                   setState(() {
//                     futureDashboard = getDashboardData(); // Make sure this matches your method to fetch data
//                   });
//                 },
//                 child: const Text('Reload'),
//               ),
//             );
//           }
//         }
//         // Before connectivity check completes, show a spinner
//         return const CircularProgressIndicator();
//       },
//     ),
//   );
// }

  Widget createDashboardGrid(Statistics? statatics) {
    final counts = [
      '${statatics?.totalProduct ?? "0"}',
      '${statatics?.totalProductType ?? "0"}',
      '${statatics?.totalUser ?? "0"}',
      '${statatics?.totalOrder ?? "0"}',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 2.2,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(
                        image: AssetImage(icons[index]),
                        height: 22,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            counts[index],
                            style: GoogleFonts.kantumruyPro(
                              fontSize: 18,
                            ),
                          ),
                          // EText(text: counts[index])
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    titles[index],
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
              style: GoogleFonts.kantumruyPro(
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              roleNames,
              style: GoogleFonts.kantumruyPro(fontSize: 11, color: Colors.grey),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                cashier.avatar ?? 'https://example.com/default-avatar.png',
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cashier.totalAmount!.toDollarCurrency(),
                  style: GoogleFonts.kantumruyPro(fontSize: 14),
                ),
                Text(
                  "(${cashier.percentageChange!.toDouble()})%", // Handle null case and format
                  style: GoogleFonts.kantumruyPro(
                    color: const Color(0xFF008000),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
