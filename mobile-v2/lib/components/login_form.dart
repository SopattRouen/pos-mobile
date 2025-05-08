import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/page/p3_auth/otp.dart';

form({required Function(String) onLogin, context}) {
  final phonekey = GlobalKey<FormState>();
  final phone = TextEditingController();
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(15),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: phonekey,
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'សូមបញ្ចូលPhone';
                }
                // You can add additional validation if needed
                return null;
              },
              controller: phone,
              decoration: InputDecoration(
                label: Text(
                  'Phone',
                  style: GoogleFonts.kantumruyPro(),
                ),
              ),
            ),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color(0xFF0C7EA5),
            ),
            fixedSize: WidgetStateProperty.all(
              const Size(400, 45),
            ),
            shape: WidgetStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          onPressed: () {
            if (phonekey.currentState!.validate()) {
              Get.to(
                () => OtpInputForm(phone: phone.text),
              );
            } else {
              // Show error message
              null;
            }
          },
          // child: Obx(
          //   () => auth.isLoading.value
          //       ? const CircularProgressIndicator()
          //       : const Text(
          //           "បន្ទាប់",
          //           style: TextStyle(fontSize: 18, color: Colors.white),
          //         ),
          // ),
          child: Text(
            "បន្ទាប់",
            style: GoogleFonts.kantumruyPro(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      
    ],
  );
}
