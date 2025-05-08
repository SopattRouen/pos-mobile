import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/entity/enum/e_font.dart';
import 'package:mobile/entity/enum/e_textformfield_class.dart';
import 'package:mobile/entity/helper/font.dart';

class EForm extends StatelessWidget {
  const EForm({
    super.key,
    required this.hintext,
    required this.obscure,
    required this.controller,
    required this.intValidationRule,
    this.onTextChange,
    required this.inputColor,
    required this.size,
    required this.maxLength,
    required this.fontFamily,
    required this.text,
  });
  final String hintext;
  final bool obscure;
  final TextEditingController controller;
  final ETextFormFieldValidationRules intValidationRule;
  final ValueChanged<bool>? onTextChange;
  final Color inputColor;
  final EFontSize size;
  final int maxLength;
  final EFontFamily fontFamily;
  final String text;
  set autoValidate(value) => autoValidate = value;

  void _textFormFielEister() {
    if (onTextChange != null) {
      onTextChange!(controller.text.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.addListener(_textFormFielEister);
    // TextInputAction _textInputAction;
    EText.getTextStyle(
        fontFamily: EFontFamily.english, color: inputColor, fontSize: size);

    int intMaxTextLength = maxLength;

    ///Default is 50 characters allowed
    if (intValidationRule == ETextFormFieldValidationRules.numberOnly) {
      intMaxTextLength = maxLength;
    } else if (intValidationRule == ETextFormFieldValidationRules.textCapOnly) {
      intMaxTextLength = maxLength;
    } else if (intValidationRule ==
        ETextFormFieldValidationRules.numberAndText) {
      intMaxTextLength = maxLength;
    }

    ///Consider the behaviour of the text box upon the type of input box
    else if (intValidationRule == ETextFormFieldValidationRules.email) {
      intMaxTextLength = 40;
    } else if (intValidationRule == ETextFormFieldValidationRules.name) {
      intMaxTextLength = 35;
    } else if (intValidationRule == ETextFormFieldValidationRules.activation) {
      // textAlign = TextAlign.center;
      intMaxTextLength = 6;
    } else if (intValidationRule == ETextFormFieldValidationRules.phone) {
      intMaxTextLength = 10;
    } else if (intValidationRule == ETextFormFieldValidationRules.password) {
      intMaxTextLength = 25;
    } else if (intValidationRule == ETextFormFieldValidationRules.oldPassword) {
      intMaxTextLength = 25;
    } else if (intValidationRule ==
        ETextFormFieldValidationRules.confirmPassword) {
      intMaxTextLength = 25;
    } else if (intValidationRule ==
        ETextFormFieldValidationRules.singlelineLongText) {
      intMaxTextLength = 200;
    } else if (intValidationRule == ETextFormFieldValidationRules.multiline) {
      intMaxTextLength = 200;
    } else if (intValidationRule ==
        ETextFormFieldValidationRules.emailOrPhone) {
      intMaxTextLength = 40;
    } else {
      intMaxTextLength = 100;
    }

    /// Force language

    List<TextInputFormatter> inputFormatters = [
      LengthLimitingTextInputFormatter(intMaxTextLength)
    ];

    if (intValidationRule == ETextFormFieldValidationRules.numberOnly) {
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (intValidationRule == ETextFormFieldValidationRules.phone) {
      inputFormatters.add(FilteringTextInputFormatter(
          RegExp(r'^0{1}[1-9]{0,1}[0-9]{0,8}'),
          allow: true));
    }
    if (intValidationRule == ETextFormFieldValidationRules.numberOnly6) {
      intMaxTextLength = maxLength;
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp("[1-6]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.textCapOnly) {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp("[A-Z_ ]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.numberAndText) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9._ \\-]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.numberAndCapText) {
      intMaxTextLength = maxLength;
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp("[A-Z0-9._ \\-]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.name) {
      inputFormatters.add(FilteringTextInputFormatter.allow(
          RegExp(r"[A-Zក-អ ា-ោះ្់៊ឧឳឩឪ៌​ឥឯឭឮឬ]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.cardNumber) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp("[A-Z0-9.]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.idNumber) {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp("[0-9]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.plateNumber) {
      inputFormatters.add(
          FilteringTextInputFormatter.allow(RegExp(r"^[1-9]{1}([A-Z]{0,2})")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.headerKhmer) {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp(r"^[ក-អ]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.plateKh) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r"^[0-9-]{0,7}")));
      intMaxTextLength = 7;
    }

    if (intValidationRule == ETextFormFieldValidationRules.userName) {
      intMaxTextLength = 25;
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp("[A-Z0-9_ ]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.specialPlate) {
      intMaxTextLength = maxLength;
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp("[A-Z0-9.]{0,8}")));
    }
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.kantumruyPro(),
      decoration: InputDecoration(
        hintText: hintext,
        hintStyle: GoogleFonts.kantumruyPro(fontSize: 12),
        label: Text(text),
      ),
    );
  }
}
