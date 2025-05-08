import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/page/p5_admin/dashboard/dashboard_view.dart';

class SplashScreen extends StatefulWidget {
  // final Widget nextPage;
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> logoAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    logoAnimation = Tween<double>(begin: 0, end: 600).animate(controller);
    controller.forward();
    Future.delayed(const Duration(seconds: 1), () {
      logoAnimation = Tween<double>(begin: 600, end: 0).animate(controller);
      controller.forward();
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardView(),
            ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mainWidth = MediaQuery.of(context).size.width;
    mainHeight = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
        animation: logoAnimation,
        builder: (context, widget) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.all(80),
                      width: logoAnimation.value,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: AssetImage('assets/logo/crosant.png'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:mobile/page/dashboard/dashboard_view.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(
//       const Duration(seconds: 3),
//       () => Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) {
//             return const DashboardView();
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/logo/crosant.png'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
