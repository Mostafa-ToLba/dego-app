


import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

Color color1 = HexColor('F5F5F5');
Color color2 = HexColor('FE3B75');
Color color3 = HexColor('#4d4d4d');


String engFont = 'BalooPaaji2';
String arbFont = 'DIN Next LT W23';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (var i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (final strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}


Future navigateTo(context, Widget) => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Widget,
  ),
);

dynamic navigateAndFinsh(context, dynamic) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => dynamic,
    ),
        (route) => false);
