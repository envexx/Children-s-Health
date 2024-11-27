// lib/features/user/screens/user_keluhan4.dart
import 'package:flutter/material.dart';
import '../../../config/routes/app_routes.dart';

class UserKeluhan4 extends StatefulWidget {
  const UserKeluhan4({super.key});

  @override
  State<UserKeluhan4> createState() => _UserKeluhan4State();
}

class _UserKeluhan4State extends State<UserKeluhan4> {
  final _formKey = GlobalKey<FormState>();

  // Kondisi saat kehamilan
  Map<String, bool> _kondisiKehamilan = {
    'Mual/Sering Muntah/Sulit Makan': false,
    'Asupan Gizi Memadai': false,
    'Melakukan Perawatan Kehamilan': false,
    'Kehamilan Di Inginkan': false,
    'Berat Bayi Tiap Semester Normal': false,
    'Diabetes': false,
    'Hipertensi': false,
    'Asma': false,
    'TBC': false,
    'Merokok': false,
    'Tinggal/bekerja di sekitar perokok berat': false,
    'Konsumsi Alkohol': false,
    'Konsumsi Obat-obatan': false,
    'Infeksi Virus (Toxoplasma,Rubellla,CMV,Herpes,dll)': false,
    'Kecelakan/Trauma': false,
    'Pendarahan/flek': false,
    'Maslah Pernafasan': false,
  };

  // Controllers untuk riwayat kelahiran
  final _jenisKelahiranController = TextEditingController();
  final _alasanScController = TextEditingController();
  final _metodeBantuController = TextEditingController();
  final _prematurController = TextEditingController();
  final _usiaKelahiranBulanController = TextEditingController();
  final _usiaKelahiranHariController = TextEditingController();
  final _posisiKelahiranController = TextEditingController();
  final _sungsangController = TextEditingController();
  final _kuningController = TextEditingController();
  final _detakJantungController = TextEditingController();
  final _apgarScoreController = TextEditingController();
  final _lamaKelahiranController = TextEditingController();
  final _penolongController = TextEditingController();
  final _tempatBersalinController = TextEditingController();
  final _prosesKelahiranController = TextEditingController();

  // Data imunisasi
  Map<String, bool> _imunisasi = {
    'BCG 1 (lahir-2 bln)': false,
    'Hep B1 (0-2 bln)': false,
    'Hep B2 (1-4 bln)': false,
    'Hep B3 (6-18 bln)': false,
    'DPT 1 (2-4 bln)': false,
    'DPT 2 (3-5 bln)': false,
    'DPT 3 (4-6 bln)': false,
    'DPT 4 (18-24 bln)': false,
    'Polio 1 (lahir)': false,
    'Polio 2 (2-4 bln)': false,
    'Polio 3 (3-5 bln)': false,
    'Polio 4 (4-6 bln)': false,
    'Polio 5 (18-24 bln)': false,
    'Campak 1 (6-9 bln)': false,
    'Campak 2 (5-7 thn)': false,
    'Hib 1 (2 bln)': false,
    'Hib 2 (4 bln)': false,
    'Hib 3 (6 bln)': false,
    'Hib 4 (15 bln)': false,
    'MMR 1 (12-18 bln)': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Perkembangan Anak',
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
                  value: 0.57, // 4/7 progress
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
                _buildSectionTitle('Riwayat Kehamilan'),
                _buildCheckboxGroup(_kondisiKehamilan),

                const SizedBox(height: 32),

                _buildSectionTitle('Riwayat Kelahiran'),
                _buildDropdownField(
                  label: 'Jenis Kelahiran',
                  items: const ['Caesar', 'Normal'],
                  value: null,
                  onChanged: (val) {},
                ),

                _buildInputField(
                  controller: _alasanScController,
                  label: 'Alasan Caesar',
                  hint: 'Isi jika kelahiran caesar',
                  maxLines: 3,
                ),

                _buildInputField(
                  controller: _metodeBantuController,
                  label: 'Metode Bantuan',
                  hint: 'Forcep/Vacuum/Dipacur',
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _usiaKelahiranBulanController,
                        label: 'Usia Kelahiran (Bulan)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _usiaKelahiranHariController,
                        label: 'Hari',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                _buildInputField(
                  controller: _posisiKelahiranController,
                  label: 'Posisi Kelahiran',
                  hint: 'Kepala/Kaki Yang Keluar Dulu',
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Sungsang',
                        items: const ['Ya', 'Tidak'],
                        value: null,
                        onChanged: (val) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Kuning',
                        items: const ['Ya', 'Tidak'],
                        value: null,
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),

                _buildInputField(
                  controller: _detakJantungController,
                  label: 'Detak Jantung Anak',
                ),

                _buildInputField(
                  controller: _apgarScoreController,
                  label: 'APGAR Score',
                ),

                _buildInputField(
                  controller: _lamaKelahiranController,
                  label: 'Lama Waktu Melahirkan (Jam)',
                  keyboardType: TextInputType.number,
                ),

                _buildDropdownField(
                  label: 'Dibantu Oleh',
                  items: const ['Dokter', 'Bidan', 'Dukun Bayi'],
                  value: null,
                  onChanged: (val) {},
                ),

                _buildInputField(
                  controller: _tempatBersalinController,
                  label: 'Tempat Bersalin',
                ),

                _buildInputField(
                  controller: _prosesKelahiranController,
                  label: 'Ceritakan Hal Spesifik saat proses kelahiran',
                  hint: 'Opsional',
                  maxLines: 4,
                ),

                const SizedBox(height: 32),

                _buildSectionTitle('Riwayat Imunisasi'),
                _buildCheckboxGroup(_imunisasi),

                const SizedBox(height: 32),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.userKeluhan5);
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
  Widget _buildCheckboxGroup(Map<String, bool> items) {
    return Column(
      children: items.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: CheckboxListTile(
            title: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1E25),
              ),
            ),
            value: entry.value,
            onChanged: (bool? value) {
              setState(() {
                items[entry.key] = value ?? false;
              });
            },
            activeColor: const Color(0xFF4461F2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            controlAffinity: ListTileControlAffinity.leading,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1E25),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
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
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
          suffixIcon: suffixIcon,
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
    required String label,
    required List<String> items,
    required String? value,
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

  @override
  void dispose() {
    _jenisKelahiranController.dispose();
    _alasanScController.dispose();
    _metodeBantuController.dispose();
    _prematurController.dispose();
    _usiaKelahiranBulanController.dispose();
    _usiaKelahiranHariController.dispose();
    _posisiKelahiranController.dispose();
    _sungsangController.dispose();
    _kuningController.dispose();
    _detakJantungController.dispose();
    _apgarScoreController.dispose();
    _lamaKelahiranController.dispose();
    _penolongController.dispose();
    _tempatBersalinController.dispose();
    _prosesKelahiranController.dispose();
    super.dispose();
  }
}
