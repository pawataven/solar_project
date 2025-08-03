import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  /// ✅ ตัวแปร static ให้หน้าอื่นเข้าถึงได้ เช่น HomeScreen
  static bool isSoundOn = true;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationSound = true;
  bool autoClean = false;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // ✅ โหลดค่าจาก SharedPreferences
  }

  /// ✅ โหลดค่าจาก SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationSound = prefs.getBool('notificationSound') ?? true;
      autoClean = prefs.getBool('autoClean') ?? false;

      /// ✅ อัปเดต static ให้หน้าอื่นเรียกใช้ได้
      SettingsScreen.isSoundOn = notificationSound;
    });
  }

  /// ✅ บันทึกค่าเสียง
  Future<void> _saveSoundSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationSound', value);

    /// ✅ อัปเดต static ให้หน้าอื่นเรียกใช้ได้
    SettingsScreen.isSoundOn = value;
  }

  /// ✅ บันทึกค่าล้างอัตโนมัติ
  Future<void> _saveAutoCleanSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoClean', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ตั้งค่า",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("การแจ้งเตือน"),
          _buildSwitchTile(
            title: "เสียงแจ้งเตือน",
            subtitle: "เปิดหรือปิดเสียงเมื่อทำความสะอาดเสร็จ",
            value: notificationSound,
            onChanged: (val) {
              setState(() => notificationSound = val);

              /// ✅ บันทึก & อัปเดตค่า static
              _saveSoundSetting(val);
            },
          ),
          const SizedBox(height: 10),

          _buildSectionTitle("การทำความสะอาด"),
          _buildSwitchTile(
            title: "ล้างอัตโนมัติ",
            subtitle: "ให้ระบบล้างตามเวลาที่ตั้งไว้โดยอัตโนมัติ",
            value: autoClean,
            onChanged: (val) {
              setState(() => autoClean = val);
              _saveAutoCleanSetting(val);
            },
          ),
        ],
      ),
    );
  }

  /// ✅ หัวข้อ Section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// ✅ Switch Setting
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SwitchListTile(
        activeColor: Colors.blue,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
