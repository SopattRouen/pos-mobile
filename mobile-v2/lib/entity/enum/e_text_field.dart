

import 'package:flutter/material.dart';
import 'package:mobile/entity/enum/e_font.dart';

class DLTextField extends StatelessWidget {

  final String text;
  final String labelText;
  final String errorText;
  final Color fillColor;
  final bool isPassword;
  final bool autofocus;
  final TextEditingController textController;
  final Widget suffixIcon;
  final ValueChanged<String> onChanged;

  const DLTextField({
    required this.textController,
    this.isPassword = false,
    this.autofocus = false,
    this.fillColor = Colors.black,
    this.labelText = "",
    this.text = "",
    this.errorText = "",
    
    required this.onChanged,
    this.suffixIcon = const SizedBox(),

    Key key = const Key(""),

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    bool obscureText = true;

    return TextField(
      controller: textController,
      autofocus: autofocus,
      onChanged: onChanged,
      style: EText.getTextStyle(),
      obscureText: isPassword? obscureText:false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: text,
        hintStyle: const TextStyle(color: Colors.white54),
        labelText: labelText,
        filled: true,
        fillColor: fillColor,
        isDense: true,
        errorText: errorText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        suffixIcon: suffixIcon
        
      ),
    );
  }
}