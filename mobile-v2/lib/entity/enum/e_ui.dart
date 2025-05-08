
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/entity/enum/e_font.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/font.dart';

class UI{
  
  static toast({
    required String text,
    ToastGravity position = ToastGravity.TOP,
    bool isSuccess = true,
  }){
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: position,
      backgroundColor: isSuccess ? const Color.fromARGB(255, 116, 166, 118) : const Color.fromARGB(255, 201, 106, 99),
      textColor: Colors.white,
      fontSize: ESize.getDouble(EFontSize.medium) * mainWidth,
    );
  }

  static void showCupertinoChoice({
    required BuildContext context,
    required String title,
    required String text,
    required VoidCallback onConfirm,
    required Widget icon,
    String alertMessage = "សូមជ្រើសរើសខាងក្រោម",
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext coEText) => CupertinoActionSheet(
        title: Center(
          child: Column(
            children: [
              EText(
                text: title,
                size: EFontSize.medium,
              ),
              icon
            ],
          ),
        ),
        message: Center(
          child: EText(
            text: alertMessage,
            color: Colors.black,
            align: TextAlign.center,
            maxLines: 3,
          ),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EText(
                    text: text,
                    color: const Color(0xFF223bff),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.maybePop(coEText);
                onConfirm();
              }),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(coEText, 'Cancel');
          },
          child: EText(
            text: 'បោះបង់',
            color: const Color(0xffb64638),
          ),
        ),
      ),
    );
  }


  static Widget cachedNetworkImage({
    required String url,
    bool isFitFromImage = false,
    double width = 80,
    double height = 80,
    double? maxHeight,
    bool profile = false
  }) {
    if(isFitFromImage){
      return Container(
        constraints: BoxConstraints(
          minHeight: 200,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: CachedNetworkImage ( 
          imageUrl: url,  
          maxHeightDiskCache: 500, 
          fit: BoxFit.contain,
          errorWidget: (coEText, str, dynamic) {
            return profile ? getNoImageProfile() : getNoImage();
          },
          placeholder: (coEText, str) {
            return spinKit(
              size: 40
            );
          }, 
        ),
      );
    }else{
      return CachedNetworkImage( 
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (coEText, str, dynamic) {
        return profile ? getNoImageProfile() : getNoImage();
      },
      placeholder: (coEText, str) {
        return spinKit();
      },
      width: width,
      height: height,
    );
    }
  }

  static Widget getNoImageProfile() {
    return Icon(
      Icons.person,
      color: Colors.white,
      size: iconSize * 1.5,
    );
  }

  static Widget getNoImage() {
    return Image.asset(
      'images/noimage.jpg',
    );
  }

  static spinKit({double size = 20.0}){
    return SpinKitThreeBounce(
      color: appBarColor,
      size: size,
    );
  }
}