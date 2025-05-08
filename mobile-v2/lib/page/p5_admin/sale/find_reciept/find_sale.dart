// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mobile/components/show_bottom_sheet.dart';
// import 'package:mobile/entity/helper/colors.dart';

// // Define enum for radio button selection
// enum SingingCharacter { phone, computer }

// class FindReciept extends StatefulWidget {
//   const FindReciept({super.key});

//   @override
//   State<FindReciept> createState() => _FindRecieptState();
// }

// class _FindRecieptState extends State<FindReciept> {
//   final txtWord = TextEditingController();
//   final txtDate = TextEditingController();
//   final txtRole = TextEditingController();
//   final formKey = GlobalKey<FormState>(); // One form key for all fields

//   SingingCharacter? _character = SingingCharacter.phone;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         scrolledUnderElevation: 0,
//         leading: InkWell(
//           onTap: () {
//             Get.back();
//           },
//           child: const Icon(Icons.close),
//         ),
//         title: Text(
//           "Search Reciept",
//           style: GoogleFonts.kantumruyPro(
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           TextButton(
//             onPressed: () {
//               if (formKey.currentState!.validate()) {
//                 // Perform search action
//               }
//             },
//             child: Text(
//               "Search ",
//               style: GoogleFonts.kantumruyPro(),
//             ),
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Form(
//             key: formKey, // Assign the form key
//             child: Column(
//               children: [
//                 TextFormField(
//                   style: GoogleFonts.kantumruyPro(),
//                   controller: txtWord,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'សូមបញ្ចូលKeyword';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     label: const Text("Keyword"),
//                     labelStyle: GoogleFonts.kantumruyPro(),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 TextFormField(
//                   style: GoogleFonts.kantumruyPro(),
//                   controller: txtDate,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'សូមជ្រើសរើសDate';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     label: const Text("Date"),
//                     labelStyle: GoogleFonts.kantumruyPro(),
//                     suffixIcon: GestureDetector(onTap:(){
//                       showCustomBottomSheet(
//                               context: context,
//                               builder: (context) {
//                                 int selectedIndex = 0;
//                                 return ListView.builder(
//                                   shrinkWrap: true,
//                                   itemCount: calendar.length,
//                                   itemBuilder: (context, index) {
//                                     return ListTile(
//                                       leading: Image(
//                                         height: 24,
//                                         image: AssetImage(calendar[index]),
//                                       ),
//                                       title: Text(
//                                         title[index],
//                                         style: GoogleFonts.kantumruyPro(),
//                                       ),
//                                       trailing: selectedIndex == index
//                                           ? const Icon(Icons.check,
//                                               color: Colors
//                                                   .green) // Show check icon if selected
//                                           : null,
//                                       onTap: () {
//                                         setState(() {
//                                           selectedIndex =
//                                               index; // Update selected index
//                                         });

//                                         Navigator.pop(
//                                             context); // Close the bottom sheet

//                                         // if (index == 5) {
//                                         //   Navigator.push(
//                                         //     context,
//                                         //     MaterialPageRoute(
//                                         //       builder: (context) => DateChooser(),
//                                         //     ),
//                                         //   );
//                                         // } else {
//                                         //   print(
//                                         //       'No page available for this index');
//                                         // }
//                                       },
//                                     );
//                                   },
//                                 );
//                               },
//                             );
//                     }, child: const Icon(Icons.arrow_drop_down)),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 TextFormField(
//                   style: GoogleFonts.kantumruyPro(),
//                   controller: txtRole,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'សូមជ្រើសរើសCashier';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     label: const Text("Cashier"),
//                     labelStyle: GoogleFonts.kantumruyPro(),
//                     suffixIcon: GestureDetector(onTap: (){

//                     },child: const Icon(Icons.arrow_drop_down)),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ListTile(
//                         title: Text(
//                           'តាមរយៈទូរស័ព្ទ',
//                           style: GoogleFonts.kantumruyPro(
//                             fontSize: 14,
//                           ),
//                         ),
//                         leading: Radio<SingingCharacter>(
//                           value: SingingCharacter.phone,
//                           groupValue: _character,
//                           onChanged: (SingingCharacter? value) {
//                             setState(() {
//                               _character = value;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                     Expanded(

//                       child: ListTile(
//                         title: Text(
//                           'តាមរយៈកុំព្យូទ័រ',
//                           style: GoogleFonts.kantumruyPro(
//                             fontSize: 14,
//                           ),
//                         ),
//                         leading: Radio<SingingCharacter>(
//                           value: SingingCharacter.computer,
//                           groupValue: _character,
//                           onChanged: (SingingCharacter? value) {
//                             setState(() {
//                               _character = value;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mobile/entity/model/transaction.dart';
// import 'package:mobile/page/p5_admin/sale/service.dart';

// enum SingingCharacter { phone, computer }

// class FindReciept extends StatefulWidget {
//   const FindReciept({super.key});

//   @override
//   State<FindReciept> createState() => _FindRecieptState();
// }

// class _FindRecieptState extends State<FindReciept> {
//   final txtWord = TextEditingController();  // Assumes this captures the receipt number
//   final txtDate = TextEditingController();
//   final txtRole = TextEditingController();  // Assumes this captures the cashier ID
//   final formKey = GlobalKey<FormState>();

//   SingingCharacter? _character = SingingCharacter.phone;
//   List<Transaction> transactions = [];
//   bool isLoading = false;

//   void searchTransactions() async {
//     if (formKey.currentState!.validate()) {
//       setState(() {
//         isLoading = true;
//       });
//       try {
//         transactions = await Service.getSearch(
//           receiptNumber: int.tryParse(txtWord.text),
//           orderedAt: txtDate.text,
//           cashierId: int.tryParse(txtRole.text),
//           platform: _character == SingingCharacter.phone ? 'Phone' : 'Computer',
//         );
//         setState(() {
//           isLoading = false;
//         });
//       } catch (e) {
//         setState(() {
//           isLoading = false;
//         });
//         // Handle errors here
//         print('Error fetching transactions: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         scrolledUnderElevation: 0,
//         leading: InkWell(
//           onTap: () {
//             Get.back();
//           },
//           child: const Icon(Icons.close),
//         ),
//         title: Text(
//           "Search Reciept",
//           style: GoogleFonts.kantumruyPro(
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           TextButton(
//             onPressed: searchTransactions,
//             child: Text(
//               "Search ",
//               style: GoogleFonts.kantumruyPro(),
//             ),
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Form(
//             key: formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   style: GoogleFonts.kantumruyPro(),
//                   controller: txtWord,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'សូមបញ្ចូលKeyword';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     label: const Text("Keyword"),
//                     labelStyle: GoogleFonts.kantumruyPro(),
//                   ),
//                 ),
//                 // Additional fields...
//                 isLoading
//                   ? CircularProgressIndicator()
//                   : transactions.isNotEmpty
//                     ? ListView.builder(
//                         shrinkWrap: true,  // Use shrinkWrap to handle ListView in SingleChildScrollView
//                         physics: NeverScrollableScrollPhysics(),  // to disable scrolling within ListView
//                         itemCount: transactions.length,
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             title: Text(transactions[index].receiptNumber.toString()),
//                             subtitle: Text(transactions[index].platform ?? 'No platform'),
//                           );
//                         },
//                       )
//                     : Text("No transactions found"),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/model/transaction.dart';
import 'package:mobile/page/p5_admin/sale/service.dart';

enum SingingCharacter { none, phone, computer }

class FindReciept extends StatefulWidget {
  const FindReciept({super.key});

  @override
  State<FindReciept> createState() => _FindRecieptState();
}

class _FindRecieptState extends State<FindReciept> {
  final txtWord = TextEditingController();
  final txtDate = TextEditingController();
  final txtRole = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Transaction> transactions = [];
  bool isLoading = false;
  int currentPage = 1;
  bool hasMore = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    searchTransactions();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMore) {
        currentPage++;
        searchTransactions();
      }
    }
  }

  void searchTransactions() async {
    if (!isLoading) {
      setState(() => isLoading = true);

      // Build search parameters only if they have values
      int? receiptNumber = int.tryParse(txtWord.text);
      String? orderedAt = txtDate.text.isNotEmpty ? txtDate.text : null;
      int? cashierId = int.tryParse(txtRole.text);
      String? platform =
          _character == SingingCharacter.phone ? 'Mobile' : 'Web';

      List<Transaction> newTransactions = await Service.getSearch(
        receiptNumber: receiptNumber,
        orderedAt: orderedAt,
        cashierId: cashierId,
        platform: platform,
      );

      if (newTransactions.isNotEmpty) {
        setState(() {
          transactions = newTransactions; // Replace the list with new results
          hasMore =
              false; // Assume no pagination or all data is returned in one go
        });
      } else {
        setState(() {
          hasMore = false; // No more data to fetch
        });
      }

      setState(() => isLoading = false);
    }
  }

  void _handleRadioValueChange(SingingCharacter? value) {
    setState(() {
      if (_character == value) {
        // If the same button is clicked, deselect it
        _character = SingingCharacter.none;
      } else {
        _character = value;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  SingingCharacter? _character = SingingCharacter.phone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.close),
        ),
        title: Text(
          "Search Reciept",
          style: GoogleFonts.kantumruyPro(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: searchTransactions,
            icon:const Icon((Icons.search))
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: txtWord,
                  style: GoogleFonts.kantumruyPro(),
                  // validator: (value) => value == null || value.isEmpty ? 'សូមបញ្ចូលKeyword' : null,
                  decoration: InputDecoration(
                    label: const Text("Keyword"),
                    labelStyle: GoogleFonts.kantumruyPro(),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: txtDate,
                  style: GoogleFonts.kantumruyPro(),
                  // validator: (value) => value == null || value.isEmpty ? 'សូមជ្រើសរើសDate' : null,
                  decoration: InputDecoration(
                    label: const Text("Date"),
                    labelStyle: GoogleFonts.kantumruyPro(),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: txtRole,
                  style: GoogleFonts.kantumruyPro(),
                  // validator: (value) => value == null || value.isEmpty ? 'សូមជ្រើសរើសCashier' : null,
                  decoration: InputDecoration(
                    label: const Text("Cashier"),
                    labelStyle: GoogleFonts.kantumruyPro(),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('តាមរយៈទូរស័ព្ទ',
                            style: GoogleFonts.kantumruyPro(fontSize: 14)),
                        leading: Radio<SingingCharacter>(
                          value: SingingCharacter.phone,
                          groupValue: _character,
                          onChanged: _handleRadioValueChange,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('តាមរយៈកុំព្យូទ័រ',
                            style: GoogleFonts.kantumruyPro(fontSize: 14)),
                        leading: Radio<SingingCharacter>(
                          value: SingingCharacter.computer,
                          groupValue: _character,
                          onChanged: _handleRadioValueChange,
                        ),
                      ),
                    ),
                  ],
                ),
                if (transactions.isEmpty && !isLoading)
                   Center(child: Text("No Data.",style: GoogleFonts.kantumruyPro(),)),
                if (transactions.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions
                        .length, // Removed +1 as no loading indicator needed at the end
                    itemBuilder: (context, index) {
                      return ListTile(
                        // onTap: (){
                        //   Get.to(()=> SalesDetailPage(date: transactions[index].orderedAt,),id: transactions[index].id,);
                        // },
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            "${transactions[index].cashier!.avatar}",
                          ),
                        ),
                        title: Text(
                          "${transactions[index].cashier!.name}",
                          style: GoogleFonts.kantumruyPro(),
                        ),
                        subtitle: Text(
                          transactions[index].receiptNumber.toString(),
                          style: GoogleFonts.kantumruyPro(),
                        ),
                        trailing:
                            Text(transactions[index].platform ?? 'No platform'),
                      );
                    },
                  ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
       bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          CustomElevatedButton(label: "Search ", onPressed: searchTransactions,backgroundColor: HColors.primaryColor(),)
        ],
      ),
    );
    
  }
}
