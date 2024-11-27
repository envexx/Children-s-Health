import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/routes/app_routes.dart';

class TerapisDashboard extends StatefulWidget {
  final String terapisId;
  const TerapisDashboard({
    Key? key,
    required this.terapisId,
  }) : super(key: key);

  @override
  State<TerapisDashboard> createState() => _TerapisDashboardState();
}

class _TerapisDashboardState extends State<TerapisDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'totalRPT': 0,
    'activeRPT': 0,
    'reviewRPT': 0,
  };
  String _terapisName = '';
  DateTime? _lastLogin;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadTerapisInfo();
  }

  Future<void> _loadTerapisInfo() async {
    try {
      final terapisDoc =
          await _firestore.collection('terapis').doc(widget.terapisId).get();

      if (mounted && terapisDoc.exists) {
        setState(() {
          _terapisName = terapisDoc.data()?['nama'] ?? 'Terapis';
          _lastLogin =
              (terapisDoc.data()?['lastLogin'] as Timestamp?)?.toDate();
        });
      }
    } catch (e) {
      print('Error loading terapis info: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final rptSnapshot = await _firestore
          .collection('rpts')
          .where('therapistId', isEqualTo: widget.terapisId)
          .get();

      if (mounted) {
        final active = rptSnapshot.docs
            .where((doc) => doc.data()['status'] == 'active')
            .length;
        final review = rptSnapshot.docs
            .where((doc) => doc.data()['status'] == 'pending')
            .length;

        setState(() {
          _stats = {
            'totalRPT': rptSnapshot.docs.length,
            'activeRPT': active,
            'reviewRPT': review,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Error loading stats: $e');
    }
  }

  void _navigateToDataList(BuildContext context, String type) {
    switch (type) {
      case 'anak':
        Navigator.pushNamed(context, AppRoutes.terapisRpt);
        break;
      case 'rpt':
        Navigator.pushNamed(context, AppRoutes.terapisRpt);
        break;
      case 'reevaluasi':
        Navigator.pushNamed(
          context,
          AppRoutes.terapisReEvaluasi,
          arguments: {
            'terapisId': widget.terapisId,
          },
        );
        break;
      case 'laporan':
        Navigator.pushNamed(context, AppRoutes.terapisLaporanList);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // RPT Stats Card with Gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF3B82F6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Total Data RPT',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_stats['totalRPT']}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRPTStatItem('Aktif', _stats['activeRPT']),
                    _buildRPTStatItem('Review', _stats['reviewRPT']),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Welcome Message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Text(
                  'Selamat Datang, $_terapisName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_lastLogin != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Terakhir login: ${DateFormat('dd MMM yyyy, HH:mm').format(_lastLogin!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Access Title
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Access Menu
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAccessItem(
                context,
                'Data Anak',
                Icons.child_care,
                () => _navigateToDataList(context, 'anak'),
              ),
              _buildQuickAccessItem(
                context,
                'RPT',
                Icons.description_outlined,
                () => _navigateToDataList(context, 'rpt'),
              ),
              _buildQuickAccessItem(
                context,
                'Re-Evaluasi',
                Icons.assessment_outlined,
                () => _navigateToDataList(context, 'reevaluasi'),
              ),
              _buildQuickAccessItem(
                context,
                'Laporan',
                Icons.article_outlined,
                () => _navigateToDataList(context, 'laporan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRPTStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 2, // 2 items per row
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
