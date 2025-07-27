import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
final String esp32Ip = "http://192.168.1.114"; // ใช้ IP Address ที่ได้จาก Serial Monitor ของ ESP32

  Future<void> setPumpState(bool isOn) async {
    final state = isOn ? "true" : "false";
    final url = Uri.parse('$esp32Ip/pump?state=$state');
    await http.get(url);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ESP32 Controller')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setPumpState(true),
                child: Text("เปิด"),
              ),
              ElevatedButton(
                onPressed: () => setPumpState(false),
                child: Text("ปิด"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
