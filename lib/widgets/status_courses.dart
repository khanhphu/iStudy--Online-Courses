// Se la mot file dinh dang cho cac trang thai cua khoa hoc:
// 1. Recommend,
// 2. NEW,
// 3. Popular

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomStatusBar extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;

  const CustomStatusBar({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.backgroundColor = const Color(0xFF2A2575), // mặc định light_purple
    this.textColor = Colors.white,
    this.borderRadius = 36,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontWeight: fontWeight,
          color: textColor,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
