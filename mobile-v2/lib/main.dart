import 'package:excellent_loading/excellent_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/entity/enum/e_user_preference.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/page/p4_account/service.dart';
import 'package:mobile/page/p6_cashier/pos/controller/cart_controller.dart';
import 'package:mobile/page/p1_splash/splashscreen.dart';
import 'package:mobile/page/p2_welcome/welcome.dart';
import 'package:mobile/services/service_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await UserPreferences.init();
  // Initialize GetX controllers before starting the app
  Get.put(ServiceController());
  Get.put(CartController());
  Get.put(AccountService());

  // await Firebase.initializeApp().then((_) {
  //   log('ok');   
  // });

  // User? userPrefs = await UserPreferences.getUser(); 
  // print("Token: ${userPrefs?.token}");
  // print("Token: ${userPrefs!.token}");
  final GetStorage box = GetStorage();
  final bool hasToken = box.hasData('token');

  // Determine the initial screen based on token
  Widget initialScreen =
      hasToken ? const SplashScreen() : const WelcomeScreen();
  ExcellentLoading.instance
    ..status = "Proceed"
    ..maskType = ExcellentLoadingMaskType.custom
    // ..indicatorType = ExcellentLoadingIndicatorType
    ..indicatorWidget = SizedBox(
      width: 70,
      height: 40,
      child: Center(
        child: SpinKitThreeBounce(
          color: appBarColor,
          size: 20.0,
        ),
      ),
    )
    ..backgroundColor = Colors.white
    ..loadingStyle = ExcellentLoadingStyle.custom
    ..indicatorColor = Colors.black
    ..textColor = Colors.black
    ..boxShadow = []
    ..maskColor = Colors.black.withOpacity(0.3)
    ..textStyle = GoogleFonts.kantumruyPro(
      color: Colors.black,
    );
  runApp(MyApp(
    initialScreen: initialScreen,
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: ExcellentLoading.init(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch:  Color(0xFF0C7EA5),

        textTheme:TextTheme(
          headlineLarge: GoogleFonts.kantumruyPro(fontSize: 24,fontWeight: FontWeight.w400)
        ) ,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C7EA5),
        ),
        useMaterial3: true,
      ),
      home: initialScreen,
       initialRoute: '/',
      // routes: {
      //   '/': (context) => HomePage(),           // Default or home route
      //   '/settings': (context) => SettingsPage(),
      //   '/details': (context) => DetailsPage(),
      // },
    );
  }
}
