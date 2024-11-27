// lib/features/terapis/terapis_laporan_detail.dart
import 'package:flutter/material.dart';

class TerapisLaporanDetail extends StatelessWidget {
  final Map<String, dynamic> laporanData;

  const TerapisLaporanDetail({
    Key? key,
    required this.laporanData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF4461F2),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Laporan',
          style: TextStyle(
            color: Color(0xFF4461F2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text('Detail Laporan: ${laporanData['title']}'),
      ),
    );
  }
}
