import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/components/show_bottom_sheet.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/paginate.dart';
import 'package:mobile/entity/model/transaction.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/sale/find_reciept/find_sale.dart';
import 'package:mobile/page/p5_admin/sale/service.dart';

import 'package:mobile/page/p5_admin/sale/view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../report/service.dart' as report;

class ListingTransaction extends StatefulWidget {
  const ListingTransaction({super.key});

  @override
  State<ListingTransaction> createState() => _ListingTransactionState();
}

class _ListingTransactionState extends State<ListingTransaction> {
  List<Transaction> items = [];
  Paginate<Transaction> paginateData = Paginate<Transaction>();
  RefreshController refreshController = RefreshController();
  TextEditingController receiptNumberController = TextEditingController();
  String? selectedCashier = "All"; // Track the selected cashier name
  bool isLoading = false;
  final services = report.Service();
  @override
  void initState() {
    super.initState();
    initFutureList();
  }

  @override
  void dispose() {
    receiptNumberController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  Future initFutureList() async {
    paginateData = await Service.get(paginateData);

    if (mounted) {
      setState(() {
        // Apply cashier filter after loading
        _filterTransactionsByCashier();
      });
    }
  }

  void _onDownloadPressed(context) async {
    String url = 'share/report/generate-sale-report';

    setState(() => isLoading = true);
    await services.downloadReceipt(
        // DateFormat('yyyy-MM-dd').format(startDate),
        // DateFormat('yyyy-MM-dd').format(endDate),
        '',
        '',
        context,
        url);
    setState(() => isLoading = false);
  }

  void _filterTransactionsByCashier() {
    setState(() {
      if (selectedCashier == "All") {
        items = paginateData.data ?? [];
      } else {
        items = paginateData.data
                ?.where((transaction) =>
                    transaction.cashier!.name == selectedCashier)
                .toList() ??
            [];
      }
    });
  }

  void _filterTransactionsByPlatform() {
    setState(() {
      if (selectedCashier == "All") {
        items = paginateData.data ?? [];
      } else {
        items = paginateData.data
                ?.where(
                    (transaction) => transaction.platform! == selectedCashier)
                .toList() ??
            [];
      }
    });
  }

  void _showBottom() {
    showCustomBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final cashierNames = paginateData.data
                ?.map((transaction) => transaction.cashier!.name)
                .toSet()
                .toList() ??
            [];
        cashierNames.insert(0, "All");

        return SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text("Cashier",
                          style: GoogleFonts.kantumruyPro(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cashierNames.length,
                  itemBuilder: (context, index) {
                    final cashierName = cashierNames[index];
                    return ListTile(
                      title: Text(
                        cashierName!,
                        style: GoogleFonts.kantumruyPro(fontSize: 14),
                      ),
                      trailing: Radio<String>(
                        value: cashierName,
                        groupValue: selectedCashier,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedCashier = value;
                              _filterTransactionsByCashier();
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
                const Divider(),
                CustomElevatedButton(
                  label: 'Done',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: HColors.primaryColor(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBottomByPlatform() {
    showCustomBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final platformNames = paginateData.data
                ?.map((transaction) => transaction.platform)
                .toSet()
                .toList() ??
            [];
        platformNames.insert(0, "All");

        return SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Text(
                        "Tool",
                        style: GoogleFonts.kantumruyPro(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: platformNames.length,
                  itemBuilder: (context, index) {
                    final platformName = platformNames[index];
                    return ListTile(
                      title: Text(
                        platformName!,
                        style: GoogleFonts.kantumruyPro(fontSize: 14),
                      ),
                      trailing: Radio<String>(
                        value: platformName,
                        groupValue: selectedCashier,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedCashier = value;
                              _filterTransactionsByPlatform();
                            });
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
                const Divider(),
                CustomElevatedButton(
                  label: 'Done',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: HColors.primaryColor(),
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
    double sumTotal = paginateData.data?.fold(0.0, (sum, item) {
          return sum! + (item.totalPrice ?? 0.0);
        }) ??
        0.0;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "Sale",
            style: GoogleFonts.kantumruyPro(
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey, height: 1.0),
          ),
          actions: [
            isLoading?UI.spinKit():
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: () {
                    _onDownloadPressed(context);
                  },
                  icon: const Icon(
                    Icons.download,
                    color: HColors.grey,
                  )),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _widget(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Total Sales',
                  style: GoogleFonts.kantumruyPro(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  sumTotal.toDollarCurrency(), // Display the total sum
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: HColors.green,
                  ),
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.grey.shade100,
              ),
              Expanded(
                child: SmartRefresher(
                  physics: const ClampingScrollPhysics(),
                  controller: refreshController,
                  enablePullDown: true,
                  enablePullUp: paginateData.lastPage != null &&
                          paginateData.currentPage != null
                      ? paginateData.lastPage! > paginateData.currentPage!
                      : false,
                  footer: const ClassicFooter(),
                  header: const ClassicHeader(),
                  onRefresh: () async {
                    paginateData.currentPage = 1;
                    await initFutureList();
                    refreshController.refreshCompleted();
                  },
                  onLoading: () async {
                    if (paginateData.currentPage != null) {
                      paginateData.currentPage = paginateData.currentPage! + 1;
                    }
                    await initFutureList();
                    refreshController.loadComplete();
                  },
                  child: items.isNotEmpty
                      ? ListView(
                          children: items.map((e) {
                            double totalPrice = e.totalPrice ?? 0.0;
                            final pro = e.details!.length;

                            return Dismissible(
                              key: Key(e.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) {
                                setState(() {
                                  paginateData.data!.remove(e);
                                });
                                final service = Service();
                                service.dalete(e.id!);
                              },
                              child: InkWell(
                                onTap: () {
                                  Get.to(
                                    () => SalesDetailPage(
                                      totalPrice:
                                          e.totalPrice!.toDollarCurrency(),
                                      date: e.orderedAt,
                                      img: e.cashier!.avatar,
                                      cashier: e.cashier!.name,
                                      recieptNum: e.receiptNumber,
                                      code: pro,
                                      qty: e.details!.indexed,
                                      id: e.id,
                                    ),
                                    transition: Transition.downToUp,
                                    duration: const Duration(milliseconds: 350),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade100,
                                        width: 1,
                                      ),
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.receipt,
                                                            color: Colors.grey,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "#${e.receiptNumber!}"
                                                                    .toString(),
                                                                style: GoogleFonts
                                                                    .kantumruyPro(),
                                                              ),
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    (e.orderedAt ??
                                                                            "N/A")
                                                                        .toDateYYYYMMDD(),
                                                                    style: GoogleFonts.kantumruyPro(
                                                                        fontSize:
                                                                            11),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            totalPrice
                                                                .toDollarCurrency(),
                                                            style: GoogleFonts
                                                                .kantumruyPro(
                                                              color:
                                                                  HColors.green,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Stack(
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 16,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        '${e.cashier!.avatar}'),
                                                              ),
                                                              const Positioned(
                                                                bottom: 0,
                                                                right: 0,
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 8,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blueGrey,
                                                                  child: Icon(
                                                                    Icons
                                                                        .phone_android_sharp,
                                                                    size: 12,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : Center(
                          child: Text(
                            "No Data",
                            style: GoogleFonts.kantumruyPro(),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final icons = [
    Icons.filter_list,
    Icons.arrow_drop_down,
    Icons.arrow_drop_down
  ];
  final texts = ["", "Cashier", "Tool"];

  Widget _widget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      child: Row(
        children: [
          Wrap(
            direction: Axis.horizontal,
            children: List.generate(icons.length, (index) {
              return InkWell(
                onTap: () {
                  if (index == 1) {
                    _showBottom();
                  } else if (index == 2) {
                    // _showBottomCreator();
                    _showBottomByPlatform();
                  } else {
                    Get.to(
                      () => const FindReciept(),
                      transition: Transition.downToUp,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        texts[index],
                        style: GoogleFonts.kantumruyPro(),
                      ),
                      Icon(icons[index]),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
