// lib/features/admin/admin_keluhan_list.dart
import 'package:flutter/material.dart';

class AdminKeluhanList extends StatelessWidget {
  const AdminKeluhanList({Key? key}) : super(key: key);

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
          'Daftar Keluhan',
          style: TextStyle(
            color: Color(0xFF4461F2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text('Daftar Keluhan Admin'),
      ),
    );
  }
}
