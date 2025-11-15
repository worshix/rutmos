import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this to your pubspec.yaml
import 'package:rutmos/landing_page.dart';

// Define the primary color from the logo
const Color kPrimaryColor = Color(0xFF1E8449); // Deep Green

void main() {
  runApp(const RutmosApp());
}

class RutmosApp extends StatelessWidget {
  const RutmosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutmos Money Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use the deep green as the primary swatch
        primarySwatch: createMaterialColor(kPrimaryColor),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(kPrimaryColor)),
        // Set up the font to be clean and readable (e.g., using Google Fonts)
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

// Helper function to create a MaterialColor from a single Color value
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
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

// NOTE: You will need to add the google_fonts package to your pubspec.yaml file:
// dependencies:
//   flutter:
//     sdk: flutter
//   google_fonts: ^6.1.0