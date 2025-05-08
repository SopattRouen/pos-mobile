import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/page/p3_auth/login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // SizedBox(
                            //   width: MediaQuery.of(context).size.width * 0.3,
                            //   height: MediaQuery.of(context).size.height * 0.2,
                            //   child: ImageFiltered(
                            //     imageFilter:
                            //         ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                            //     child: const Image(
                            //       image: AssetImage('asset/service.png'),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                // width: MediaQuery.of(context).size.width * 0.11,
                                // height: MediaQuery.of(context).size.height * 0.15,
                                child: Text("🇺🇸",style: TextStyle(fontSize: 28),)
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                        ),
                        SizedBox(
                          // width: MediaQuery.of(context).size.width * 0.4,
                          // height: MediaQuery.of(context).size.height * 0.3,
                          child: ImageFiltered(
                            imageFilter:
                                ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
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
                  ),
                  Positioned(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // const SizedBox(
                        //   height: 50,
                        // ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  height: 120,
                                  image:
                                      AssetImage('assets/logo/crosant.png'),
                                ),
                              ],
                            ),
                            Hero(
                              tag: 'hero-text',
                              createRectTween: (begin, end) {
                                return RectTween(begin: begin, end: end);
                              },
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  'USA CROISSANT',
                                  style: GoogleFonts.kantumruyPro(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: const Color.fromARGB(255, 187, 143, 11),
                                  ),
                                ),
                              ),
                            ),
                            // Text(
                            //   "",
                            //   style: GoogleFonts.kantumruyPro(
                            //     fontSize: 20,
                            //   ),
                            // ),
                            // Text(
                            //   "",
                            //   style: GoogleFonts.kantumruyPro(
                            //     fontSize: 20,
                            //   ),
                            // ),
                            // Text(
                            //   "",
                            //   style: GoogleFonts.kantumruyPro(
                            //     fontSize: 20,
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
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
                elevation: WidgetStateProperty.all(0), // Remove shadow
              ),
              onPressed: () {
                Get.to(() => const Login());
              },
              child: Text(
                "Welcome",
                style: GoogleFonts.kantumruyPro(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.kantumruyPro(
                    color: Colors.grey.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
