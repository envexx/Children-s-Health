// lib/features/user/screens/user_keluhan2.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/routes/app_routes.dart';

class UserKeluhan2 extends StatefulWidget {
  const UserKeluhan2({super.key});

  @override
  State<UserKeluhan2> createState() => _UserKeluhan2State();
}

class _UserKeluhan2State extends State<UserKeluhan2> {
  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('dd-MM-yyyy');

  // Controller untuk tanggal pemeriksaan
  final _tanggalPemeriksaanController = TextEditingController();

  // Controllers untuk data saudara (dinamis)
  List<Map<String, TextEditingController>> _saudaraControllers = [
    {
      'nama': TextEditingController(),
      'jenisKelamin': TextEditingController(),
      'usia': TextEditingController(),
      'pendidikan': TextEditingController(),
    }
  ];

  // Controllers untuk identitas ayah
  final _namaAyahController = TextEditingController();
  final _tempatLahirAyahController = TextEditingController();
  final _tanggalLahirAyahController = TextEditingController();
  final _usiaAyahController = TextEditingController();
  final _kewarganegaraanController = TextEditingController();
  final _alamatAyahController = TextEditingController();
  final _anakKeAyahController = TextEditingController();
  final _jumlahSaudaraController = TextEditingController();
  final _pernikahanKeController = TextEditingController();
  final _usiaMenikahController = TextEditingController();
  final _pendidikanAyahController = TextEditingController();
  final _pekerjaanAyahController = TextEditingController();
  final _teleponController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Data Keluarga',
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
                  value: 0.28, // 2/7 progress
                  backgroundColor: Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4461F2)),
                ),
                const SizedBox(height: 24),

                // Title Section
                Text(
                  'Data Keluarga',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF1A1E25),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi data keluarga berikut',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                // Tanggal Pemeriksaan
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _tanggalPemeriksaanController.text =
                            dateFormat.format(picked);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: _buildInputField(
                      controller: _tanggalPemeriksaanController,
                      label: 'Tanggal Pemeriksaan',
                      hint: 'DD-MM-YYYY',
                      suffixIcon: const Icon(Icons.calendar_today,
                          size: 18, color: Color(0xFF4461F2)),
                    ),
                  ),
                ),

                _buildSectionTitle('Daftar Urutan Saudara'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _saudaraControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildInputField(
                                  controller: _saudaraControllers[index]
                                      ['nama']!,
                                  label: 'Nama',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'L/P',
                                  items: const ['L', 'P'],
                                  value: null,
                                  onChanged: (val) {},
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _saudaraControllers[index]
                                      ['usia']!,
                                  label: 'Usia',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: _buildInputField(
                                  controller: _saudaraControllers[index]
                                      ['pendidikan']!,
                                  label: 'Pendidikan/Pekerjaan',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Add & Delete Saudara Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _saudaraControllers.add({
                            'nama': TextEditingController(),
                            'jenisKelamin': TextEditingController(),
                            'usia': TextEditingController(),
                            'pendidikan': TextEditingController(),
                          });
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline,
                          color: Color(0xFF4461F2)),
                      label: const Text(
                        'Tambah Saudara',
                        style: TextStyle(
                          color: Color(0xFF4461F2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_saudaraControllers.length >
                        1) // Tampilkan delete button jika ada lebih dari 1 saudara
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            // Dispose controller terakhir sebelum dihapus
                            _saudaraControllers.last.values
                                .forEach((controller) => controller.dispose());
                            _saudaraControllers.removeLast();
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        label: const Text(
                          'Hapus Saudara',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                _buildSectionTitle('Identitas Orangtua/Wali'),
                _buildInputField(
                  controller: _namaAyahController,
                  label: 'Nama Ayah',
                  hint: 'Masukkan nama ayah',
                ),

                // Tempat & Tanggal Lahir
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInputField(
                        controller: _tempatLahirAyahController,
                        label: 'Tempat Lahir',
                        hint: 'Masukkan tempat lahir',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _tanggalLahirAyahController.text =
                                  dateFormat.format(picked);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: _buildInputField(
                            controller: _tanggalLahirAyahController,
                            label: 'Tanggal Lahir',
                            hint: 'DD-MM-YYYY',
                            suffixIcon: const Icon(Icons.calendar_today,
                                size: 18, color: Color(0xFF4461F2)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Usia & Kewarganegaraan
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _usiaAyahController,
                        label: 'Usia',
                        hint: 'Tahun',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildInputField(
                        controller: _kewarganegaraanController,
                        label: 'Kewarganegaraan',
                        hint: 'Masukkan kewarganegaraan',
                      ),
                    ),
                  ],
                ),

                // Alamat
                _buildInputField(
                  controller: _alamatAyahController,
                  label: 'Alamat Rumah',
                  hint: 'Masukkan alamat lengkap',
                  maxLines: 2,
                ),

                // Anak Ke & Jumlah Saudara
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _anakKeAyahController,
                        label: 'Anak Ke-',
                        hint: 'No',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('dari',
                          style: TextStyle(color: Color(0xFF6B7280))),
                    ),
                    Expanded(
                      child: _buildInputField(
                        controller: _jumlahSaudaraController,
                        label: 'Jumlah Saudara',
                        hint: 'Total',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // Pernikahan Ke & Usia Menikah
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _pernikahanKeController,
                        label: 'Pernikahan Ke-',
                        hint: 'No',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _usiaMenikahController,
                        label: 'Usia Saat Menikah',
                        hint: 'Tahun',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // Pendidikan & Pekerjaan
                _buildInputField(
                  controller: _pendidikanAyahController,
                  label: 'Pendidikan Terakhir',
                  hint: 'Masukkan pendidikan terakhir',
                ),
                _buildInputField(
                  controller: _pekerjaanAyahController,
                  label: 'Pekerjaan Saat Ini',
                  hint: 'Masukkan pekerjaan',
                ),

                // Kontak
                _buildInputField(
                  controller: _teleponController,
                  label: 'No. Telepon/HP',
                  hint: 'Masukkan nomor telepon',
                  keyboardType: TextInputType.phone,
                ),
                _buildInputField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan alamat email',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 32),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pushNamed(context, AppRoutes.userKeluhan3);
                      }
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

  // Helper methods untuk section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 24),
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

// Helper Widgets
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool isRequired = false,
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
    // Dispose semua controllers
    _tanggalPemeriksaanController.dispose();

    // Dispose saudara controllers
    for (var controllerMap in _saudaraControllers) {
      controllerMap.values.forEach((controller) => controller.dispose());
    }

    // Dispose identitas ayah controllers
    _namaAyahController.dispose();
    _tempatLahirAyahController.dispose();
    _tanggalLahirAyahController.dispose();
    _usiaAyahController.dispose();
    _kewarganegaraanController.dispose();
    _alamatAyahController.dispose();
    _anakKeAyahController.dispose();
    _jumlahSaudaraController.dispose();
    _pernikahanKeController.dispose();
    _usiaMenikahController.dispose();
    _pendidikanAyahController.dispose();
    _pekerjaanAyahController.dispose();
    _teleponController.dispose();
    _emailController.dispose();

    super.dispose();
  }
}
