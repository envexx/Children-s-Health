// lib/features/admin/admin_keluhan_detail.dart
import 'package:flutter/material.dart';

class AdminKeluhanDetail extends StatelessWidget {
  final Map<String, dynamic> keluhanData;

  const AdminKeluhanDetail({
    Key? key,
    required this.keluhanData,
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
          'Detail Keluhan',
          style: TextStyle(
            color: Color(0xFF4461F2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text('Detail Keluhan: ${keluhanData['title']}'),
      ),
    );
  }
}
