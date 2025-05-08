
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/font.dart';

//////////////////
///Font Size Enumeration for using with stylishtext


class ESize {
  ESize();

  static double getDouble(EFontSize size) {
    switch (size) {
      case EFontSize.medium:
        return 0.044 * (isIpad ? iPadSize * 0.7 : iPadSize); //font 50
      case EFontSize.large:
        return 0.053 * (isIpad ? iPadSize * 0.5 : iPadSize); //font 60
      case EFontSize.extraLarge:
        return 0.071 * (isIpad ? iPadSize * 0.7 : iPadSize); //font 80
      case EFontSize.small:
        return 0.035 * (isIpad ? iPadSize * 0.5 : iPadSize); //font 40
      case EFontSize.verySmall:
        return 0.027 * (isIpad ? iPadSize * 0.5 : iPadSize); //font 30
      /// for invoice
      case EFontSize.title:
        return 22 ;
      case EFontSize.header:
        return 20 ;
      case EFontSize.content:
        return 18 ;
      case EFontSize.footer:
        return 16 ;
      /// for AppBar
      case EFontSize.mediumPx:
        return 16.5 * (isIpad ? iPadSize * 1.5 : iPadSize); //font 50

      case EFontSize.largePx:
        return 19.8 * (isIpad ? iPadSize * 0.5 : iPadSize); //font 60

      case EFontSize.extraLargePx:
        return 26.4 * (isIpad ? iPadSize * 1.5 : iPadSize); //font 80
      case EFontSize.smallPx:
        return 13.2 * (isIpad ? iPadSize * 0.5 : iPadSize); //font 40
      case EFontSize.verySmallPx:
        return 9.9 * (isIpad ? iPadSize * 0.5 : iPadSize); //font 30

      default: //EFontSize.verySmall:
        return 0.027 * (isIpad ? iPadSize * 0.5 : iPadSize); //font 30
    }
  }
}

//////////////////
///Font Language Enumeration for using with stylishtext
enum EFontFamily { khmer, khmerBold, english, englishBold, moul, contentBold}

class EFontLanguage {
  EFontLanguage();

  static String getString(font) {
    switch (font) {
      case EFontFamily.english:
        return "EnOpenSans";
      case EFontFamily.englishBold:
        return "EnOpenSansBold";
      case EFontFamily.khmerBold:
        return "KhBattambangBold";
      case EFontFamily.moul:
        return "Moul";
      case EFontFamily.contentBold:
        return "ContentBold";
      case EFontFamily.khmer:
      default: //NFontLanguage.khmer:
        return "Kantumruy Pro";
    }
  }
}

///////////////////////////
///Stylish Text Widget
class EText extends StatelessWidget {
  final String text;
  final TextOverflow textOverflow;
  final Color color;
  final EFontFamily fontFamily;
  final EFontSize size;
  final TextAlign align;
  final String semaStringabel;
  final int maxLines;
  final TextDecoration decoration;
  ///////////////////////
  ///Constructor
  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  EText({
    required this.text,
    this.textOverflow = TextOverflow.fade,
    this.align = TextAlign.left,
    this.semaStringabel = '',
    this.fontFamily = EFontFamily.khmer,
    this.color = Colors.black,
    this.size = EFontSize.medium,
    this.decoration = TextDecoration.none,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: textOverflow,
      textAlign: align,
      semanticsLabel: semaStringabel,
      maxLines: maxLines,
      style: getTextStyle(
        fontFamily: fontFamily,
        color: color,
        // color:userPrefs.isDark?(article.isSensitive?Colors.red:Colors.white):(article.isSensitive?Colors.red:Colors.black),
        // color: userPrefs.isDark?Colors.white:Colors.black87,
        fontSize: size,
        decoration: decoration,
      ),
    );
  }

  ///Text Span
  static TextSpan getTextSpan({
    String text = "",
    required List<TextSpan> children,
    EFontFamily fontFamily = EFontFamily.khmer,
    Color color = Colors.black,
    EFontSize size = EFontSize.medium,
    required TextDecoration decoration,
    GestureRecognizer? recognizer,
  }) {
    return TextSpan(
      text: text,
      children: children,
      recognizer: recognizer,
      style: getTextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        color: color,
        decoration: decoration,
      ),
    );
  }

  ///Text Style
  static TextStyle getTextStyle(
      {EFontFamily fontFamily = EFontFamily.khmer,
      Color color = Colors.black,
      EFontSize fontSize = EFontSize.large,
      TextDecoration decoration = TextDecoration.none}) {
    double size = ESize.getDouble(fontSize);
    return TextStyle(
        fontSize: (size >= 1 ? size : mainWidth * size),
        fontFamily: EFontLanguage.getString(fontFamily),
        color: color,
        decoration: decoration);
  }
}

enum ETextFormatter { lowercase, uppercase, nomal }

/// format text to lowercase
class TextFormatter extends TextInputFormatter {
  var textFormater = ETextFormatter.nomal ;

  TextFormatter({this.textFormater = ETextFormatter.nomal});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    switch (textFormater) {
      case ETextFormatter.uppercase:
        return newValue.copyWith(text: newValue.text.toUpperCase());
      case ETextFormatter.lowercase:
        return newValue.copyWith(text: newValue.text.toLowerCase());
      case ETextFormatter.nomal:
      default:
        return newValue.copyWith(text: newValue.text.trim());
    }
  }
}
