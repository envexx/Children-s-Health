import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../config/routes/app_routes.dart';

class TerapisRpt extends StatefulWidget {
  const TerapisRpt({Key? key}) : super(key: key);

  @override
  State<TerapisRpt> createState() => _TerapisRptState();
}

class _TerapisRptState extends State<TerapisRpt> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _localeInitialized = false;
  String? _terapisId;
  String? _terapisName;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _initializeTerapisData();
  }

  // Inisialisasi data terapis
  Future<void> _initializeTerapisData() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Ambil data terapis dari collection terapis
      final terapisDoc =
          await _firestore.collection('terapis').doc(currentUser.uid).get();

      if (terapisDoc.exists) {
        setState(() {
          _terapisId = currentUser.uid;
          _terapisName = terapisDoc.data()?['nama'] ?? 'Unknown Terapis';
        });
      }
    }
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      _localeInitialized = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(Timestamp timestamp) {
    if (!_localeInitialized) return '';
    final date = timestamp.toDate();
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFB923C); // Orange untuk pending
      case 'active':
        return const Color(0xFF4461F2); // Biru untuk active
      case 'completed':
        return const Color(0xFF10B981); // Hijau untuk completed
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.lock_outline;
      case 'active':
        return Icons.description_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.description_outlined;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Review';
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Cari nama anak...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              child: const Icon(Icons.close, color: Color(0xFF6B7280)),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return InkWell(
      onTap: () {
        if (_terapisId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.terapisRptCreate,
            arguments: {
              'terapisId': _terapisId,
              'terapisName': _terapisName,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mohon login terlebih dahulu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF4461F2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4461F2).withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buat RPT Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rencana Program Terapi untuk anak',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRPTCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = (data['status'] ?? 'pending').toLowerCase();
    final statusColor = _getStatusColor(status);
    final isLocked = status == 'pending';

    return InkWell(
      onTap: isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'RPT masih dalam proses review oleh admin',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Color(0xFFFB923C),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          : () {
              Navigator.pushNamed(
                context,
                AppRoutes.terapisRptDetail,
                arguments: doc.id,
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(status),
                size: 24,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['childName'] ?? 'Nama tidak tersedia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isLocked
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF1A1E25),
                          ),
                        ),
                      ),
                      if (isLocked)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: statusColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(data['createdAt'] as Timestamp),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['terapiType'] ?? 'Tipe terapi tidak tersedia',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLocked)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: statusColor,
                      ),
                    ),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRPTList() {
    if (_terapisId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 48,
                color: Color(0xFF6B7280),
              ),
              SizedBox(height: 16),
              Text(
                'Mohon login terlebih dahulu',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      // Mengubah field name dari 'terapisId' menjadi 'therapistId'
      stream: _firestore
          .collection('rpts')
          .where('therapistId', isEqualTo: _terapisId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi kesalahan saat memuat data',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4461F2)),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final sortedDocs = List.from(docs)
          ..sort((a, b) {
            final aDate =
                (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
            final bDate =
                (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
            return bDate.compareTo(aDate); // descending order
          });

        final filteredDocs = sortedDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['childName']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        // Empty state ketika tidak ada data RPT
        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data RPT',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silakan buat RPT baru dengan menekan tombol di atas',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state untuk hasil pencarian yang tidak ditemukan
        if (filteredDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada RPT dengan nama anak "$_searchQuery"',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) => _buildRPTCard(filteredDocs[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header with Terapis Name
          if (_terapisName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Color(0xFF4461F2),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Terapis: $_terapisName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1E25),
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 24),

          // Create New RPT Button
          _buildCreateButton(),
          const SizedBox(height: 32),

          // RPT List Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat RPT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E25),
                ),
              ),
              // Badge untuk jumlah RPT aktif (opsional)
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('rpts')
                    .where('terapisId', isEqualTo: _terapisId)
                    .where('status', isEqualTo: 'active')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final activeCount = snapshot.data?.docs.length ?? 0;
                  if (activeCount == 0) return const SizedBox();

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4461F2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: Color(0xFF4461F2),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$activeCount RPT Aktif',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4461F2),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // RPT List
          _buildRPTList(),
        ],
      ),

      // FloatingActionButton untuk refresh (opsional)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Refresh state
            _searchQuery = '';
            _searchController.clear();
          });
        },
        backgroundColor: const Color(0xFF4461F2),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
