import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double borderRadius;

  const CustomElevatedButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.blue, // Default color if not provided
    this.borderRadius = 8.0, // Default border radius if not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: backgroundColor,
          textStyle: GoogleFonts.kantumruyPro(color: Colors.white),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
