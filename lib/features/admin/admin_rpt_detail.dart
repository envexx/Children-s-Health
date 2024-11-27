import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/models/rpt_model_terapis.dart';

class AdminRptDetail extends StatefulWidget {
  final String rptId;
  final String terapisName;

  const AdminRptDetail({
    Key? key,
    required this.rptId,
    required this.terapisName,
  }) : super(key: key);

  @override
  State<AdminRptDetail> createState() => _AdminRptDetailState();
}

class _AdminRptDetailState extends State<AdminRptDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RPTModel? _rptData;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadRptData();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
  }

  Future<void> _loadRptData() async {
    try {
      setState(() => _isLoading = true);

      final rptDoc =
          await _firestore.collection('rpts').doc(widget.rptId).get();
      final titlesSnapshot = await _firestore
          .collection('rpts')
          .doc(widget.rptId)
          .collection('titles')
          .orderBy('createdAt')
          .get();

      List<TitleModel> titles = [];
      for (var titleDoc in titlesSnapshot.docs) {
        final subtitlesSnapshot = await titleDoc.reference
            .collection('subtitles')
            .orderBy('createdAt')
            .get();

        List<SubtitleModel> subtitles = [];
        for (var subtitleDoc in subtitlesSnapshot.docs) {
          final activitiesSnapshot = await subtitleDoc.reference
              .collection('activities')
              .orderBy('createdAt')
              .get();

          List<ActivityModel> activities = activitiesSnapshot.docs
              .map((doc) => ActivityModel.fromFirestore(doc))
              .toList();

          subtitles.add(SubtitleModel.fromFirestore(
            subtitleDoc,
            activities: activities,
          ));
        }

        titles.add(TitleModel.fromFirestore(titleDoc, subtitles));
      }

      if (mounted) {
        setState(() {
          _rptData = RPTModel.fromFirestore(rptDoc).copyWith(titles: titles);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading RPT data: $e');
      _showSnackBar('Gagal memuat data RPT', isError: true);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      setState(() => _isProcessing = true);

      await _firestore.collection('rpts').doc(widget.rptId).update({
        'status': newStatus,
        'reviewedAt': Timestamp.now(),
      });

      _showSnackBar(
        newStatus == 'active'
            ? 'RPT berhasil diverifikasi'
            : 'RPT dibatalkan verifikasi',
      );

      await _loadRptData();
    } catch (e) {
      print('Error updating RPT status: $e');
      _showSnackBar('Gagal mengubah status RPT', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    if (_rptData == null) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4461F2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF4461F2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Informasi Anak",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1E25),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.person,
              label: "Nama",
              value: _rptData!.childName,
            ),
            _buildInfoRow(
              icon: Icons.medical_services_outlined,
              label: "Jenis Terapi",
              value: _rptData!.terapiType,
            ),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: "Terapis",
              value: _rptData!.therapistName,
            ),
            _buildInfoRow(
              icon: Icons.flag_outlined,
              label: "Tujuan Program",
              value: _rptData!.tujuanProgram,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(_rptData!.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(_rptData!.status).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(_rptData!.status),
                    color: _getStatusColor(_rptData!.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(_rptData!.status),
                    style: TextStyle(
                      color: _getStatusColor(_rptData!.status),
                      fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4461F2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4461F2), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFB923C);
      case 'active':
        return const Color(0xFF4461F2);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'active':
        return 'Terverifikasi';
      case 'completed':
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions;
      case 'active':
        return Icons.verified;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildTitleCard(TitleModel title, int index) {
    String indexToLetter(int index) {
      return String.fromCharCode(65 + index); // A, B, C, dst
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4461F2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Color(0xFF4461F2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1E25),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...title.subtitles.asMap().entries.map((entry) {
              final subtitle = entry.value;
              return Container(
                margin: const EdgeInsets.only(left: 32, bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4461F2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              indexToLetter(entry.key),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4461F2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subtitle.subtitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle.activities.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...subtitle.activities.map((activity) => Padding(
                            padding: const EdgeInsets.only(
                              left: 40,
                              top: 8,
                              bottom: 8,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4461F2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    activity.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4461F2)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            children: [
              // Ubah crossAxisAlignment menjadi children saja
              const Text(
                'Detail RPT',
                style: TextStyle(
                  color: Color(0xFF4461F2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.terapisName,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_rptData == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4461F2)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'Data RPT tidak ditemukan',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4461F2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail RPT',
              style: TextStyle(
                color: Color(0xFF4461F2),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.terapisName,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF4461F2),
        onRefresh: _loadRptData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            ..._rptData!.titles.asMap().entries.map((entry) {
              return Column(
                children: [
                  _buildTitleCard(entry.value, entry.key),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () => _updateStatus(
                    _rptData!.status == 'active' ? 'pending' : 'active'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _rptData!.status == 'active'
                  ? Colors.orange
                  : const Color(0xFF4461F2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _rptData!.status == 'active'
                        ? 'Batalkan Verifikasi'
                        : 'Verifikasi RPT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
