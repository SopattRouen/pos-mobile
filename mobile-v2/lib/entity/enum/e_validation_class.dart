class EValidation {
  /// check varible is number or not
  static bool isNumber(String s) {
    if (s == '') {
      return false;
    }
    return double.tryParse(s) != null;
  }

  //// check email varidate or not 
  static bool isEmail(String email) {
    String parttern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z ]{2,}))$';
    RegExp regExp = RegExp(parttern);
    if (email.trim().isEmpty) {
      return false;
    }
    if (!regExp.hasMatch(email)) {
      return false;
    }
    return true;
  }

  //// check phone varidate or not 
  static bool isPhone(String phone) {
    final RegExp phoneExp = RegExp(r'(^[0-9]*$)');
    if (phone.trim().isEmpty || phone.trim().length <= 8){
      return false;
    } 
    if (!phoneExp.hasMatch(phone)) {
      return false;
    }
    return true;
  }
}
