import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solar_project/screens/ScheduleScreen.dart';
import 'package:solar_project/screens/history_screen.dart';
import 'package:solar_project/screens/settings_screen.dart';
import 'package:solar_project/services/main_ctrl.dart';
import 'package:audioplayers/audioplayers.dart';

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

  String lastCleaningDate = "ยังไม่เคยทำความสะอาด";
  int cleaningCount = 0;
  double waterLevel = 75; // mock data (เช่น % น้ำในถัง)
  String pumpStatus = "พร้อมใช้งาน";

  /// ฟังก์ชันสั่ง ESP32
  void sendCommand() async {
    setState(() {
      _isSendingCommand = true;
      pumpStatus = "กำลังทำความสะอาด...";
      _audioPlayer.play(AssetSource('sounds/start.mp3'), volume: 1.0);
    });

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      try {
        await widget.esp32Service.setPumpState(true);
        print('✅ Command sent to ESP32');

        // ✅ อัปเดตข้อมูลเมื่อทำงานเสร็จ
        setState(() {
          lastCleaningDate = _getTodayDate();
          cleaningCount++;
          pumpStatus = "ทำความสะอาดเสร็จแล้ว ✅";
        });

        // 🔊 ✅ เล่นเสียงแจ้งเตือนเมื่อทำความสะอาดเสร็จ (ใน try block)
        await _audioPlayer.play(AssetSource('sounds/done.mp3'), volume: 1.0);
        
        // ✅ แสดง SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("สั่งงาน ESP32 เสร็จแล้ว ✅")),
          );
        }
      } catch (e) {
        print('❌ Error: $e');
        setState(() {
          pumpStatus = "เกิดข้อผิดพลาด ⚠️";
        });
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("เกิดข้อผิดพลาดในการสั่งงาน ⚠️")),
          );
        }
      } finally {
        setState(() {
          _isSendingCommand = false;
        });
      }
    });
  }

  /// ฟังก์ชันดึงวันที่ปัจจุบัน
  String _getTodayDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Solar Panel Cleaner",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "สถานะระบบ: $pumpStatus",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _isSendingCommand ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSendingCommand ? null : sendCommand,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSendingCommand
                    ? Colors.grey[400]
                    : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 18,
                ),
              ),
              child: _isSendingCommand
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      "START CLEANING",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInfoCard(Icons.date_range, "ล่าสุด", lastCleaningDate),
                  _buildInfoCard(
                    Icons.countertops,
                    "จำนวนครั้ง",
                    "$cleaningCount ครั้ง",
                  ),
                  _buildInfoCard(
                    Icons.water_drop,
                    "ระดับน้ำ",
                    "${waterLevel.toInt()}%",
                  ),
                  _buildInfoCard(Icons.info, "สถานะ", pumpStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        MaterialPageRoute(builder: (_) => const ScheduleScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onNavTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.cleaning_services),
          label: "ทำความสะอาด",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "ประวัติ"),
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "ตั้งเวลา"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "ตั้งค่า"),
      ],
    );
  }
}