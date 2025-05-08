import 'package:flutter/material.dart';

class FormInput {
  final namekey = GlobalKey<FormState>();
  final codekey = GlobalKey<FormState>();
  final pricekey = GlobalKey<FormState>();
  final typekey = GlobalKey<FormState>();
   final passkey = GlobalKey<FormState>();
  final conpasskey = GlobalKey<FormState>();
  final txt_name = TextEditingController();
  final txt_code = TextEditingController();
  final txt_price = TextEditingController();
  final txt_type = TextEditingController();
  final txtPass = TextEditingController();
  final txtConpass = TextEditingController();
}
