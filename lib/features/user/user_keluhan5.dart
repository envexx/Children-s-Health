// lib/features/user/screens/user_keluhan5.dart
import 'package:flutter/material.dart';
import '../../../config/routes/app_routes.dart';

class UserKeluhan5 extends StatefulWidget {
  const UserKeluhan5({super.key});

  @override
  State<UserKeluhan5> createState() => _UserKeluhan5State();
}

class _UserKeluhan5State extends State<UserKeluhan5> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk input fields
  final _asiController = TextEditingController();

  // Controllers untuk riwayat jatuh
  final _jatuhUsiaController = TextEditingController();
  final _jatuhTinggiController = TextEditingController();

  // Controllers untuk riwayat sakit
  final _sakitParahUsiaController = TextEditingController();
  final _panasTinggiUsiaController = TextEditingController();
  final _panasKejangUsiaController = TextEditingController();
  final _panasKejangFrekuensiController = TextEditingController();
  final _kejangTanpaPanasUsiaController = TextEditingController();
  final _kejangTanpaPanasFrekuensiController = TextEditingController();
  final _beratRendahUsiaController = TextEditingController();
  final _virusUsiaController = TextEditingController();
  final _virusJenisController = TextEditingController();

  // Dropdown values
  String? _selectedJatuh;
  String? _selectedSakitParah;
  String? _selectedPanasTinggi;
  String? _selectedPanasKejang;
  String? _selectedKejangTanpaPanas;
  String? _selectedBeratRendah;
  String? _selectedVirus;

  // Data perkembangan motorik
  final List<Map<String, dynamic>> _motorikList = [
    {'title': 'Tengkurap', 'done': false, 'usia': ''},
    {'title': 'Berguling', 'done': false, 'usia': ''},
    {'title': 'Duduk', 'done': false, 'usia': ''},
    {'title': 'Merayap', 'done': false, 'usia': ''},
    {'title': 'Merangkak', 'done': false, 'usia': ''},
    {'title': 'Jongkok', 'done': false, 'usia': ''},
    {'title': 'Transisi Berdiri', 'done': false, 'usia': ''},
    {'title': 'Berdiri tanpa pegangan', 'done': false, 'usia': ''},
    {'title': 'Berjalan tanpa pegangan', 'done': false, 'usia': ''},
    {'title': 'Berlari', 'done': false, 'usia': ''},
    {'title': 'Melompat', 'done': false, 'usia': ''},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Perkembangan',
          style: TextStyle(
            color: Color(0xFF4461F2),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF4461F2),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                const LinearProgressIndicator(
                  value: 0.71, // 5/7 progress
                  backgroundColor: Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4461F2)),
                ),
                const SizedBox(height: 24),

                // Title Section
                Text(
                  'Riwayat Perkembangan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF1A1E25),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi data riwayat perkembangan anak',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                ),
                const SizedBox(height: 32),

                // Form Sections
// Riwayat ASI
                _buildFormSection(
                  title: 'Riwayat ASI',
                  children: [
                    _buildInputField(
                      controller: _asiController,
                      label: 'Lama Pemberian ASI',
                      suffix: 'Bulan',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

// Riwayat Jatuh
                _buildFormSection(
                  title: 'Riwayat Jatuh',
                  children: [
                    _buildDropdownField(
                      value: _selectedJatuh,
                      label: 'Pilih riwayat jatuh',
                      items: const ['Ya', 'Tidak'],
                      onChanged: (val) {
                        setState(() => _selectedJatuh = val);
                      },
                    ),
                    if (_selectedJatuh == 'Ya') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _jatuhUsiaController,
                              label: 'Usia saat jatuh',
                              suffix: 'Bulan',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInputField(
                              controller: _jatuhTinggiController,
                              label: 'Ketinggian',
                              suffix: 'cm',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),

// Riwayat Sakit
                _buildFormSection(
                  title: 'Riwayat Sakit',
                  children: [
                    _buildDropdownField(
                      value: _selectedSakitParah,
                      label: 'Pernah sakit parah',
                      items: const ['Ya', 'Tidak'],
                      onChanged: (val) {
                        setState(() => _selectedSakitParah = val);
                      },
                    ),
                    if (_selectedSakitParah == 'Ya') ...[
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _sakitParahUsiaController,
                        label: 'Usia saat sakit',
                        suffix: 'Bulan',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      value: _selectedPanasTinggi,
                      label: 'Pernah panas tinggi',
                      items: const ['Ya', 'Tidak'],
                      onChanged: (val) {
                        setState(() => _selectedPanasTinggi = val);
                      },
                    ),
                    if (_selectedPanasTinggi == 'Ya') ...[
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _panasTinggiUsiaController,
                        label: 'Usia saat panas tinggi',
                        suffix: 'Bulan',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      value: _selectedPanasKejang,
                      label: 'Panas disertai kejang',
                      items: const ['Ya', 'Tidak'],
                      onChanged: (val) {
                        setState(() => _selectedPanasKejang = val);
                      },
                    ),
                    if (_selectedPanasKejang == 'Ya') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _panasKejangUsiaController,
                              label: 'Usia',
                              suffix: 'Bulan',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInputField(
                              controller: _panasKejangFrekuensiController,
                              label: 'Frekuensi dan durasi',
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      value: _selectedKejangTanpaPanas,
                      label: 'Pernah kejang tanpa panas',
                      items: const ['Ya', 'Tidak'],
                      onChanged: (val) {
                        setState(() => _selectedKejangTanpaPanas = val);
                      },
                    ),
                    if (_selectedKejangTanpaPanas == 'Ya') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _kejangTanpaPanasUsiaController,
                              label: 'Usia',
                              suffix: 'Bulan',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInputField(
                              controller: _kejangTanpaPanasFrekuensiController,
                              label: 'Frekuensi dan durasi',
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      value: _selectedBeratRendah,
                      label: 'Pernah sakit sampai berat badan rendah',
                      items: const ['Ya', 'Tidak'],
                      onChanged: (val) {
                        setState(() => _selectedBeratRendah = val);
                      },
                    ),
                    if (_selectedBeratRendah == 'Ya') ...[
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _beratRendahUsiaController,
                        label: 'Usia saat berat badan rendah',
                        suffix: 'Bulan',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      value: _selectedVirus,
                      label: 'Sakit karena virus',
                      items: const ['Ya', 'Tidak'],
                      onChanged: (val) {
                        setState(() => _selectedVirus = val);
                      },
                    ),
                    if (_selectedVirus == 'Ya') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _virusUsiaController,
                              label: 'Usia saat terkena virus',
                              suffix: 'Bulan',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInputField(
                              controller: _virusJenisController,
                              label: 'Jenis virus',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),

// Perkembangan Motorik
                _buildFormSection(
                  title: 'Perkembangan Motorik',
                  children: _motorikList
                      .map((item) => _buildMotorikItem(item))
                      .toList(),
                ),

                const SizedBox(height: 32),
                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.userKeluhan6);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4461F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1E25),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1A1E25),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
          suffixText: suffix,
          suffixStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4461F2)),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1E25),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMotorikItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: item['done'],
            onChanged: (value) {
              setState(() {
                item['done'] = value;
              });
            },
            activeColor: const Color(0xFF4461F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item['title'],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1E25),
              ),
            ),
          ),
          if (item['done'])
            SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: item['usia']?.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  item['usia'] = value;
                },
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1E25),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Usia',
                  suffixText: 'Bln',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4461F2)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    _asiController.dispose();
    _jatuhUsiaController.dispose();
    _jatuhTinggiController.dispose();
    _sakitParahUsiaController.dispose();
    _panasTinggiUsiaController.dispose();
    _panasKejangUsiaController.dispose();
    _panasKejangFrekuensiController.dispose();
    _kejangTanpaPanasUsiaController.dispose();
    _kejangTanpaPanasFrekuensiController.dispose();
    _beratRendahUsiaController.dispose();
    _virusUsiaController.dispose();
    _virusJenisController.dispose();
    super.dispose();
  }
}
