import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solar_project/screens/history_screen.dart';
import 'package:solar_project/screens/settings_screen.dart';
import 'package:solar_project/services/main_ctrl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.esp32Service});
  final Esp32Service esp32Service;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _debounceTimer;
  bool _isSendingCommand = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String lastCleaningDate = "กำลังโหลดข้อมูล...";
  String pumpStatus = "พร้อมใช้งาน";

  // โหลดข้อมูลล่าสุดจาก Firestore
  Future<void> _loadLastCleaning() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cleaning')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        lastCleaningDate = data['date'] ?? "ไม่พบข้อมูล";
        pumpStatus = data['status'] == true
            ? "ทำความสะอาดเสร็จแล้ว ✅"
            : "เกิดข้อผิดพลาด ⚠️";
      });
    } else {
      setState(() {
        lastCleaningDate = "ยังไม่เคยทำความสะอาด";
      });
    }
  }

  // ฟังก์ชันสั่ง ESP32
  void sendCommand() async {
    setState(() {
      _isSendingCommand = true;
      pumpStatus = "กำลังทำความสะอาด...";

      // เล่นเสียงเริ่มทำความสะอาด (ถ้าเปิดเสียงอยู่)
      if (SettingsScreen.isSoundOn) {
        _audioPlayer.play(AssetSource('sounds/start.mp3'), volume: 1.0);
      }
    });

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      try {
        await widget.esp32Service
            .setPumpState(true)
            .timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                throw TimeoutException("ESP32 ไม่ตอบสนองภายใน 60 วินาที");
              },
            );

        print('✅ Command sent to ESP32');

        //  บันทึกข้อมูลสำเร็จ
        await FirebaseFirestore.instance.collection('cleaning').add({
          'date': _getTodayDate(),
          'status': true,
        });

        // เล่นเสียงทำความสะอาดเสร็จ (ถ้าเปิดเสียงอยู่)
        if (SettingsScreen.isSoundOn) {
          await _audioPlayer.play(AssetSource('sounds/done.mp3'), volume: 1.0);
        }

        setState(() {
          pumpStatus = "ทำความสะอาดเสร็จแล้ว ✅";
          lastCleaningDate = _getTodayDate();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("สั่งงาน ESP32 เสร็จแล้ว ✅")),
          );
        }
      } catch (e) {
        print('❌ Error: $e');
        await FirebaseFirestore.instance.collection('cleaning').add({
          'date': _getTodayDate(),
          'status': false,
        });

        // เล่นเสียง error (ถ้าเปิดเสียงอยู่)
        if (SettingsScreen.isSoundOn) {
          await _audioPlayer.play(AssetSource('sounds/error.mp3'), volume: 1.0);
        }

        setState(() {
          pumpStatus = "เกิดข้อผิดพลาด ⚠️";
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: const Text(
                "เกิดข้อผิดพลาดในการสั่งงาน ⚠️",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      } finally {
        _loadLastCleaning();
        setState(() {
          _isSendingCommand = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLastCleaning();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Image.asset("assets/logo-v2.png", height: 150)),

              const SizedBox(height: 10),
              const Text(
                "Sora  Cleaner",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ปุ่มวงกลม START CLEANING
              Center(
                child: InkWell(
                  onTap: _isSendingCommand ? null : sendCommand,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isSendingCommand ? Colors.grey[400] : Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSendingCommand
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 4,
                            )
                          : const Text(
                              "START",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

          
              _buildInfoCard(
                Icons.date_range,
                "ทำความสะอาดล่าสุด",
                lastCleaningDate,
              ),
              _buildInfoCard(Icons.info, "สถานะ", pumpStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    Color statusColor = Colors.black54;
    if (value.contains("เสร็จแล้ว")) {
      statusColor = Colors.green;
    } else if (value.contains("ผิดพลาด")) {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
         
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 32, color: Colors.blue),
          ),
          const SizedBox(width: 16),

        
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(value, style: TextStyle(fontSize: 14, color: statusColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistoryScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.blue, 
      selectedItemColor: Colors.white, 
      unselectedItemColor: Colors.white70, 
      currentIndex: _selectedIndex,
      onTap: _onNavTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.cleaning_services),
          label: "ทำความสะอาด",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "ประวัติ"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "ตั้งค่า"),
      ],
    );
  }
}
