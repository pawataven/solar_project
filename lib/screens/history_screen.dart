import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📝 mock data (ภายหลังสามารถดึงจาก ESP32 หรือ Database ได้)
    final List<Map<String, dynamic>> historyList = [
      {"date": "30/07/2025 14:30", "status": true},
      {"date": "28/07/2025 10:15", "status": true},
      {"date": "26/07/2025 16:45", "status": false},
      {"date": "25/07/2025 09:20", "status": true},
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ประวัติการทำความสะอาด",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final item = historyList[index];
          return _buildHistoryCard(item["date"], item["status"]);
        },
      ),
    );
  }

  /// ✅ Card ประวัติแต่ละรายการ
  Widget _buildHistoryCard(String date, bool status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.redAccent,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            status ? "สำเร็จ" : "ล้มเหลว",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: status ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
