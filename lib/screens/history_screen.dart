import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistoryData();
  }

  Future<List<Map<String, dynamic>>> _fetchHistoryData() async {
    await Firebase.initializeApp();
    final snapshot = await FirebaseFirestore.instance
        .collection('cleaning')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'date': data['date'] ?? '',
        'status': data['status'] ?? false,
        'waterLevel': data['waterLevel'] ?? 0,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          }

          final historyList = snapshot.data!;
          if (historyList.isEmpty) {
            return const Center(child: Text("ยังไม่มีประวัติการทำความสะอาด"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              return _buildHistoryCard(
                item['date'],
                item['status'],
                item['waterLevel'],
              );
            },
          );
        },
      ),
    );
  }

  /// ✅ Card แสดงข้อมูลแต่ละรายการ
  Widget _buildHistoryCard(String date, bool status, int waterLevel) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 8),
          Text("ระดับน้ำ: $waterLevel%", style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
