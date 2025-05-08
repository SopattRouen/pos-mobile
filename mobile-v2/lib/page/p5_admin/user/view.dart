import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/extension/extension_method.dart';

import 'package:mobile/page/p5_admin/user/update.dart';
import 'package:mobile/page/p5_admin/user/controller/user_controller.dart';

import 'package:mobile/entity/enum/e_font.dart';
import 'package:mobile/entity/model/paginate.dart';
import 'package:mobile/entity/model/transaction.dart';
import 'package:mobile/page/p5_admin/user/service.dart';

import 'package:mobile/page/p6_cashier/sale/view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ViewUser extends StatefulWidget {
  final UserController userController = Get.put(UserController());
  ViewUser({
    super.key,
    required String name,
    required String email,
    required String phoneNumber,
    required String date,
    required String role,
    required int userId,
    required String profilePic,
  }) {
    // Initialize the controller with the provided values
    userController.updateUser(
      updatedName: name,
      updatedEmail: email,
      updatedPhoneNumber: phoneNumber,
      updatedDate: date,
      updatedRole: role,
      updatedProfilePic: profilePic,
      updatedUserId: userId,
    );
  }

  @override
  State<ViewUser> createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser>
    with SingleTickerProviderStateMixin {
  final UserController userController = Get.put(UserController());
  late TabController _tabController;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Account',
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF0C7EA5),
          labelColor: const Color(0xFF0C7EA5),
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Sale'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserWidget(userController: userController),
          const CaashierViewListTransaction(),
        ],
      ),
    );
  }
}

class UserWidget extends StatelessWidget {
  const UserWidget({
    super.key,
    required this.userController,
  });

  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(height: 32,),
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 55,
                        backgroundImage:
                            NetworkImage(userController.profilePic.value),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            // Navigate to UpdateUser and wait for results
                            await Get.to(
                                () => UpdateUser(
                                      avatar: userController.profilePic.value,
                                      email: userController.email.value,
                                      name: userController.name.value,
                                      phone: userController.phoneNumber.value,
                                      roleID: 2, // Assuming roleId is passed
                                      userID: userController.userId.value,
                                      date: userController.date.value,
                                    ),
                                transition: Transition.downToUp);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.blueGrey.shade100
                            ),
                            // child: const Image(
                            //   height: 18,
                            //   image: AssetImage('assets/images/edit.png'),
                            // ),
                            child: const Icon(Icons.create),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    userController.name.value,
                    style: GoogleFonts.kantumruyPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "${userController.role}",
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.phone_android_sharp),
                              const SizedBox(width: 8),
                              Text('Phone',style: GoogleFonts.kantumruyPro(),)
                            ],
                          ),
                          Text(
                            userController.phoneNumber.value,
                            style: GoogleFonts.kantumruyPro(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.email_outlined),
                              const SizedBox(width: 8),
                              Text('Email',style: GoogleFonts.kantumruyPro(),)
                            ],
                          ),
                          Text(
                            userController.email.value,
                            style: GoogleFonts.kantumruyPro(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined),
                              const SizedBox(width: 8),
                              Text('Date',style: GoogleFonts.kantumruyPro(),)
                            ],
                          ),
                          Text(
                            userController.date.value.toDateDMY(),
                            style: GoogleFonts.kantumruyPro(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CaashierViewListTransaction extends StatefulWidget {
  const CaashierViewListTransaction({super.key});

  @override
  State<CaashierViewListTransaction> createState() =>
      _CaashierViewListTransactionState();
}

class _CaashierViewListTransactionState
    extends State<CaashierViewListTransaction> {
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
    paginateData = await Service.getSales(paginateData);
    setState(() {});
  }

  Future searchInvoice() async {
    paginateData.currentPage = 1;
    paginateData.data!.clear();
    paginateData = await Service.getSales(paginateData,
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
        //
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Total Sales',
                    style: GoogleFonts.kantumruyPro(fontSize: 14),
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
                          fontSize: 20,
                          color: HColors.green,
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
                        paginateData.currentPage =
                            paginateData.currentPage! + 1;
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
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
                                  service.daleteSales(e.id!);
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
                                      duration:
                                          const Duration(milliseconds: 350),
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
                                                    width:
                                                        MediaQuery.of(context)
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
                                                              color:
                                                                  Colors.grey,
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
                                                                color: Colors
                                                                    .green,
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
      ),
    );
  }
}
