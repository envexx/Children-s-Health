// lib/features/terapis/widgets/rpt_header_card.dart

import 'package:flutter/material.dart';
import '../../../core/models/rpt_model_terapis.dart';
import '../constants/styles.dart';

class RPTHeaderCard extends StatelessWidget {
  final RPTModel rptData;

  const RPTHeaderCard({
    Key? key,
    required this.rptData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          _buildHeaderSection(),

          // Divider
          const Divider(height: 1),

          // Program Details Section
          _buildProgramDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RPTStyles.mainColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Terapi Type & Therapist Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rptData.terapiType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: RPTStyles.mainColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terapis: ${rptData.therapistName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: rptData.status == 'Active'
                  ? RPTStyles.mainColor.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              rptData.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: rptData.status == 'Active'
                    ? RPTStyles.mainColor
                    : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Info Section
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 20,
                color: RPTStyles.mainColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Anak: ${rptData.childName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Program Purpose Section
          const Text(
            'Tujuan Program',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1E25),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
              ),
            ),
            child: Text(
              rptData.tujuanProgram,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),

          // Progress Section - Optional
          // You can add progress indicators or statistics here
          // const SizedBox(height: 16),
          // _buildProgressSection(),
        ],
      ),
    );
  }

  // Optional: Progress Section
  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Program',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1E25),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              // Add your progress indicators here
              // Example: LinearProgressIndicator or custom progress widgets
            ],
          ),
        ),
      ],
    );
  }
}

// Optional: If you want to make the card more reusable with custom styles
class RPTHeaderCardTheme {
  final Color backgroundColor;
  final Color headerColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final BorderRadius borderRadius;

  const RPTHeaderCardTheme({
    this.backgroundColor = Colors.white,
    this.headerColor = const Color(0xFF4461F2),
    this.titleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF4461F2),
    ),
    this.subtitleStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFF6B7280),
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });
}
