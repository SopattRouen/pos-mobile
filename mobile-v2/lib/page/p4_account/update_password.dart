import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/floating_button.dart';
import 'package:mobile/entity/enum/e_ui.dart';
import 'package:mobile/entity/helper/colors.dart';
import 'package:mobile/entity/helper/form.dart';
import 'package:mobile/services/service_controller.dart';

class UpdatePasswordProfile extends StatelessWidget {
  const UpdatePasswordProfile({super.key, this.id});
  final id;

  @override
  Widget build(BuildContext context) {
    final controller = FormInput();
    ServiceController service = ServiceController();
    void _handleSubmit() {
      final confirmPass = controller.txtConpass.text.trim();
      final pass = controller.txtPass.text.trim();
      if (controller.txtConpass.text.trim().isEmpty) {
        UI.toast(text: 'សូមបញ្ចូលPasswordគ្រប់គ្រាន់', isSuccess: false);
      } else {
        service.updatePasswordProfile(pass, confirmPass);
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
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: controller.passkey,
                child: TextFormField(
                  controller: controller.txtPass,
                  decoration: InputDecoration(
                    label: Text(
                      "Password",
                      style: GoogleFonts.kantumruyPro(),
                    ),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return ("សូមបញ្ចូលPasswordយ៉ាងតិច៦ខ្ទង់");
                    }
                    return null;
                  },
                ),
              ),
            ),
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
      floatingActionButton: CustomElevatedButton(
        label: 'Done',
        onPressed: _handleSubmit,
        backgroundColor: HColors.primaryColor(),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
