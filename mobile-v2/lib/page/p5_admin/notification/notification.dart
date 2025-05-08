import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/model/notification.dart';
import 'package:mobile/extension/extension_method.dart';
import 'package:mobile/page/p5_admin/notification/service.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late Future<NotificationS> notification;
  late Service service;
  List<NotificationData> notifications = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    service = Service();
    fetchNotifications(); // Fetch initial data
    // Set up a timer to fetch data every 5 seconds (or any other interval)
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => fetchNotifications());
  }

  // Fetch notifications and update the state
  void fetchNotifications() async {
    try {
      NotificationS fetchedNotifications = await service.getNotification();
      setState(() {
        notifications =
            fetchedNotifications.data ?? []; // Update the notification list
      });
    } catch (e) {
      UI.spinKit();
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Group notifications by orderedAt date and sort them by latest first
  Map<String, List<NotificationData>> groupNotificationsByDate(
      List<NotificationData> notifications) {
    Map<String, List<NotificationData>> groupedNotifications = {};

    // Sort the notifications by 'orderedAt' in descending order (latest first)
    notifications.sort((a, b) =>
        DateTime.parse(b.orderedAt!).compareTo(DateTime.parse(a.orderedAt!)));

    for (var notification in notifications) {
      // Parse and format the date as 'dd MMM yyyy' (e.g., '07 Oct 2024')
      String formattedDate = DateFormat('dd MMM yyyy')
          .format(DateTime.parse(notification.orderedAt!));

      // If the group for this date doesn't exist, create it
      if (groupedNotifications[formattedDate] == null) {
        groupedNotifications[formattedDate] = [];
      }

      // Add the notification to the group for that date
      groupedNotifications[formattedDate]!.add(notification);
    }

    return groupedNotifications;
  }

  @override
  Widget build(BuildContext context) {
// Function to format the date and group notifications by date

    // Group notifications by orderedAt date
    Map<String, List<NotificationData>> groupedNotifications =
        groupNotificationsByDate(notifications);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Notification',
          style: GoogleFonts.kantumruyPro(
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "No Data",
                style: GoogleFonts.kantumruyPro(),
              ),
            ) // Display if empty
          : SingleChildScrollView(
              child: Column(
                children: groupedNotifications.entries.map((entry) {
                  // entry.key is the formatted date (e.g., '07 Oct 2024')
                  // entry.value is the list of notifications for that date
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the date header
                      Container(
                        width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.height * 0.05,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            entry.key, // Display the grouped date
                            style: GoogleFonts.kantumruyPro(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Display the list of notifications for this date
                      ...entry.value.map((notification) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(
                                          notification.cashier?.avatar ??
                                              "assets/images/avatar.png", // Default avatar
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "#${notification.receiptNumber}",
                                            style: GoogleFonts.kantumruyPro(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            notification.orderedAt!
                                                .toDateDividerStandardMPWT(),
                                            style: GoogleFonts.kantumruyPro(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "${notification.cashier!.name} has ordered ${notification.totalPrice!.toDouble().toDollarCurrency()}",
                                    style: GoogleFonts.kantumruyPro(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
