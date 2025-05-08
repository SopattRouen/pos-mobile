import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/entity/enum/e_font.dart';
import 'package:mobile/entity/enum/e_validation_class.dart';
import 'package:mobile/entity/enum/e_variable.dart';
import 'package:mobile/entity/helper/font.dart';

String parttern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z ]{2,}))$';

enum ETextFormFieldValidationRules {
  cardNumber,
  idNumber,
  headerKhmer,
  plateNumber,
  plateKh,
  vehicleHead,
  vehicleSeries,
  vehicleNumber,
  numberAndChar,
  numberOnly,
  numberOnly6,
  specialPlate,
  textCapOnly,
  numberAndText,
  numberAndCapText,
  name,
  userName,
  email,
  phone,
  password,
  confirmPassword,
  activation,
  custom,
  emailOrPhone,
  multiline,
  singlelineLongText,
  oldPassword,
}

class ETextFormField extends StatelessWidget {
  final ETextFormFieldValidationRules intValidationRule;
  final TextInputAction textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final bool isShowBorder;
  final bool isChangePassword;
  final bool isRequired;
  final bool isAutofocus;
  final bool enabled;
  final bool enableInteractiveSelection;
  final bool isReadOnly;
  final bool isAutoValidate;
  final bool isAutoCorrect;
  final bool isEditing;
  final bool isAllCapital;
  final bool isTextChange;
  final bool isObscureText;
  final bool isSmallHolder;
  final bool isDisableIcon;

  final String placeHolder;
  final Color labelColor;
  final Color textColor;
  final Color inputColor;
  final Widget? iconImage;
  final Icon? icon;
  final Color borderColor;
  final EFontFamily fontFamily;
  final EFontSize size;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? defaultValue;
  final int maxLength;
  final TextAlign textAlign;
  final double? customTextBoxHeight;
  final double? radius;

  final ValueChanged<String?> onSaved;
  final ValueChanged<Map<String, String>>? onValidating;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<bool>? onTextChange;
  final VoidCallback? onShowPassword;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onClear;
  final VoidCallback? onEndEditing;
  final ValueChanged<String>? onChange;

  ////////////////////////
  ///Constructor
  const ETextFormField({
    super.key,
    this.contentPadding,

    /// contentPadding: EdgeInsets.all(mainWidth * textboxPadding),
    this.placeHolder = '',
    this.labelColor = Colors.grey,
    this.textColor = Colors.white,
    this.inputColor = Colors.black,
    this.borderColor = Colors.black,
    this.fontFamily = EFontFamily.khmer,
    this.size = EFontSize.large,
    required this.intValidationRule,
    this.textInputAction = TextInputAction.done,
    this.isAutoValidate = false,
    this.isAutoCorrect = false,
    this.isShowBorder = true,
    this.enabled = true,
    this.enableInteractiveSelection = true,
    this.isReadOnly = false,
    this.isChangePassword = false,
    this.isRequired = true,
    this.isAutofocus = false,
    this.isEditing = false,
    this.isAllCapital = false,
    this.isTextChange = false,
    this.isObscureText = false,
    this.isSmallHolder = false,
    this.isDisableIcon = false,
    this.customTextBoxHeight,
    this.defaultValue,
    this.iconImage,
    this.icon,
    required this.controller,
    this.focusNode,
    this.maxLength = 50,
    this.textAlign = TextAlign.left,

    /// EVENT
    required this.onSaved,
    this.onFieldSubmitted,
    this.onValidating,
    this.onShowPassword,
    this.onTextChange,
    this.onTap,
    this.onEndEditing,
    this.onChange,
    this.onClear,
    this.radius = 5,
  });

  set autoValidate(value) => autoValidate = value;

  void _textFormFielEister() {
    if (onTextChange != null) {
      onTextChange!(controller.text.isNotEmpty);
    }
  }

  ///////////////////
  ///Build Widget
  @override
  Widget build(BuildContext context) {
    controller.addListener(_textFormFielEister);
    TextInputType textInputType;
    // TextInputAction _textInputAction;
    TextStyle style = EText.getTextStyle(
        fontFamily: EFontFamily.english, color: inputColor, fontSize: size);

    int intMaxTextLength = maxLength;

    ///Default is 50 characters allowed

    if (intValidationRule == ETextFormFieldValidationRules.numberOnly) {
      intMaxTextLength = maxLength;
      textInputType = TextInputType.number;
    } else if (intValidationRule == ETextFormFieldValidationRules.textCapOnly) {
      intMaxTextLength = maxLength;
      textInputType = TextInputType.text;
    } else if (intValidationRule ==
        ETextFormFieldValidationRules.numberAndText) {
      intMaxTextLength = maxLength;
      textInputType = TextInputType.text;
    }

    ///Consider the behaviour of the text box upon the type of input box
    else if (intValidationRule == ETextFormFieldValidationRules.email) {
      intMaxTextLength = 40;
      textInputType = TextInputType.emailAddress;
    } else if (intValidationRule == ETextFormFieldValidationRules.name) {
      textInputType = TextInputType.text;
      intMaxTextLength = 35;
    } else if (intValidationRule == ETextFormFieldValidationRules.activation) {
      // textAlign = TextAlign.center;
      textInputType = TextInputType.number;
      intMaxTextLength = 6;
    } else if (intValidationRule == ETextFormFieldValidationRules.phone) {
      textInputType = TextInputType.phone;
      intMaxTextLength = 10;
    } else if (intValidationRule == ETextFormFieldValidationRules.password) {
      textInputType = TextInputType.text;
      intMaxTextLength = 25;
    } else if (intValidationRule == ETextFormFieldValidationRules.oldPassword) {
      textInputType = TextInputType.text;
      intMaxTextLength = 25;
    } else if (intValidationRule ==
        ETextFormFieldValidationRules.confirmPassword) {
      textInputType = TextInputType.text;
      intMaxTextLength = 25;
    } else if (intValidationRule ==
        ETextFormFieldValidationRules.singlelineLongText) {
      textInputType = TextInputType.text;
      intMaxTextLength = 200;
    } else if (intValidationRule == ETextFormFieldValidationRules.multiline) {
      style = EText.getTextStyle(
        fontFamily: EFontFamily.khmer,
        color: Colors.black,
      );
      textInputType = TextInputType.multiline;
      intMaxTextLength = 200;
    } else if (intValidationRule ==
        ETextFormFieldValidationRules.emailOrPhone) {
      textInputType = TextInputType.emailAddress;
      intMaxTextLength = 40;
    } else {
      textInputType = TextInputType.text;
      intMaxTextLength = 100;
    }

    /// Force language
    style = EText.getTextStyle(fontFamily: fontFamily);

    List<TextInputFormatter> inputFormatters = [
      LengthLimitingTextInputFormatter(intMaxTextLength)
    ];

    if (intValidationRule == ETextFormFieldValidationRules.numberOnly) {
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (intValidationRule == ETextFormFieldValidationRules.phone) {
      textInputType = TextInputType.phone;
      inputFormatters.add(FilteringTextInputFormatter(
          RegExp(r'^0{1}[1-9]{0,1}[0-9]{0,8}'),
          allow: true));
    }
    if (intValidationRule == ETextFormFieldValidationRules.numberOnly6) {
      intMaxTextLength = maxLength;
      textInputType = TextInputType.number;
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
      textInputType = TextInputType.text;
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
      textInputType = TextInputType.text;
      intMaxTextLength = 25;
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp("[A-Z0-9_ ]")));
    }

    if (intValidationRule == ETextFormFieldValidationRules.specialPlate) {
      intMaxTextLength = maxLength;
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp("[A-Z0-9.]{0,8}")));
    }

    //////////////////////////////////////////////////////////////
    ///RETURN THE BUILD
    return SizedBox(
      // alignment: Alignment.center,
      // height: intValidationRule == ETextFormFieldValidationRules.multiline? null: (customTextBoxHeight ?? mainWidth * textBoxHeight) ,
      // width: mainWidth,
      child: TextFormField(
        autocorrect: isAutoCorrect,
        enableInteractiveSelection: enableInteractiveSelection,
        key: key,
        controller: controller,

        textAlign: textAlign,
        maxLines: intValidationRule == ETextFormFieldValidationRules.multiline
            ? null
            : 1,
        inputFormatters: inputFormatters,
        textCapitalization: isAllCapital
            ? TextCapitalization.characters
            : TextCapitalization.none,
        autovalidateMode: isAutoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        autofocus: isAutofocus,
        decoration: _generateInputDecoration(placeHolder, labelColor, context),
        style: style,
        enabled: enabled,
        readOnly: isReadOnly,
        keyboardType: textInputType,
        textInputAction: textInputAction,
        initialValue: defaultValue,
        focusNode: focusNode,
        textAlignVertical: TextAlignVertical.center,

        // Events
        validator: (value) {
          String txt = _onTextFormFieldValidation(value ?? "", context);
          // print('validator: $txt');
          return value!.isEmpty ? null : txt;
        },
        obscureText: isObscureText,
        onTap: () {
          if (onTap != null) {
            controller.selection =
                TextSelection.collapsed(offset: controller.text.length);
            onTap!();
          }
        },
        onChanged: onChange,
        onSaved: onSaved,
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(FocusNode());
          if (onEndEditing != null) onEndEditing!();
        },
        onFieldSubmitted: (String value) {
          if (onFieldSubmitted != null) onFieldSubmitted!(value);
        },
        maxLength: maxLength,
      ),
    );
  }

  /////////////////////////////
  ///Function to Generate Input Decoration
  InputDecoration _generateInputDecoration(
      String labelText, Color labelHint, BuildContext context) {
    OutlineInputBorder? errorOutlineBorder = !isShowBorder
        ? null
        : OutlineInputBorder(
            borderSide: const BorderSide(
                style: BorderStyle.solid, width: 1, color: Colors.red),
            borderRadius: BorderRadius.circular(radius!),
          );

    OutlineInputBorder? normalOutlineBorder = !isShowBorder
        ? null
        : OutlineInputBorder(
            borderSide: BorderSide(
                style: BorderStyle.solid, width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(radius!),
          );

    return InputDecoration(
      isDense: true,
      hintStyle: const TextStyle(color: Colors.red),
      counter: const Offstage(),
      prefixIcon: iconImage ?? icon,
      suffixIcon: enabled || isEditing
          ? isChangePassword
              // show password
              ? IconButton(
                  // iconSize: !isTextChange? 0 : mainWidth * ESize.getDouble(EFontSize.medium ),
                  onPressed: () {
                    if (onShowPassword != null) onShowPassword!();
                  },
                  color: Colors.grey,
                  icon: const Icon(Icons.remove_red_eye),
                )

              // clear text
              : isDisableIcon
                  ? null
                  : IconButton(
                      padding: const EdgeInsets.all(0),
                      // iconSize: !isTextChange? 0 : mainWidth * ESize.getDouble(EFontSize.medium),
                      onPressed: () {
                        controller.clear();
                        if (onClear != null) {
                          onClear!(true);
                        }
                      },
                      color: Colors.grey,
                      icon: const Icon(
                        Icons.clear,
                      ),
                    )
          : Container(),

      fillColor:
          (!enabled && textColor == Colors.white) ? Colors.white : textColor,
      // fillColor: (userPrefs.isDark?Colors.white:this.textColor),
      labelText: labelText,
      labelStyle: EText.getTextStyle(
        fontSize: isSmallHolder ? EFontSize.verySmall : EFontSize.medium,
        fontFamily: EFontFamily.khmer,
        color: labelHint,
      ),

      prefixStyle: const TextStyle(color: Colors.red),
      // enabledBorder: normalOutlineBorder,
      border: isShowBorder ? normalOutlineBorder : InputBorder.none,
      focusedBorder: normalOutlineBorder,
      focusedErrorBorder: errorOutlineBorder,
      errorBorder: errorOutlineBorder,
      contentPadding:
          contentPadding ?? EdgeInsets.all(mainWidth * textboxPadding * 1.2),
      filled: !isShowBorder ? false : true,
    );
  }

  ///////////////////////
  /// Validate Text Form Field
  String _onTextFormFieldValidation(String value, BuildContext context) {
    String errMsg = '';
    switch (intValidationRule) {
      ////////////////////
      /// email validation
      case ETextFormFieldValidationRules.vehicleHead:
        final RegExp regExp = RegExp(r'(^[0-9]*$)');
        if (isRequired) {
          if (value.trim().length < 2) {
            errMsg = 'errInputPhoneGE9';
          } else if (!regExp.hasMatch(value)) {
            errMsg = 'errInputPhone09';
          }
        }

        break;

      ////////////////////
      /// email validation
      case ETextFormFieldValidationRules.numberOnly:
        if (value.trim().isEmpty) {
          errMsg = 'errInputPhoneGE9';
        }

        break;

      ////////////////////
      /// email validation
      case ETextFormFieldValidationRules.email:
        RegExp regExp = RegExp(parttern);
        if (isRequired) {
          if (value.trim().isEmpty) {
            errMsg = 'errInputEmailRequired';
          }
          if (!regExp.hasMatch(value)) {
            errMsg = 'errInputEmail';
          }
        }

        break;

      ////////////////////
      /// phone validation
      case ETextFormFieldValidationRules.phone:
        final RegExp phoneExp = RegExp(r'(^[0-9]*$)');

        /// Original
        // final RegExp phoneExp = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
        if (isRequired) {
          if (value.trim().length < 9 || value.trim().length > 10) {
            errMsg = '* ឧ.៖ 0123456789 (9-10ខ្ទង់)';
          } else if (!phoneExp.hasMatch(value)) {
            errMsg = 'errInputPhone09';
          }
        }

        break;

      case ETextFormFieldValidationRules.numberAndText:
        // String parttern = r'(^[A-Z_ ]*$)';
        // RegExp regExp = new RegExp(parttern);

        if (value.length < 8 || value.length > 35) {
          errMsg = '* យ៉ាងតិច ៨ខ្ទង់';
        }

        // else if (!regExp.hasMatch(value))

        break;
      ////////////////
      /// both E Card and ID Card
      case ETextFormFieldValidationRules.cardNumber:
        if (value.length != 9 || value.contains(RegExp("[A-Z]."))) {
          if (value.length < 8 ||
              !value.contains(RegExp("[A-Z].")) ||
              !value.contains(RegExp("[0-9]"))) {
            errMsg = '* ឧ.៖ B.PP.00000000 (៨-១៥ខ្ទង់) ឬ 000000001 (៩ខ្ទង់)';
          }
        }
        break;

      ///ID Card Numbers
      case ETextFormFieldValidationRules.idNumber:
        if (value.length < 9) {
          errMsg = '* ឧ.៖ 000000001';
        }
        break;

      case ETextFormFieldValidationRules.name:
        // String parttern = r'(^[A-Z_ ]*$)';
        // RegExp regExp = new RegExp(parttern);

        if (value.length < 4 || value.length > 35) {
          errMsg = '* យ៉ាងតិច៤ខ្ទង់';
        }
        // else if (!regExp.hasMatch(value))

        break;

      ////////////////////
      /// password validation
      case ETextFormFieldValidationRules.password:
        passwordMatch = value;
        // String parttern = r'(^[a-zA-Z0-9\s]*$)';
        // RegExp regExp = new RegExp(parttern);
        if (value.length < 6) {
          errMsg = '* ពាក្យសម្ងាត់យ៉ាងតិច៦ខ្ទង់';
        }
        // else if (!regExp.hasMatch(value))
        //   errMsg = 'errInputPasswordAZ';

        break;

      //////
      /// confirm password validation
      case ETextFormFieldValidationRules.confirmPassword:
        if (value != passwordMatch) {
          errMsg = 'errInputConfirmPasswordMatch';
        }

        break;

      ////////////////////
      /// activate validation
      case ETextFormFieldValidationRules.activation:
        String parttern = r'(^[0-9]*$)';
        RegExp regExp = RegExp(parttern);
        if (value.length < 6) {
          errMsg = 'errInputActivation6';
        } else if (!regExp.hasMatch(value)) {
          errMsg = 'errInputActivation09';
        }

        break;

      ////////////////////
      /// custom validation
      case ETextFormFieldValidationRules.custom:
        break;

      ////////////////////
      /// email or phone in one box validation
      case ETextFormFieldValidationRules.emailOrPhone:
        final RegExp phoneExp = RegExp(r'(^[0-9]*$)');

        if (isRequired) {
          /// check number or not
          if (EValidation.isNumber(value)) {
            /// is number
            if (value.trim().length < 9) {
              errMsg = 'errInputPhoneGE9';
            } else if (!phoneExp.hasMatch(value)) {
              errMsg = 'errInputPhone09';
            }
          } else {
            /// not number is email
            RegExp regExp = RegExp(parttern);

            if (isRequired && value.trim().isEmpty) {
              errMsg = 'errInputEmailRequired';
            }
            if (!regExp.hasMatch(value)) {
              errMsg = 'errInputEmail';
            }
          }
        } else {
          if (EValidation.isNumber(value)) {
            if (value.trim().isNotEmpty && !phoneExp.hasMatch(value)) {
              errMsg = 'errInputPhone09';
            }
          }
        }

        break;

      ////////////////////
      /// multiline validation
      case ETextFormFieldValidationRules.multiline:
        break;

      ////////////////////
      /// Other case
      default:

        ///If reached, assume that your application is abnormally functioned!
        errMsg = 'errInputUnexpect';
        break;
    }

    // If any error message > error happen
    Map<String, String> responseMap = <String, String>{};
    responseMap['value'] = value;
    responseMap['error'] = errMsg;
    if (errMsg == '') {
      if (onValidating != null) onValidating!(responseMap);
      return "";
    }

    if (onValidating != null) onValidating!(responseMap);
    return errMsg;
  }
}
