import 'package:flutter/material.dart';
import 'package:solar_project/services/main_ctrl.dart';
import 'screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String esp32Ip = "http://192.168.1.114";

  @override
  Widget build(BuildContext context) {
    final esp32Service = Esp32Service(esp32Ip: esp32Ip);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: HomeScreen(esp32Service: esp32Service),
    );
  }
}
