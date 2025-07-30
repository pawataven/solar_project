import 'package:flutter/material.dart';
import 'package:solar_project/services/main_ctrl.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String esp32Ip =
      "http://192.168.1.114"; //กำหนดค่า IP ที่เดียวกับ wifi ที่ seting ค่าใน ESP32

  @override
  Widget build(BuildContext context) {
    final esp32Service = Esp32Service(esp32Ip: esp32Ip);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: HomeScreen(esp32Service: esp32Service),
      ),
    );
  }
}