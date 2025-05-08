import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/helper/form.dart';
import 'package:mobile/page/p5_admin/user/service.dart';

class UpdatePassword extends StatelessWidget {
  const UpdatePassword({super.key, this.id});
  final id;

  @override
  Widget build(BuildContext context) {
    final controller = FormInput();
    Service service = Service();
    @override
    void handle() {
      final confirmPass = controller.txtConpass.text.trim();
      if (controller.txtConpass.text.trim().isEmpty) {
        UI.toast(text: 'សូមបញ្ចូលPasswordគ្រប់គ្រាន់', isSuccess: false);
      } else {
        service.updatePassword(id, confirmPass);
        UI.toast(text: "ការUpdatePasswordទទួលបានជោគជ័យ");
        Navigator.pop(context);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.close),
        ),
        title: Text(
          "Update Password",
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: handle,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(25),
            //   child: Form(
            //     key: controller.passkey,
            //     child: TextFormField(
            //       controller: controller.txtPass,
            //       decoration: const InputDecoration(
            //         label: Text(
            //           "Password",
            //           style: GoogleFonts.kantumruyPro(
            //
            //           ),
            //         ),
            //       ),
            //       validator: (value) {
            //         if ((value == null || value.isEmpty)) {
            //           return ("សូមបញ្ចូលPasswordយ៉ាងតិច៦ខ្ទង់");
            //         }
            //         return null;
            //       },
            //     ),
            //   ),
            // ),
            // Product Price Input
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.conpasskey,
                child: TextFormField(
                  controller: controller.txtConpass,
                  decoration: InputDecoration(
                    label: Text(
                      "ConfirmPassword",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return ("សូមConfirmពាក្យសម្ងាត់");
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Divider(), // Adds a divider at the top of the bottom navigation bar
          CustomElevatedButton(
            label: "Done", // Your button label
            onPressed:handle, // Your handler function
            backgroundColor: HColors.primaryColor(), // Your custom background color
          ),
        ],
      ),
    );
  }
}
