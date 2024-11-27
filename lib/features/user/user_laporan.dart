import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLaporan extends StatefulWidget {
  const UserLaporan({Key? key}) : super(key: key);
  @override
  State<UserLaporan> createState() => _UserLaporanState();
}

class _UserLaporanState extends State<UserLaporan> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _childData;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final childSnapshot = await _firestore
          .collection('children')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (childSnapshot.docs.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final childDoc = childSnapshot.docs.first;
      final childId = childDoc.id;
      _childData = {
        'id': childId,
        'nama': childDoc.data()['nama'] ?? '',
        'usia': childDoc.data()['usia'] ?? '',
      };

      final rptSnapshot = await _firestore
          .collection('rpts')
          .where('childId', isEqualTo: childId)
          .where('status', isEqualTo: 'active')
          .get();

      for (var rpt in rptSnapshot.docs) {
        final rptData = rpt.data();
        final activities = await _getAllActivitiesAndRatings(rpt.reference);
        if (activities.isNotEmpty) {
          _reports.add({
            'id': rpt.id,
            'date': activities.first['date'],
            'terapiType': rptData['terapiType'],
            'therapistName': rptData['therapistName'] ?? '',
            'activities': activities,
          });
        }
      }

      setState(() {
        _reports.sort((a, b) =>
            (b['date'] as Timestamp).compareTo(a['date'] as Timestamp));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _getAllActivitiesAndRatings(
      DocumentReference rptRef) async {
    List<Map<String, dynamic>> activities = [];
    try {
      final titlesSnapshot = await rptRef.collection('titles').get();

      for (var title in titlesSnapshot.docs) {
        final titleData = title.data();
        final subtitlesSnapshot =
            await title.reference.collection('subtitles').get();

        for (var subtitle in subtitlesSnapshot.docs) {
          final subtitleData = subtitle.data();
          final activitiesSnapshot =
              await subtitle.reference.collection('activities').get();

          for (var activity in activitiesSnapshot.docs) {
            final activityData = activity.data();
            final ratingsSnapshot = await activity.reference
                .collection('ratings')
                .orderBy('date', descending: true)
                .get();

            if (ratingsSnapshot.docs.isNotEmpty) {
              activities.add({
                'title': titleData['title'] ?? '',
                'subtitle': subtitleData['subtitle'] ?? '',
                'activity': activityData['description'] ?? '',
                'date': ratingsSnapshot.docs.first['date'],
                'ratings': ratingsSnapshot.docs.map((doc) {
                  final data = doc.data();
                  return {
                    'date': data['date'],
                    'notes': data['notes'] ?? '',
                    'value': data['value'] ?? 0,
                  };
                }).toList(),
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error getting activities and ratings: $e');
    }
    return activities;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          color: Color(0xFF4461F2),
        )),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4461F2).withOpacity(0.1),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _childData?['nama'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1E25),
                          ),
                        ),
                        Text(
                          'tahun',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return _TimelineCard(report: report);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Map<String, dynamic> report;

  const _TimelineCard({Key? key, required this.report}) : super(key: key);

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['terapiType'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Terapis: ${report['therapistName']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...((report['activities'] as List<Map<String, dynamic>>)
                        .map((activity) => Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity['activity'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...(activity['ratings'] as List)
                                      .map((rating) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rating['notes'],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ],
                              ),
                            ))).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = report['activities'] as List<Map<String, dynamic>>;
    final date = (report['date'] as Timestamp).toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4461F2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: Color(0xFF4461F2),
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFF4461F2).withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF4461F2).withOpacity(0.1),
                  ),
                ),
                child: InkWell(
                  onTap: () => _showDetailDialog(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report['terapiType'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'Terapis: ${report['therapistName']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              DateFormat('d MMM yyyy').format(date),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4461F2),
                              ),
                            ),
                          ],
                        ),
                        if (activities.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            activities.first['ratings'][0]['notes'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          if (activities.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${activities.length - 1} aktivitas lainnya',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4461F2),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
