// Common styles
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final baseTextStyle = GoogleFonts.spaceGrotesk();
const primaryColor = Colors.green;
const borderColor = Color.fromARGB(255, 15, 37, 16);
const scaffoldBackgroundColor = Colors.black;
const brightness = Brightness.dark;

// Input decoration theme
final inputDecorationTheme = InputDecorationTheme(
  prefixIconColor: Colors.white70,
  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  labelStyle: baseTextStyle.copyWith(color: Colors.white, fontSize: 22),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(0),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(0),
    borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
  ),
);

// Common button styles
final buttonStyle = ButtonStyle(
  alignment: Alignment.center,
  padding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
  ),
  fixedSize: WidgetStateProperty.resolveWith(
    (states) => const Size(double.infinity, 48),
  ),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
  ),
  textStyle: WidgetStateProperty.all(
    TextStyle(
      color: Colors.green[900],
      fontSize: 18,
      fontWeight: FontWeight.w400,
      fontFamily: baseTextStyle.fontFamily,
    ),
  ),
);

// Common slider theme
final sliderTheme = SliderThemeData(
  activeTrackColor: primaryColor,
  inactiveTrackColor: Colors.grey.shade700,
  thumbColor: primaryColor,
  overlayColor: primaryColor.withOpacity(0.3),
  valueIndicatorColor: primaryColor,
  valueIndicatorTextStyle: baseTextStyle.copyWith(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  ),
  showValueIndicator: ShowValueIndicator.always,
);
