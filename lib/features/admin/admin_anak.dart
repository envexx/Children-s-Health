import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../config/themes/style.dart';
// import '../admin/widgets/date_formater.dart';

class ChildrenListScreen extends StatefulWidget {
  const ChildrenListScreen({super.key});

  @override
  _ChildrenListScreenState createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier('');

  String formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  String formatTime(DateTime date) {
    String addLeadingZero(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${addLeadingZero(date.hour)}:${addLeadingZero(date.minute)}';
  }

// Untuk memformat timestamp
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${formatDate(date)} ${formatTime(date)}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Anak',
          style: TextStyle(
            color: Color(0xFF4461F2),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4461F2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            onPressed: () => _showAddChildForm(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama anak...',
                prefixIcon: const Icon(Icons.search),
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
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => _searchQuery.value = value,
            ),
          ),
          // Child List
          Expanded(
            child: _buildChildList(),
          ),
        ],
      ),
    );
  }

  // Memindahkan logic child list ke fungsi terpisah
  Widget _buildChildList() {
    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, searchQuery, _) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('children').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4461F2)),
              );
            }

            var children = snapshot.data?.docs ?? [];

            if (searchQuery.isNotEmpty) {
              children = children.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nama = (data['nama'] ?? '').toString().toLowerCase();
                return nama.contains(searchQuery.toLowerCase());
              }).toList();
            }

            if (children.isEmpty) {
              return _buildEmptyState(searchQuery.isEmpty);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final data = children[index].data() as Map<String, dynamic>;
                final documentId = children[index].id;
                return _buildChildCard(data, documentId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isInitialEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isInitialEmpty
                ? 'Belum ada data anak'
                : 'Tidak ada hasil pencarian',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> data, String documentId) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF4461F2).withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4461F2).withOpacity(0.1),
          child: Text(
            (data['nama'] as String? ?? '?')[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF4461F2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          data['nama'] as String? ?? 'Unnamed',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['id'] != null)
              Text(
                'ID: ${data['id']}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            if (data['umur'] != null)
              Text(
                'Umur: ${data['umur']} tahun',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            if (data['jenisKelamin'] != null)
              Text(
                'Jenis Kelamin: ${data['jenisKelamin']}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: data['userId'] != null
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data['userId'] != null
                    ? 'Terhubung dengan orang tua'
                    : 'Belum terhubung dengan orang tua',
                style: TextStyle(
                  fontSize: 12,
                  color: data['userId'] != null ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            data['userId'] != null ? Icons.link : Icons.link_off,
            color:
                data['userId'] != null ? const Color(0xFF4461F2) : Colors.grey,
            size: 20,
          ),
          onPressed: () {
            if (data['userId'] != null) {
              _showConnectionStatusDialog(context, data, documentId);
            } else {
              _showLinkUserDialog(context, documentId);
            }
          },
        ),
      ),
    );
  }

  // Deklarasi method-method yang akan diimplementasikan di part selanjutnya
  // Implementasi _showAddChildForm di dalam class _ChildrenListScreenState

  void _showAddChildForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final umurController = TextEditingController();
    String selectedJenisKelamin = 'Laki-laki';
    DateTime? selectedDate;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(
                        Icons.person_add_outlined,
                        color: Color(0xFF4461F2),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tambah Anak',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Nama Field
                  TextFormField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Color(0xFF4461F2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4461F2)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Lahir Field
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        selectedDate = picked;
                        final age =
                            DateTime.now().difference(picked).inDays ~/ 365;
                        umurController.text = age.toString();
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: umurController,
                        decoration: InputDecoration(
                          labelText: 'Umur',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Color(0xFF4461F2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF4461F2)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih tanggal lahir';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Jenis Kelamin Field
                  DropdownButtonFormField<String>(
                    value: selectedJenisKelamin,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(
                        Icons.people_outline,
                        size: 20,
                        color: Color(0xFF4461F2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF4461F2)),
                      ),
                    ),
                    items: ['Laki-laki', 'Perempuan'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        selectedJenisKelamin = newValue;
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Color(0xFF4461F2)),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Color(0xFF4461F2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate() &&
                                selectedDate != null) {
                              try {
                                // Tambah dokumen baru ke collection children
                                await _firestore.collection('children').add({
                                  'nama': namaController.text,
                                  'tanggalLahir': selectedDate,
                                  'umur': int.parse(umurController.text),
                                  'jenisKelamin': selectedJenisKelamin,
                                  'userId': null,
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Anak berhasil ditambahkan'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Error adding child: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4461F2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Implementasi _showLinkUserDialog di dalam class _ChildrenListScreenState

  void _showLinkUserDialog(BuildContext context, String documentId) {
    final searchController = TextEditingController();
    final ValueNotifier<String> searchQuery = ValueNotifier('');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.link,
                    color: Color(0xFF4461F2),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Hubungkan dengan Orang Tua',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Box
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau email...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF4461F2),
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
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) => searchQuery.value = value,
              ),
              const SizedBox(height: 20),

              // User List
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ValueListenableBuilder<String>(
                    valueListenable: searchQuery,
                    builder: (context, query, _) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('users')
                            .where('role', isEqualTo: 'patient')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Terjadi kesalahan: ${snapshot.error}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4461F2),
                              ),
                            );
                          }

                          var users = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name =
                                (data['name'] ?? '').toString().toLowerCase();
                            final email =
                                (data['email'] ?? '').toString().toLowerCase();
                            final phone =
                                (data['phone'] ?? '').toString().toLowerCase();
                            final searchLower = query.toLowerCase();

                            return name.contains(searchLower) ||
                                email.contains(searchLower) ||
                                phone.contains(searchLower);
                          }).toList();

                          if (users.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    query.isEmpty
                                        ? 'Belum ada data orang tua'
                                        : 'Tidak ada hasil pencarian',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: users.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFE5E7EB),
                            ),
                            itemBuilder: (context, index) {
                              final userData =
                                  users[index].data() as Map<String, dynamic>;
                              final userId = users[index].id;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      const Color(0xFF4461F2).withOpacity(0.1),
                                  child: Text(
                                    (userData['name'] ?? '?')[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF4461F2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  userData['name'] ?? 'Unnamed User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (userData['email'] != null)
                                      Text(
                                        userData['email'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    if (userData['phone'] != null)
                                      Text(
                                        userData['phone'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: OutlinedButton(
                                  onPressed: () =>
                                      _connectUser(context, documentId, userId),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4461F2),
                                    side: const BorderSide(
                                        color: Color(0xFF4461F2)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Hubungkan'),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper function untuk menghubungkan user
  Future<void> _connectUser(
      BuildContext context, String documentId, String userId) async {
    try {
      await _firestore.collection('children').doc(documentId).update({
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil menghubungkan dengan orang tua'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error connecting user: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Implementasi _showConnectionStatusDialog di dalam class _ChildrenListScreenState

  void _showConnectionStatusDialog(
    BuildContext context,
    Map<String, dynamic> child,
    String documentId,
  ) async {
    print('Child data received: $child'); // Debug print
    print('Document ID: $documentId'); // Debug print

    final userId = child['userId'];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anak belum terkoneksi dengan orang tua'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Tampilkan loading dialog
    showLoadingDialog(context);

    try {
      final userData = await _getUserData(userId);
      print('User data received: $userData'); // Debug print

      // Tutup loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (userData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data orang tua tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (!context.mounted) return;

      // Tampilkan dialog status koneksi
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.link,
                      color: Color(0xFF4461F2),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Status Koneksi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Connection Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Child Info Section
                      _buildConnectionInfoSection(
                        title: 'Informasi Anak',
                        icon: Icons.child_care,
                        iconColor: const Color(0xFF4461F2),
                        data: [
                          {
                            'label': 'Nama',
                            'value': child['nama'] ?? 'Tidak tersedia'
                          },
                          {'label': 'ID', 'value': documentId},
                          if (child['jenisKelamin'] != null)
                            {
                              'label': 'Jenis Kelamin',
                              'value': child['jenisKelamin']
                            },
                          if (child['umur'] != null)
                            {
                              'label': 'Umur',
                              'value': '${child['umur']} tahun'
                            },
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFE5E7EB)),
                      ),

                      // Parent Info Section
                      _buildConnectionInfoSection(
                        title: 'Informasi Orang Tua',
                        icon: Icons.person,
                        iconColor: Colors.green,
                        data: [
                          {
                            'label': 'Nama',
                            'value': userData['name'] ?? 'Tidak tersedia'
                          },
                          {
                            'label': 'Email',
                            'value': userData['email'] ?? 'Tidak tersedia'
                          },
                          {
                            'label': 'No. HP',
                            'value': userData['phone'] ?? 'Tidak tersedia'
                          },
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Connected Time Info
                      if (child['updatedAt'] != null)
                        Text(
                          'Terhubung sejak: ${_formatTimestamp(child['updatedAt'] as Timestamp)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Disconnect Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showDisconnectConfirmation(context, documentId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text(
                      'Hapus Koneksi',
                      style: TextStyle(
                        fontSize: 14,
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
    } catch (e) {
      print('Error showing connection status: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog if error occurs
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Helper widget untuk menampilkan section informasi
  Widget _buildConnectionInfoSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, String>> data,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...data.map((item) => Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    item['value']!,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

// Fungsi untuk menampilkan konfirmasi disconnect
  Future<void> _showDisconnectConfirmation(
      BuildContext context, String documentId) async {
    final confirm = await showConfirmationDialog(
      context,
      title: 'Hapus Koneksi',
      message: 'Anda yakin ingin menghapus koneksi dengan orang tua?',
      confirmText: 'Hapus',
      isDestructive: true,
    );

    if (confirm && context.mounted) {
      try {
        // Tampilkan loading
        showLoadingDialog(context);

        // Update document
        await _firestore.collection('children').doc(documentId).update({
          'userId': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          // Tutup loading dialog
          Navigator.pop(context);
          // Tutup dialog status koneksi
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Koneksi berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error disconnecting user: $e');
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Helper methods akan diimplementasikan di Part 5
  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF4461F2)),
                SizedBox(height: 16),
                Text(
                  'Memproses...',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Tidak',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              isDestructive
                  ? Icons.warning_rounded
                  : Icons.help_outline_rounded,
              color: isDestructive ? Colors.red : const Color(0xFF4461F2),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? Colors.red : const Color(0xFF4461F2),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
