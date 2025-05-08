import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:mobile/entity/model/user.dart';

User userPrefs = User();

Color appBarColor = Colors.grey;

String passwordMatch = "";
// String mainUrlApi = "http://localhost:8000/api";
// String mainUrlApi = "http://127.0.0.1:8002/api/";
// String mainUrlApi    =   "http://192.168.152.138:8000/api/";
// String mainUrlFile = "http://127.0.0.1:8003/";
String mainUrlFile = "https://file-v4-api.uat.camcyber.com/";
String mainUrlApi = "https://api.usa-croissant.shop/api/";
// String mainUrlFile = "https://pos-v2-file.uat.camcyber.com/";
// String mainUrlApi = "https://pos-v2-api.uat.camcyber.com/api/";
// String mainUrlApi = "https://api.sophat123.online/api/";
// String mainUrlFile = "https://file.sophat123.online/";
double iconSize = 30;

double mainWidth = 0;
double mainHeight = 0;
double textBoxHeight = 0.16;
double textboxPadding = 0.030;
double wPaddingAll = 0.025;
double iPadSize = 1;
bool isOffline = false;
bool isIpad = Device.get().isTablet;
