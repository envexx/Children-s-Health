import 'package:flutter/material.dart';

class TerapisFilter extends StatelessWidget {
  final Function(String) onSearchChanged;
  final Function(String) onSpesialisasiChanged;
  final String selectedSpesialisasi;

  const TerapisFilter({
    Key? key,
    required this.onSearchChanged,
    required this.onSpesialisasiChanged,
    required this.selectedSpesialisasi,
  }) : super(key: key);

  static final List<String> spesialisasiOptions = [
    'Semua',
    'Fisioterapi',
    'Okupasi',
    'Terapi Wicara'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildSpesialisasiFilter(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Cari terapis...',
        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSpesialisasiFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: spesialisasiOptions.map((spesialisasi) {
          final isSelected = selectedSpesialisasi == spesialisasi;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(spesialisasi),
              onSelected: (_) => onSpesialisasiChanged(spesialisasi),
              selectedColor: const Color(0xFF2563EB).withOpacity(0.1),
              checkmarkColor: const Color(0xFF2563EB),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
