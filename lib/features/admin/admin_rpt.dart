import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRpt extends StatefulWidget {
  const AdminRpt({Key? key}) : super(key: key);

  @override
  State<AdminRpt> createState() => _AdminRptState();
}

class _AdminRptState extends State<AdminRpt> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, int>> _getRptCounts(String terapisId) async {
    try {
      final QuerySnapshot rptSnapshot = await _firestore
          .collection('rpts')
          .where('therapistId', isEqualTo: terapisId)
          .get();

      int pendingCount = 0;
      int activeCount = 0;
      int completedCount = 0;

      for (var doc in rptSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status']?.toString().toLowerCase() ?? '';

        switch (status) {
          case 'pending':
            pendingCount++;
            break;
          case 'active':
            activeCount++;
            break;
          case 'completed':
            completedCount++;
            break;
        }
      }

      return {
        'pending': pendingCount,
        'active': activeCount,
        'completed': completedCount,
      };
    } catch (e) {
      print('Error getting RPT counts: $e');
      return {
        'pending': 0,
        'active': 0,
        'completed': 0,
      };
    }
  }

  Widget _buildStatusBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF4461F2),
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('terapis').orderBy('nama').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text('Terjadi kesalahan dalam memuat data'),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4461F2)),
              );
            }

            final terapis = snapshot.data?.docs ?? [];

            if (terapis.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('Belum ada data terapis'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: terapis.length,
              itemBuilder: (context, index) {
                final doc = terapis[index];
                final data = doc.data();
                final String terapisId = doc.id;
                final String terapisName =
                    data['nama'] ?? 'Nama tidak tersedia';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/admin/rpt/list',
                          arguments: <String, String>{
                            'terapisId': terapisId,
                            'terapisName': terapisName,
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4461F2)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF4461F2),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        terapisName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        data['spesialisasi'] ??
                                            'Spesialisasi tidak tersedia',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<Map<String, int>>(
                              future: _getRptCounts(terapisId),
                              builder: (context, countSnapshot) {
                                final counts = countSnapshot.data ??
                                    {
                                      'pending': 0,
                                      'active': 0,
                                      'completed': 0,
                                    };

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildStatusBadge(
                                      'Pending',
                                      counts['pending']!,
                                      const Color(0xFFFB923C),
                                    ),
                                    _buildStatusBadge(
                                      'Aktif',
                                      counts['active']!,
                                      const Color(0xFF4461F2),
                                    ),
                                    _buildStatusBadge(
                                      'Selesai',
                                      counts['completed']!,
                                      const Color(0xFF10B981),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
