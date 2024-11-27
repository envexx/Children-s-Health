// lib/features/terapis/terapis_rpt_edit.dart
import 'package:flutter/material.dart';

class TerapisRptEdit extends StatelessWidget {
  final Map<String, dynamic> rptData;

  const TerapisRptEdit({
    Key? key,
    required this.rptData,
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
          'Edit RPT',
          style: TextStyle(
            color: Color(0xFF4461F2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text('Edit RPT: ${rptData['title']}'),
      ),
    );
  }
}
