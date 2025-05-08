import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/enum/e_font.dart';
import 'package:mobile/entity/model/paginate.dart';
import 'package:mobile/entity/model/transaction.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p6_cashier/sale/service.dart';
import 'package:mobile/page/p6_cashier/sale/view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CashierListTransaction extends StatefulWidget {
  const CashierListTransaction({super.key});

  @override
  State<CashierListTransaction> createState() => _CashierListTransactionState();
}

class _CashierListTransactionState extends State<CashierListTransaction> {
  List<Transaction> items = [];
  Paginate<Transaction> paginateData = Paginate<Transaction>();
  RefreshController refreshController = RefreshController();
  TextEditingController receiptNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initFutureList();
  }

  Future initFutureList() async {
    paginateData = await Service.get(paginateData);
    setState(() {});
  }

  Future searchInvoice() async {
    paginateData.currentPage = 1;
    paginateData.data!.clear();
    paginateData = await Service.get(paginateData,
        param: "receipt_number=${receiptNumberController.text}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total sum of all transactions
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
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: InkWell(
          //       onTap: () {},
          //       child: Container(
          //         width: 35,
          //         height: 35,
          //         decoration: BoxDecoration(
          //           color: Colors.grey.shade100,
          //           borderRadius: BorderRadius.circular(50),
          //         ),
          //         child: const Icon(Icons.more_horiz),
          //       ),
          //     ),
          //   )
          // ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey, height: 1.0),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Total Sales',
                  style: GoogleFonts.kantumruyPro(fontSize: 18),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      sumTotal.toDollarCurrency(), // Display the total sum
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                   Divider(
                thickness: 1,
                color: Colors.grey.shade100,
              ),
                ],
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
                  child: paginateData.data != null &&
                          paginateData.data!.isNotEmpty
                      ? ListView(
                          children: paginateData.data!.map((e) {
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
                                    () => CashierSalesDetail(
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
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          // CircleAvatar(
                                                          //   radius: 12,
                                                          //   backgroundColor:
                                                          //       Colors.white,
                                                          //   backgroundImage:
                                                          //       NetworkImage(
                                                          //           '${e.cashier!.avatar}'),
                                                          // ),
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
                          child: EText(
                            text: "No Data",
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
}
