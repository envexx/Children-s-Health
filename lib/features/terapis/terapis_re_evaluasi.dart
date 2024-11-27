import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/routes/app_routes.dart';

class TerapisReEvaluasi extends StatefulWidget {
  final String terapisId;

  const TerapisReEvaluasi({
    Key? key,
    required this.terapisId,
  }) : super(key: key);

  @override
  State<TerapisReEvaluasi> createState() => _TerapisReEvaluasiState();
}

class _TerapisReEvaluasiState extends State<TerapisReEvaluasi> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  List<DocumentSnapshot> _rptDocs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRPTs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRPTs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final snapshot = await _firestore
          .collection('rpts')
          .where('createdBy', isEqualTo: widget.terapisId)
          .get();

      List<DocumentSnapshot> docs = snapshot.docs;
      docs.sort((a, b) {
        final aDate =
            (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
        final bDate =
            (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
        return bDate.compareTo(aDate);
      });

      setState(() {
        _rptDocs = docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<DocumentSnapshot> _getFilteredDocs() {
    if (_searchQuery.isEmpty) return _rptDocs;

    return _rptDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['childName']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
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

  Widget _buildReEvaluasiCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final childName = data['childName'] ?? 'Unknown Child';
    final reviewStatus = data['reviewStatus'] ?? {};
    final isReviewed = reviewStatus['isReviewed'] ?? false;
    final createdAt = data['createdAt'] as Timestamp;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.terapisReEvaluasiDetail,
              arguments: {
                'rptId': doc.id,
                'childName': childName,
                'reviewStatus': reviewStatus,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isReviewed
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFFB923C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isReviewed
                        ? Icons.check_circle_outline
                        : Icons.pending_outlined,
                    size: 24,
                    color: isReviewed
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFB923C),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        childName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1E25),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(createdAt.toDate()),
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
                    color: isReviewed
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFFB923C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isReviewed ? 'Re-Evaluasi' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isReviewed
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFB923C),
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4461F2)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Terjadi kesalahan saat memuat data',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadRPTs,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final filteredDocs = _getFilteredDocs();

    if (filteredDocs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada data re-evaluasi yang ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) =>
          _buildReEvaluasiCard(filteredDocs[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Re-Evaluasi RPT',
          style: TextStyle(
            color: Color(0xFF1A1E25),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF1A1E25),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRPTs,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildContent(),
          ],
        ),
      ),
    );
  }
}
