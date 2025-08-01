import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationSound = true;
  bool autoClean = false;
  double pumpPower = 50;

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
            onChanged: (val) => setState(() => notificationSound = val),
          ),
          const SizedBox(height: 10),

          _buildSectionTitle("การทำความสะอาด"),
          _buildSwitchTile(
            title: "ล้างอัตโนมัติ",
            subtitle: "ให้ระบบล้างตามเวลาที่ตั้งไว้โดยอัตโนมัติ",
            value: autoClean,
            onChanged: (val) => setState(() => autoClean = val),
          ),
          const SizedBox(height: 10),

          _buildSliderTile(
            title: "กำลังปั๊ม",
            subtitle: "ปรับความแรงของปั๊ม (0 - 100%)",
            value: pumpPower,
            onChanged: (val) => setState(() => pumpPower = val),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle("เกี่ยวกับแอป"),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text("เวอร์ชันแอป"),
            subtitle: const Text("v1.0.0"),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text("ผู้พัฒนา"),
            subtitle: const Text("Dawn company"),
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

  /// ✅ Slider Setting
  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 10,
            label: "${value.toInt()}%",
            activeColor: Colors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
