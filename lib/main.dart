import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:solar_project/firebase_options.dart';
import 'package:solar_project/services/main_ctrl.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
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
