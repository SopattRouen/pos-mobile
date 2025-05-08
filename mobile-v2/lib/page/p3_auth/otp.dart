import 'dart:async';
import 'dart:ui';
import 'package:excellent_loading/excellent_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/enum/e_ui.dart';

import 'package:mobile/entity/helper/form.dart';

import 'package:mobile/entity/model/user.dart';
import 'package:mobile/page/p3_auth/service.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

class OtpInputForm extends StatefulWidget {
  final String phone;

  const OtpInputForm({super.key, required this.phone});

  @override
  _OtpInputFormState createState() => _OtpInputFormState();
}

class _OtpInputFormState extends State<OtpInputForm> {
  final GlobalKey<OtpPinFieldState> _otpPinFieldController =
      GlobalKey<OtpPinFieldState>();

  String _enteredOtp = '';
  late Timer _timer;
  int start = 60;
  final AuthService service = AuthService();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void verifyOtp() async {
    print(
        'Verifying OTP: $_enteredOtp for phone: ${widget.phone}'); // Debug log
    if (_enteredOtp.length == 6) {
      ExcellentLoading.show();
      User user = User(
        phone: widget.phone.trim(),
        password: _enteredOtp.trim(),
      );
      print('Sending phone: ${user.phone}, password: ${user.password}');

      service.login(
        username: widget.phone.trim(),
        password: _enteredOtp.trim(),
      );

      // print('Received token: ${token.success}, message: ${token.message}');

      ExcellentLoading.dismiss();
      // UI.toast(
      //   text: "Success",
      // );
      // if (token.success!) {
      //   UI.toast(
      //     text: "Success",
      //   );
      //   // ignore: use_build_context_synchronously
      //   Get.offAll(() => const Dashboard());
      // } else {
      //   UI.toast(
      //     text: token.message!,
      //     isSuccess: false,
      //   );
      // }
    } else {
      UI.toast(text: 'Please fill in all required fields', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  const HeaderWidget(),
                  Positioned(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      'USA CROISSANT',
                                      style: GoogleFonts.kantumruyPro(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0C7EA5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 35,
                                child: Text(
                                  "🇺🇸",
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.10),
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Image(
                              height: 50,
                              width: 50,
                              fit: BoxFit.contain,
                              image: AssetImage('assets/images/otp.png'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Verify Your Account",
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Check your inbox",
                              style: GoogleFonts.kantumruyPro(fontSize: 14),
                            ),
                            Text(
                              widget.phone,
                              style: GoogleFonts.kantumruyPro(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        OtpPinField(
                          key: _otpPinFieldController,
                          autoFillEnable: false,
                          fieldHeight: 45,
                          fieldWidth: 45,
                          textInputAction: TextInputAction.done,
                          highlightBorder: true,
                          cursorWidth: 2,
                          mainAxisAlignment: MainAxisAlignment.center,
                          otpPinFieldDecoration: OtpPinFieldDecoration.custom,
                          maxLength: 6,
                          showCursor: true,
                          keyboardType: TextInputType.number,
                          cursorColor: const Color(0xFF0C7EA5),
                          onSubmit: (text) {
                            setState(() {
                              _enteredOtp = text;
                            });
                            verifyOtp();
                          },
                          onChange: (text) {
                            setState(() {
                              _enteredOtp = text;
                            });
                          },
                          onCodeChanged: (code) {},
                          otpPinFieldStyle: OtpPinFieldStyle(
                            defaultFieldBackgroundColor: Colors.grey.shade100,
                            defaultFieldBorderColor: Colors.black,
                            activeFieldBorderColor: const Color(0xFF0C7EA5),
                            fieldBorderRadius: 8,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Time Out : ',
                                    style: GoogleFonts.kantumruyPro(
                                        fontSize: 14, color: Colors.red),
                                  ),
                                  Text(
                                    '$start',
                                    style: GoogleFonts.kantumruyPro(
                                        fontSize: 14, color: Colors.red),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  // Add functionality to resend OTP here
                                },
                                child: Text(
                                  'Send​ OTP Again',
                                  style: GoogleFonts.kantumruyPro(
                                    fontSize: 14,
                                    color: const Color(0xFF0C7EA5),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xFF0C7EA5),
                              ),
                              fixedSize: WidgetStateProperty.all(
                                Size(MediaQuery.of(context).size.width, 50),
                              ),
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: verifyOtp,
                            // child: AuthService().isLoading.value
                            //     ? const CircularProgressIndicator()
                            //     :
                            child: Text(
                              "Verify",
                              style: GoogleFonts.kantumruyPro(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                  height: 1,
                                ),
                              ),
                              Text(
                                'OR',
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(
                              () => Password(phone: widget.phone),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.black),
                              ),
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                child: Text(
                                  'Login By Password',
                                  style: GoogleFonts.kantumruyPro(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Version 1.0.0​',
                                style: GoogleFonts.kantumruyPro(
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width * 0.3,
                  //   height: MediaQuery.of(context).size.height * 0.2,
                  //   child: ImageFiltered(
                  //     imageFilter: ImageFilter.blur(sigmaX: 0.7, sigmaY: 0.4),
                  //     child: const Image(
                  //       image: AssetImage('assets/images/service-item.png'),
                  //     ),
                  //   ),
                  // ),
                  // const Positioned(
                  //   right: 25,
                  //   top: 55,
                  //   child:
                  // )
                ],
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
          ),
          SizedBox(
            // width: MediaQuery.of(context).size.width * 0.4,
            // height: MediaQuery.of(context).size.height * 0.3,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: const Opacity(
                opacity: 0.2,
                child: Image(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/Kbach.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Password extends StatefulWidget {
  final String phone;

  const Password({super.key, required this.phone});

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  final formCon = FormInput();
  bool isFilled = false;
  bool isHidePwd = false;
  final AuthService service = AuthService();

  onTextChange() {
    if (formCon.txtPass.text.length >= 6) {
      isFilled = true;
    } else {
      isFilled = false;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    userName.addListener(onTextChange);
    formCon.txtPass.addListener(onTextChange);
  }

  @override
  void dispose() {
    userName.dispose();
    formCon.txtPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  const HeaderWidget(),
                  Positioned(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      'USA CROISSANT',
                                      style: GoogleFonts.kantumruyPro(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF0C7EA5)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 35,
                                child: Text(
                                  "🇺🇸",
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Image(
                              height: 50,
                              width: 50,
                              fit: BoxFit.contain,
                              image: AssetImage('assets/images/otp.png'),
                            ),
                          ),
                        ),
                        // const SizedBox(height: 8),
                        Text(
                          "Verify Account",
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 8),
                                child: Center(
                                  child: Text(
                                    "Please enter the password created with the account",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.kantumruyPro(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(
                              //   height: 8,
                              // ),
                              Text(
                                widget.phone,
                                style: GoogleFonts.kantumruyPro(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        //  SizedBox(
                        //   height: MediaQuery.of(context).size.height * 0.01,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(25),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Form(
                              key: formCon.passkey,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  // You can add additional validation if needed
                                  return null;
                                },
                                controller: formCon.txtPass,
                                obscureText: true,
                                decoration: InputDecoration(
                                  label: Text(
                                    'Passsword*',
                                    style: GoogleFonts.kantumruyPro(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.23,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xFF0C7EA5),
                              ),
                              fixedSize: WidgetStateProperty.all(
                                Size(MediaQuery.of(context).size.width, 50),
                              ),
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (formCon.passkey.currentState!.validate()) {
                                if (isFilled) {
                                  ExcellentLoading.show();
                                  User user = User(
                                    phone: widget.phone.trim(),
                                    password: formCon.txtPass.text.trim(),
                                  );
                                  print(
                                      'Sending phone: ${user.phone}, password: ${user.password}');

                                  service.login(
                                    username: widget.phone.trim(),
                                    password: formCon.txtPass.text.trim(),
                                  );
                                  // print(
                                  //     'Received token: ${token.success}, message: ${token.message}');

                                  ExcellentLoading.dismiss();

                                  // if (token.success!) {
                                  //   UI.toast(
                                  //     text: "Success",
                                  //   );
                                  //   // ignore: use_build_context_synchronously
                                  //   Get.offAll(
                                  //     () => const DashboardView(),
                                  //   );
                                  // } else {
                                  //   UI.toast(
                                  //     text: token.message!,
                                  //     isSuccess: false,
                                  //   );
                                  // }
                                } else {
                                  UI.toast(
                                      text: 'Please enter password',
                                      isSuccess: false);
                                }
                              } else {
                                return;
                              }
                            },
                            // child: AuthService().isLoading.value
                            //     ? const CircularProgressIndicator()
                            //     :
                            // onPressed: () {
                            //   service.login(
                            //       username: widget.phone.trim(), password: password.text.trim());
                            // },
                            child: Text(
                              "Verify",
                              style: GoogleFonts.kantumruyPro(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Version 1.0.0​',
                                style: GoogleFonts.kantumruyPro(
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
