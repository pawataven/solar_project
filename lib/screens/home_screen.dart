import 'package:flutter/material.dart';
import 'package:solar_project/services/main_ctrl.dart';
import 'dart:async'; // เพิ่ม import สำหรับ Timer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.esp32Service});

  final Esp32Service esp32Service;

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  Timer? _debounceTimer; // ตัวแปรสำหรับจัดการ Timer
  bool _isSendingCommand = false; // สถานะเพื่อควบคุมการส่งคำสั่งและปุ่ม

  @override
  Widget build(BuildContext context) {
    final double buttonSize = 300; // กำหนดขนาดปุ่ม

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 41, 84, 122),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.cleaning_services_rounded,
                  size: 48,
                ),
                // ตรวจสอบ _isSendingCommand เพื่อเปิด/ปิดปุ่ม
                onPressed: _isSendingCommand ? null : () {
                  // ตั้งค่าสถานะว่ากำลังส่งคำสั่ง เพื่อปิดปุ่มชั่วคราว
                  setState(() {
                    _isSendingCommand = true;
                  });

                  // ยกเลิก Timer เก่าถ้ายังทำงานอยู่ (สำหรับ Debounce)
                  if (_debounceTimer?.isActive ?? false) {
                    _debounceTimer!.cancel();
                  }

                  // ตั้ง Timer ใหม่: จะเรียก setPumpState หลังจาก 500ms
                  // หากมีการกดซ้ำภายใน 500ms Timer จะถูกรีเซ็ต
                  _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
                    try {
                      await widget.esp32Service.setPumpState(true);
                      print('Command sent successfully!');
                    } catch (e) {
                      print('Error sending command: $e');
                      // อาจแสดง SnackBar หรือ Dialog แจ้งผู้ใช้ถึง Error
                    } finally {
                      // เมื่อการส่งคำสั่งเสร็จสิ้น (ไม่ว่าจะสำเร็จหรือ error)
                      // ให้เปิดปุ่มกลับมาใช้งานได้
                      setState(() {
                        _isSendingCommand = false;
                      });
                    }
                  });
                },
                label: const Text(
                  'START',
                  style: TextStyle(fontSize: 28),
                ),
                style: ElevatedButton.styleFrom(
                  // เปลี่ยนสีปุ่มเมื่อถูกปิดการใช้งาน
                  backgroundColor: _isSendingCommand ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 255, 200, 80) ,
                  foregroundColor: Color.fromARGB(255, 41, 84, 122),
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.history_rounded),
              iconSize: 50,
              color: Colors.white,
              onPressed: () {
                print('History icon pressed!');
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // สำคัญ: ยกเลิก Timer เมื่อ Widget ถูกทำลายเพื่อป้องกัน memory leak
    _debounceTimer?.cancel();
    super.dispose();
  }
}