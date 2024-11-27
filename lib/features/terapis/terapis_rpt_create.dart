// PART 1: Imports, Models & Widget Declaration
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityItem {
  String text = '';
  double? rating;
  bool isValid() => text.isNotEmpty;
}

class SubtitleItem {
  String text = '';
  List<ActivityItem> activities = [ActivityItem()];
  bool isValid() =>
      text.isNotEmpty && activities.every((activity) => activity.isValid());
}

class TitleSection {
  String title = '';
  List<SubtitleItem> subtitles = [SubtitleItem()];
  bool isValid() =>
      title.isNotEmpty && subtitles.every((subtitle) => subtitle.isValid());
}

class TerapisRptCreate extends StatefulWidget {
  const TerapisRptCreate({Key? key}) : super(key: key);

  @override
  State<TerapisRptCreate> createState() => _TerapisRptCreateState();
}

// PART 2: State Class Implementation and Variables
class _TerapisRptCreateState extends State<TerapisRptCreate> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();

  bool _isLoading = true;
  String? _selectedChildId;
  String? _selectedChildName;
  String? _therapistId;
  String? _therapistName;
  String _selectedTerapiType = 'Terapi Wicara';
  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> _children = [];
  List<TitleSection> _titleSections = [TitleSection()];

  final List<String> _terapiTypes = [
    'Terapi Wicara',
    'Okupasi Terapis',
    'Sensori Integrasi',
    'Behavior Terapi',
    'Neuro Senso',
    'Fisioterapi'
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tujuanController.dispose();
    super.dispose();
  }

  // PART 3: Data Initialization Methods
  Future<void> _initializeData() async {
    try {
      await _getTherapistData();
      await _loadChildren();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getTherapistData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final therapistDoc = await _firestore
          .collection('terapis')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (therapistDoc.docs.isNotEmpty) {
        final therapist = therapistDoc.docs.first;
        setState(() {
          _therapistId = therapist.id;
          _therapistName = therapist.data()['nama'] as String?;
        });
      }
    } catch (e) {
      print('Error getting therapist data: $e');
      throw e;
    }
  }

  Future<void> _loadChildren() async {
    try {
      final snapshot = await _firestore.collection('children').get();
      setState(() {
        _children = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'nama': doc.data()['nama'] as String? ?? '',
                })
            .toList();
      });
    } catch (e) {
      print('Error loading children: $e');
      throw e;
    }
  }

  // PART 4: UI Building Methods
  Widget _buildChildSelection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Anak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1E25),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama anak...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _isSearching = true;
              });
            },
          ),
          if (_selectedChildId != null && !_isSearching)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4461F2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Color(0xFF4461F2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedChildName ?? '',
                      style: const TextStyle(
                        color: Color(0xFF4461F2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF4461F2),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedChildId = null;
                        _selectedChildName = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          if (_searchQuery.isNotEmpty && _isSearching)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListView(
                  shrinkWrap: true,
                  children: _children
                      .where((child) => child['nama']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .map((child) => ListTile(
                            title: Text(child['nama']),
                            onTap: () {
                              setState(() {
                                _selectedChildId = child['id'];
                                _selectedChildName = child['nama'];
                                _searchController.clear();
                                _searchQuery = '';
                                _isSearching = false;
                              });
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // PART 5: Title Section and Terapi Type UI Methods
  Widget _buildTerapiTypeSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Terapi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1E25),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedTerapiType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: _terapiTypes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTerapiType = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTujuanProgramSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tujuan Program',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1E25),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tujuanController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Masukkan tujuan program terapi',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(TitleSection section) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4461F2).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4461F2).withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: section.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1E25),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Judul Kategori',
                      hintStyle: TextStyle(
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                        fontWeight: FontWeight.normal,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFF4461F2).withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFF4461F2).withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF4461F2),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      section.title = value;
                    },
                  ),
                ),
                if (_titleSections.length > 1)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _titleSections.remove(section);
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Subtitles Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                ...section.subtitles.map((subtitle) => Column(
                      children: [
                        _buildSubtitleField(subtitle, section),
                        const SizedBox(height: 12),
                      ],
                    )),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        section.subtitles.add(SubtitleItem());
                      });
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF4461F2),
                    ),
                    label: const Text(
                      'Tambah Sub Kategori',
                      style: TextStyle(
                        color: Color(0xFF4461F2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleField(SubtitleItem subtitle, TitleSection section) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: subtitle.text,
                  decoration: InputDecoration(
                    hintText: 'Sub Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    subtitle.text = value;
                  },
                ),
              ),
              if (section.subtitles.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: () {
                    setState(() {
                      section.subtitles.remove(subtitle);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...subtitle.activities
              .map((activity) => _buildActivityItem(activity, subtitle)),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  subtitle.activities.add(ActivityItem());
                });
              },
              icon: const Icon(
                Icons.add_task,
                color: Color(0xFF4461F2),
                size: 20,
              ),
              label: const Text('Tambah Kegiatan'),
            ),
          ),
        ],
      ),
    );
  }

  // PART 6: Activity Items and Save Methods
  Widget _buildActivityItem(ActivityItem activity, SubtitleItem subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              initialValue: activity.text,
              decoration: const InputDecoration(
                hintText: 'Deskripsi Kegiatan',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                activity.text = value;
              },
            ),
          ),
          if (subtitle.activities.length > 1)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              onPressed: () {
                setState(() {
                  subtitle.activities.remove(activity);
                });
              },
            ),
        ],
      ),
    );
  }

  Future<void> _saveRPT() async {
    if (_therapistId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data terapis tidak ditemukan')),
      );
      return;
    }

    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih anak terlebih dahulu')),
      );
      return;
    }

    if (_tujuanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi tujuan program')),
      );
      return;
    }

    if (_titleSections.any((section) => !section.isValid())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua bagian RPT')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rptRef = await _firestore.collection('rpts').add({
        'childId': _selectedChildId,
        'childName': _selectedChildName,
        'therapistId': _therapistId,
        'therapistName': _therapistName,
        'terapiType': _selectedTerapiType,
        'tujuanProgram': _tujuanController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'createdBy': _therapistId,
        'lastModifiedBy': _therapistId,
        'reviewStatus': {
          'isReviewed': false,
          'reviewedAt': null,
          'reviewedBy': null,
          'reviewNotes': null,
        }
      });

      // Save titles, subtitles, and activities
      for (var titleSection in _titleSections) {
        final titleRef = await rptRef.collection('titles').add({
          'title': titleSection.title,
          'createdAt': FieldValue.serverTimestamp(),
          'isCompleted': false,
        });

        for (var subtitle in titleSection.subtitles) {
          final subtitleRef = await titleRef.collection('subtitles').add({
            'subtitle': subtitle.text,
            'createdAt': FieldValue.serverTimestamp(),
            'isCompleted': false,
          });

          for (var activity in subtitle.activities) {
            await subtitleRef.collection('activities').add({
              'description': activity.text,
              'rating': activity.rating,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'isCompleted': false,
            });
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('RPT berhasil disimpan dan menunggu review dari admin'),
            backgroundColor: Color(0xFFFB923C), // Warna orange untuk pending
          ),
        );
      }
    } catch (e) {
      print('Error saving RPT: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan RPT. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // PART 7: Build Method
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4461F2),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Buat RPT Baru',
          style: TextStyle(
            color: Color(0xFF4461F2),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveRPT,
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Color(0xFF4461F2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildChildSelection(),
          const SizedBox(height: 24),
          _buildTerapiTypeSection(),
          const SizedBox(height: 24),
          _buildTujuanProgramSection(),
          const SizedBox(height: 24),
          ..._titleSections.map((section) => Column(
                children: [
                  _buildTitleSection(section),
                  const SizedBox(height: 16),
                ],
              )),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _titleSections.add(TitleSection());
                });
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF4461F2),
              ),
              label: const Text(
                'Tambah Kategori',
                style: TextStyle(
                  color: Color(0xFF4461F2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
