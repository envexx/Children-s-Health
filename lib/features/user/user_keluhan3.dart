// lib/features/user/screens/user_keluhan3.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/routes/app_routes.dart';

class UserKeluhan3 extends StatefulWidget {
  // Ubah nama class
  const UserKeluhan3({super.key});

  @override
  State<UserKeluhan3> createState() => _UserKeluhan3State();
}

class _UserKeluhan3State extends State<UserKeluhan3> {
  final _formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('dd-MM-yyyy');

  // Controllers untuk data ibu
  final _namaIbuController = TextEditingController();
  final _tempatLahirIbuController = TextEditingController();
  final _tanggalLahirIbuController = TextEditingController();
  final _kewarganegaraanController = TextEditingController();
  final _alamatController = TextEditingController();
  final _anakKeController = TextEditingController();
  final _jumlahSaudaraController = TextEditingController();
  final _pernikahanController = TextEditingController();
  final _usiaMenikahController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _pendidikanController = TextEditingController();
  final _teleponController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedAgama;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Data Ibu',
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
                  value: 0.42, // 3/7 progress
                  backgroundColor: Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4461F2)),
                ),
                const SizedBox(height: 24),

                // Title Section
                Text(
                  'Data Ibu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF1A1E25),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi data ibu berikut',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildInputField(
                  controller: _namaIbuController,
                  label: 'Nama Ibu',
                  hint: 'Masukkan nama lengkap ibu',
                ),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInputField(
                        controller: _tempatLahirIbuController,
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
                              _tanggalLahirIbuController.text =
                                  dateFormat.format(picked);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: _buildInputField(
                            controller: _tanggalLahirIbuController,
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

                _buildInputField(
                  controller: _kewarganegaraanController,
                  label: 'Kewarganegaraan',
                  hint: 'Masukkan kewarganegaraan',
                ),

                _buildDropdownField(
                  label: 'Agama',
                  hint: 'Pilih agama',
                  items: const [
                    'Islam',
                    'Kristen',
                    'Katolik',
                    'Hindu',
                    'Buddha',
                    'Konghucu'
                  ],
                  value: _selectedAgama,
                  onChanged: (val) => setState(() => _selectedAgama = val),
                ),

                _buildInputField(
                  controller: _alamatController,
                  label: 'Alamat Rumah',
                  hint: 'Masukkan alamat lengkap',
                  maxLines: 2,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _anakKeController,
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

                _buildInputField(
                  controller: _pernikahanController,
                  label: 'Pernikahan',
                  hint: 'Status pernikahan',
                ),

                _buildInputField(
                  controller: _usiaMenikahController,
                  label: 'Usia Saat Menikah',
                  hint: 'Tahun',
                  keyboardType: TextInputType.number,
                ),

                _buildInputField(
                  controller: _pekerjaanController,
                  label: 'Pekerjaan Saat ini',
                  hint: 'Masukkan pekerjaan',
                ),

                _buildInputField(
                  controller: _pendidikanController,
                  label: 'Pendidikan Terakhir',
                  hint: 'Masukkan pendidikan terakhir',
                ),

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
                        Navigator.pushNamed(context, AppRoutes.userKeluhan4);
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

  // Helper Methods dengan styling yang sudah diupdate
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
    required String hint,
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
        hint: Text(
          hint,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
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
    _namaIbuController.dispose();
    _tempatLahirIbuController.dispose();
    _tanggalLahirIbuController.dispose();
    _kewarganegaraanController.dispose();
    _alamatController.dispose();
    _anakKeController.dispose();
    _jumlahSaudaraController.dispose();
    _pernikahanController.dispose();
    _usiaMenikahController.dispose();
    _pekerjaanController.dispose();
    _pendidikanController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
