import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/http_field.dart';
import 'package:mobile/entity/helper/http_key.dart';
import 'package:mobile/entity/helper/http_method.dart';
import 'package:mobile/entity/model/order.dart';
import 'package:mobile/infrastracture.dart/e_http_class.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/page/p6_cashier/pos/recipt/reciept.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CartController extends GetxController {
  // RxMap for products (observable map)
  var products = <Products, int>{}.obs;
  var isLoading = true.obs; // Observable boolean
  var totalPrice = 0.0.obs; // Observable string for total price
  var receiptNumber = ''.obs; // Observable string for receipt number
  final List<ItemInfoData> _items = []; // List of items for the receipt

  // Getter for item list
  List<ItemInfoData> getItemList() => _items;

  // Add product to the cart and increase the quantity if the product exists
  void addProduct(Products product) {
    if (products.containsKey(product)) {
      products[product] = products[product]! + 1; // Increment the quantity
    } else {
      products[product] = 1; // Add a new product with a quantity of 1
    }
    _calculateTotalPrice(); // Recalculate total price
  }

  // Remove product or decrease quantity
  void removeProduct(Products product) {
    if (products.containsKey(product)) {
      if (products[product]! > 1) {
        products[product] = products[product]! - 1; // Decrease the quantity
      } else {
        products.remove(product); // Remove the product if quantity is 0
      }
      _calculateTotalPrice(); // Recalculate total price
    }
  }

  // Clear the cart
  void clearCart() {
    products.clear();
    _items.clear();
    _calculateTotalPrice(); // Reset the total price
  }

  // Calculate total price of all items in the cart
  void _calculateTotalPrice() {
    double total = 0;
    products.forEach((product, quantity) {
      total += (product.unitPrice ?? 0) * quantity;
    });
   totalPrice.value = double.parse(total.toStringAsFixed(2));

  }

  Future<void> processOrder() async {
    final box = GetStorage();

    // Create a cart map of product IDs and quantities
    final cartDetails =
        products.map((product, qty) => MapEntry(product.id!.toString(), qty));

    final mainPayload = {
      'cart': jsonEncode(cartDetails),
      'platform':'Mobile',
    };
    log("$cartDetails");
    log("$mainPayload");

    final url =
        Uri.parse('${mainUrlApi}cashier/ordering/order?cart=$mainPayload');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${box.read('token')}',
        },
        body: jsonEncode(mainPayload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading(false); // Set isLoading to false

        final responseBody = jsonDecode(response.body);
        final orderId = responseBody['data']['receipt_number'];
        final message = responseBody['message'];
        log("${orderId}");

        receiptNumber(orderId); // Update the receipt number
        _prepareReceiptItems(); // Prepare receipt items
        products.clear(); // Clear the cart

        // Request storage permission
        if (await _requestPermission(Permission.storage)) {
          var fileName = 'វិក្ក័យបត្រលេខ $orderId.pdf';
          await downloadAndSaveReceipt(
              mainUrlApi, orderId.toString(), fileName);
        } else {
          log("error");
        }

        log('Order Placed'
            'Your order has been placed successfully. Receipt: $orderId. $message');
      } else {
        log('Error' 'Failed to place order');
      }
    } catch (error) {
      log('Error' 'Failed to place order:$error');
      log("$error");
    }
  }

  Future<void> downloadAndSaveReceipt(
      String baseUrl, String orderId, String fileName) async {
    try {
      // Request storage permission
      if (!await _requestPermission(Permission.manageExternalStorage)) {
        log('Permission Denied: Storage permission is required to save the receipt');
        return;
      }

      // Make HTTP request to download the receipt
      Map<EHTTPField, dynamic> response = await EHTTP.httpRequest(
        uri: 'admin/sales/print/$orderId',
        bodyMap: {},
        method: EHTTPMethod.get,
        isHead: true,
      );

      if (response[EHTTPField.key] == EHTTPKey.responseOK) {
        final responseBody = response[EHTTPField.body] is String
            ? jsonDecode(response[EHTTPField.body])
            : response[EHTTPField.body];

        final base64String = responseBody['file_base64'];
        final bytes = base64.decode(base64String);

        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          log('Receipt saved: $filePath');
        } else {
          throw Exception('Failed to get storage directory');
        }
      } else {
        throw Exception('Failed to download receipt');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  // Prepare list of items for the receipt
  void _prepareReceiptItems() {
    _items.clear(); // Clear previous items
    products.forEach((product, quantity) {
      _items.add(ItemInfoData(
        name: product.name ?? '',
        quantity: quantity,
        price: (product.unitPrice ?? 0).toString(),
      ));
    });
  }
}
