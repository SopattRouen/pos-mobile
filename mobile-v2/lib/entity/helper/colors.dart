import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HColors {
  // Static method to return a primary color
  static Color primaryColor() {
    return const Color(0xFF0C7EA5);
  }

  // You can define other helper methods for different color schemes if needed
  static Color secondaryColor() {
    return const Color(0xFF0A6E90); // Example of another color
  }

  static Color accentColor() {
    return const Color(0xFFE53935); // Example of an accent color
  }

  static Color backgroundColor() {
    return Colors.teal; // Example of a background color
  }

  // You can also define color values directly as static properties
  static const Color success = Color(0xFF28A745);
  static const Color danger = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color green= Color(0xFF008000);
  static const Color grey=Color(0xFF64748B);
}
class Fonts {
  // Regular text style
  static TextStyle regular({
    double fontSize = 14,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.kantumruyPro(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  // Bold text style
  static TextStyle bold({
    double fontSize = 14,
    Color color = Colors.black,
  }) {
    return GoogleFonts.kantumruyPro(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  // Italic text style
  static TextStyle italic({
    double fontSize = 14,
    Color color = Colors.black,
  }) {
    return GoogleFonts.kantumruyPro(
      fontSize: fontSize,
      color: color,
      fontStyle: FontStyle.italic,
    );
  }
}

final icons = [
  'assets/images/pack.png',
  'assets/images/packagegreen.png',
  'assets/images/group.png',
  'assets/images/cart2.png',
];
final List<String> titles = [
  'Product',
  'Category',
  'User',
  'Sale',
];
final calendar = [
  'assets/images/event.png',
  'assets/images/calendar1.png',
  'assets/images/remove.png',
  'assets/images/calendar2.png',
  'assets/images/calendar4.png',
];
final title = [
  'Today',
  'This Week',
  'This Month',
  '3 Month Ago',
  '6 Month Ago',
];

final dateIcons=[
  'assets/images/event.png',
  'assets/images/calendar1.png',
  'assets/images/remove.png',
];
final dateIconsType=[
  'assets/images/calendar1.png',
  'assets/images/remove.png',
  'assets/images/calendar2.png',
  'assets/images/calendar4.png',
];
final dateText=[
  'Today',
  'This Week',
  'Yesterday',
];
