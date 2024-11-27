import 'package:flutter/material.dart';
import '../../../config/routes/app_routes.dart';

class UserKeluhan6 extends StatefulWidget {
  const UserKeluhan6({super.key});

  @override
  State<UserKeluhan6> createState() => _UserKeluhan6State();
}

class _UserKeluhan6State extends State<UserKeluhan6> {
  final _formKey = GlobalKey<FormState>();

  // Data perkembangan bahasa
  final List<Map<String, dynamic>> _perkembanganBahasaList = [
    {'title': 'Reflek Vokalisasi (spt lenguhan)', 'done': false, 'usia': ''},
    {'title': 'Bubbling (bababa...mamama)', 'done': false, 'usia': ''},
    {
      'title': 'Laling (lebih jelas mengucapkan satu suku kata)',
      'done': false,
      'usia': ''
    },
    {'title': 'Echolalia (Meniru ucapan)', 'done': false, 'usia': ''},
    {'title': 'Mengucapkan 1 Kata', 'done': false, 'usia': ''},
    {
      'title': 'True speech (mengucap kata dan mengerti maksudnya)',
      'done': false,
      'usia': ''
    },
    {
      'title': 'Mengungkapkan keinginan minimal 2 kata',
      'done': false,
      'usia': ''
    },
    {'title': 'Bercerita', 'done': false, 'usia': ''},
  ];

  // Controllers untuk pola makan
  String? _selectedPolaMakanTeratur;
  String? _selectedPantanganMakanan;
  final _pantanganMakananController = TextEditingController();
  final _keteranganMakananController = TextEditingController();

  // Controllers untuk perkembangan sosial
  final _perilakuOrangBaruController = TextEditingController();
  final _perilakuTemanSeumurController = TextEditingController();
  final _perilakuAnakMudaController = TextEditingController();
  final _perilakuOrangTuaController = TextEditingController();
  String? _selectedBermainBanyakAnak;
  final _keteranganSosialController = TextEditingController();

  // Controllers untuk pola tidur
  String? _selectedTidurTeratur;
  String? _selectedSeringTerbangun;
  final _jamTidurMalamController = TextEditingController();
  final _jamBangunController = TextEditingController();

  // Controllers untuk riwayat penyakit
  String? _selectedSakitTelinga;
  final _sakitTelingaUsiaController = TextEditingController();
  final _sakitTelingaPenjelasanController = TextEditingController();

  String? _selectedSakitPencernaan;
  final _sakitPencernaanUsiaController = TextEditingController();
  final _sakitPencernaanPenjelasanController = TextEditingController();

  String? _selectedSakitMata;
  final _sakitMataUsiaController = TextEditingController();
  final _sakitMataPenjelasanController = TextEditingController();

  String? _selectedLukaKepala;
  final _lukaKepalaUsiaController = TextEditingController();
  final _penyakitLainnyaController = TextEditingController();

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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Perkembangan Bahasa
              _buildFormSection(
                title: 'Perkembangan Bahasa',
                children: _perkembanganBahasaList.map((item) {
                  return _buildCheckboxField(item);
                }).toList(),
              ),

              // Pola Makan
              _buildFormSection(
                title: 'Pola Makan',
                children: [
                  _buildDropdownField(
                    value: _selectedPolaMakanTeratur,
                    label: 'Pola Makan Teratur',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedPolaMakanTeratur = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    value: _selectedPantanganMakanan,
                    label: 'Pantangan Makanan',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedPantanganMakanan = val);
                    },
                  ),
                  if (_selectedPantanganMakanan == 'Ya') ...[
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _pantanganMakananController,
                      label: 'Sebutkan Pantangan Makanan',
                      maxLines: 2,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _keteranganMakananController,
                    label: 'Keterangan Lainnya',
                    maxLines: 3,
                    isOptional: true,
                  ),
                ],
              ),

              // Perkembangan Sosial
              _buildFormSection(
                title: 'Perkembangan Sosial',
                children: [
                  _buildInputField(
                    controller: _perilakuOrangBaruController,
                    label: 'Perilaku saat bertemu orang baru',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _perilakuTemanSeumurController,
                    label: 'Perilaku saat bertemu teman seumur',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _perilakuAnakMudaController,
                    label: 'Perilaku saat bertemu anak yang lebih muda',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _perilakuOrangTuaController,
                    label: 'Perilaku saat bertemu orang yang lebih tua',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    value: _selectedBermainBanyakAnak,
                    label: 'Bermain dengan banyak anak',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedBermainBanyakAnak = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _keteranganSosialController,
                    label: 'Keterangan Lainnya',
                    maxLines: 3,
                    isOptional: true,
                  ),
                ],
              ),

              // Kebiasaan Pola Tidur
              _buildFormSection(
                title: 'Kebiasaan Pola Tidur',
                children: [
                  _buildDropdownField(
                    value: _selectedTidurTeratur,
                    label: 'Jam tidur teratur',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedTidurTeratur = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    value: _selectedSeringTerbangun,
                    label: 'Sering terbangun',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedSeringTerbangun = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _jamTidurMalamController,
                          label: 'Jam Tidur Malam',
                          hint: 'Contoh: 21:00',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _jamBangunController,
                          label: 'Jam Bangun',
                          hint: 'Contoh: 06:00',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Penyakit yang pernah diderita
              _buildFormSection(
                title: 'Penyakit yang Pernah Diderita',
                children: [
                  // Sakit Telinga
                  _buildDropdownField(
                    value: _selectedSakitTelinga,
                    label: 'Pernah sakit pada daerah telinga',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedSakitTelinga = val);
                    },
                  ),
                  if (_selectedSakitTelinga == 'Ya') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _sakitTelingaUsiaController,
                            label: 'Usia',
                            suffix: 'Tahun',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _sakitTelingaPenjelasanController,
                            label: 'Penjelasan',
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Sakit Pencernaan
                  _buildDropdownField(
                    value: _selectedSakitPencernaan,
                    label: 'Pernah sakit pencernaan/pembuangan',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedSakitPencernaan = val);
                    },
                  ),
                  if (_selectedSakitPencernaan == 'Ya') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _sakitPencernaanUsiaController,
                            label: 'Usia',
                            suffix: 'Tahun',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _sakitPencernaanPenjelasanController,
                            label: 'Penjelasan',
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Sakit Mata
                  _buildDropdownField(
                    value: _selectedSakitMata,
                    label: 'Pernah sakit mata',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedSakitMata = val);
                    },
                  ),
                  if (_selectedSakitMata == 'Ya') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _sakitMataUsiaController,
                            label: 'Usia',
                            suffix: 'Tahun',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _sakitMataPenjelasanController,
                            label: 'Penjelasan',
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Luka Kepala
                  _buildDropdownField(
                    value: _selectedLukaKepala,
                    label: 'Pernah terluka di bagian kepala',
                    items: const ['Ya', 'Tidak'],
                    onChanged: (val) {
                      setState(() => _selectedLukaKepala = val);
                    },
                  ),
                  if (_selectedLukaKepala == 'Ya') ...[
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _lukaKepalaUsiaController,
                      label: 'Usia',
                      suffix: 'Tahun',
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _penyakitLainnyaController,
                    label: 'Penyakit yang pernah diderita lainnya',
                    maxLines: 3,
                    isOptional: true,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.pushNamed(context, AppRoutes.userKeluhan7);
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
                    'Simpan',
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

  Widget _buildCheckboxField(Map<String, dynamic> item) {
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? suffix,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
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
        validator: isOptional
            ? null
            : (value) {
                if (value == null || value.isEmpty) {
                  return 'Field ini harus diisi';
                }
                return null;
              },
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

  @override
  void dispose() {
    // Dispose all controllers
    _pantanganMakananController.dispose();
    _keteranganMakananController.dispose();
    _perilakuOrangBaruController.dispose();
    _perilakuTemanSeumurController.dispose();
    _perilakuAnakMudaController.dispose();
    _perilakuOrangTuaController.dispose();
    _keteranganSosialController.dispose();
    _jamTidurMalamController.dispose();
    _jamBangunController.dispose();
    _sakitTelingaUsiaController.dispose();
    _sakitTelingaPenjelasanController.dispose();
    _sakitPencernaanUsiaController.dispose();
    _sakitPencernaanPenjelasanController.dispose();
    _sakitMataUsiaController.dispose();
    _sakitMataPenjelasanController.dispose();
    _lukaKepalaUsiaController.dispose();
    _penyakitLainnyaController.dispose();
    super.dispose();
  }
}
