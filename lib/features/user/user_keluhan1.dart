// lib/features/user/screens/user_keluhan1.dart
import 'package:flutter/material.dart';
import '../../../config/routes/app_routes.dart';

class UserKeluhan1 extends StatefulWidget {
  const UserKeluhan1({super.key});

  @override
  State<UserKeluhan1> createState() => _UserKeluhan1State();
}

class _UserKeluhan1State extends State<UserKeluhan1> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk survei
  String? _selectedSumber;
  String? _selectedObservasi;
  String? _selectedAssessment;

  // Controllers untuk keluhan dan tindakan
  final List<TextEditingController> _keluhanControllers =
      List.generate(3, (i) => TextEditingController());
  final List<TextEditingController> _tindakanControllers =
      List.generate(3, (i) => TextEditingController());

  // Controllers untuk identitas anak
  final _namaAnakController = TextEditingController();
  final _namaPanggilanController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _usiaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _anakKeController = TextEditingController();
  final _sekolahController = TextEditingController();
  String? _selectedAgama;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Form Survei',
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
                  value: 0.14, // 1/7 progress
                  backgroundColor: Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4461F2)),
                ),
                const SizedBox(height: 24),

                // Title Section
                Text(
                  'Informasi Awal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF1A1E25),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silahkan isi informasi dasar berikut',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                ),
                const SizedBox(height: 32),

                // Survei Section
                _buildSectionTitle('Survey Awal'),
                _buildDropdownField(
                  label: 'Mengetahui YAMET dari',
                  hint: 'Pilih sumber informasi',
                  items: const ['Media Sosial', 'Teman', 'Keluarga', 'Lainnya'],
                  value: _selectedSumber,
                  onChanged: (val) => setState(() => _selectedSumber = val),
                ),
                _buildDropdownField(
                  label: 'Sudah dijelaskan mekanisme observasi',
                  hint: 'Pilih jawaban',
                  items: const ['Ya', 'Tidak'],
                  value: _selectedObservasi,
                  onChanged: (val) => setState(() => _selectedObservasi = val),
                ),
                _buildDropdownField(
                  label: 'Bersedia assessment online',
                  hint: 'Pilih jawaban',
                  items: const ['Ya', 'Tidak'],
                  value: _selectedAssessment,
                  onChanged: (val) => setState(() => _selectedAssessment = val),
                ),

                const SizedBox(height: 32),

                // Keluhan Section
                _buildSectionTitle('Keluhan Utama'),
                ...List.generate(
                  3,
                  (index) => _buildInputField(
                    controller: _keluhanControllers[index],
                    label: 'Keluhan ${index + 1}',
                    hint: 'Masukkan keluhan utama anak',
                    maxLines: 2,
                  ),
                ),

                const SizedBox(height: 32),

                // Tindakan Section
                _buildSectionTitle('Tindakan yang Sudah Dilakukan'),
                ...List.generate(
                  3,
                  (index) => _buildInputField(
                    controller: _tindakanControllers[index],
                    label: 'Tindakan ${index + 1}',
                    hint: 'Masukkan tindakan yang sudah dilakukan',
                    maxLines: 2,
                  ),
                ),

                const SizedBox(height: 32),

                // Identitas Anak Section
                _buildSectionTitle('Identitas Anak'),

                // Nama Lengkap dan Panggilan
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _namaAnakController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _namaPanggilanController,
                        label: 'Nama Panggilan',
                        hint: 'Masukkan panggilan',
                      ),
                    ),
                  ],
                ),

                // Tempat, Tanggal Lahir dan Usia
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInputField(
                        controller: _tempatLahirController,
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
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _tanggalLahirController.text =
                                  "${picked.day}-${picked.month}-${picked.year}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: _buildInputField(
                            controller: _tanggalLahirController,
                            label: 'Tanggal Lahir',
                            hint: 'DD-MM-YYYY',
                            suffixIcon:
                                const Icon(Icons.calendar_today, size: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _usiaController,
                        label: 'Usia',
                        hint: 'Tahun',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // Agama dan Anak Ke-
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
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
                        onChanged: (val) =>
                            setState(() => _selectedAgama = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _anakKeController,
                        label: 'Anak Ke-',
                        hint: 'Urutan anak',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // Alamat dan Sekolah
                _buildInputField(
                  controller: _alamatController,
                  label: 'Alamat',
                  hint: 'Masukkan alamat lengkap',
                  maxLines: 2,
                ),

                _buildInputField(
                  controller: _sekolahController,
                  label: 'Sekolah/Kelas',
                  hint: 'Masukkan nama sekolah dan kelas',
                ),

                const SizedBox(height: 32),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pushNamed(context, AppRoutes.userKeluhan2);
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
    for (var controller in _keluhanControllers) {
      controller.dispose();
    }
    for (var controller in _tindakanControllers) {
      controller.dispose();
    }
    _namaAnakController.dispose();
    _namaPanggilanController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _usiaController.dispose();
    _alamatController.dispose();
    _anakKeController.dispose();
    _sekolahController.dispose();
    super.dispose();
  }
}
