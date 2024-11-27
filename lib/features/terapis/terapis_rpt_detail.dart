// lib/features/terapis/screens/rpt_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/rpt_model_terapis.dart';
import 'widgets/rpt_header_card.dart';
import 'widgets/rpt_title_card.dart';
import 'dialogs/confirmation_dialog.dart';
import 'constants/styles.dart';

class TerapisRptDetail extends StatefulWidget {
  final String rptId;

  const TerapisRptDetail({Key? key, required this.rptId}) : super(key: key);

  @override
  State<TerapisRptDetail> createState() => _TerapisRptDetailState();
}

class _TerapisRptDetailState extends State<TerapisRptDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  bool _isDeleting = false;
  RPTModel? _rptData;

  @override
  void initState() {
    super.initState();
    _loadRptData();
  }

  Future<void> _loadRptData() async {
    try {
      setState(() => _isLoading = true);

      final rptDoc =
          await _firestore.collection('rpts').doc(widget.rptId).get();
      if (!rptDoc.exists) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('RPT tidak ditemukan')),
          );
        }
        return;
      }

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

          List<ActivityModel> activities = [];
          for (var activityDoc in activitiesSnapshot.docs) {
            final ratingsSnapshot = await activityDoc.reference
                .collection('ratings')
                .orderBy('date', descending: true)
                .get();

            List<RatingModel> ratings = ratingsSnapshot.docs
                .map((ratingDoc) => RatingModel.fromFirestore(ratingDoc))
                .toList();

            activities.add(
                ActivityModel.fromFirestore(activityDoc, ratings: ratings));
          }

          // Load subtitle ratings if no activities
          List<RatingModel>? subtitleRatings;
          if (activities.isEmpty) {
            final ratingsSnapshot = await subtitleDoc.reference
                .collection('ratings')
                .orderBy('date', descending: true)
                .get();

            subtitleRatings = ratingsSnapshot.docs
                .map((ratingDoc) => RatingModel.fromFirestore(ratingDoc))
                .toList();
          }

          subtitles.add(SubtitleModel.fromFirestore(
            subtitleDoc,
            activities: activities,
            ratings: subtitleRatings,
          ));
        }

        titles.add(TitleModel.fromFirestore(titleDoc, subtitles));
      }

      final rptModel = RPTModel.fromFirestore(rptDoc);

      if (mounted) {
        setState(() {
          _rptData = rptModel.copyWith(titles: titles);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading RPT data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data RPT'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRPT() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus RPT',
      message:
          'Apakah Anda yakin ingin menghapus RPT ini? Semua data termasuk rating akan terhapus permanen.',
      isDanger: true,
      isLoading: _isDeleting,
    );

    if (!confirmed) return;

    try {
      setState(() => _isDeleting = true);

      // Delete all nested collections
      for (var title in _rptData!.titles) {
        for (var subtitle in title.subtitles) {
          // Delete activities and their ratings
          for (var activity in subtitle.activities) {
            final ratingsSnapshot = await _firestore
                .collection('rpts')
                .doc(widget.rptId)
                .collection('titles')
                .doc(title.id)
                .collection('subtitles')
                .doc(subtitle.id)
                .collection('activities')
                .doc(activity.id)
                .collection('ratings')
                .get();

            for (var ratingDoc in ratingsSnapshot.docs) {
              await ratingDoc.reference.delete();
            }

            // Delete activity
            await _firestore
                .collection('rpts')
                .doc(widget.rptId)
                .collection('titles')
                .doc(title.id)
                .collection('subtitles')
                .doc(subtitle.id)
                .collection('activities')
                .doc(activity.id)
                .delete();
          }

          // Delete subtitle ratings if any
          if (subtitle.ratings != null) {
            final ratingsSnapshot = await _firestore
                .collection('rpts')
                .doc(widget.rptId)
                .collection('titles')
                .doc(title.id)
                .collection('subtitles')
                .doc(subtitle.id)
                .collection('ratings')
                .get();

            for (var ratingDoc in ratingsSnapshot.docs) {
              await ratingDoc.reference.delete();
            }
          }

          // Delete subtitle
          await _firestore
              .collection('rpts')
              .doc(widget.rptId)
              .collection('titles')
              .doc(title.id)
              .collection('subtitles')
              .doc(subtitle.id)
              .delete();
        }

        // Delete title
        await _firestore
            .collection('rpts')
            .doc(widget.rptId)
            .collection('titles')
            .doc(title.id)
            .delete();
      }

      // Finally delete the main RPT document
      await _firestore.collection('rpts').doc(widget.rptId).delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RPT berhasil dihapus')),
        );
      }
    } catch (e) {
      print('Error deleting RPT: $e');
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus RPT'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleStatusSelesai(
      SubtitleModel subtitle, TitleModel title, bool isCompleted) async {
    try {
      setState(() => _isLoading = true);

      Map<String, dynamic> dataUpdate = {
        'isCompleted': isCompleted,
        'updatedAt': Timestamp.now(),
      };

      if (isCompleted) {
        // Langsung menggunakan waktu sekarang
        dataUpdate['endDate'] = Timestamp.now();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('Menyimpan perubahan...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        dataUpdate['endDate'] = FieldValue.delete();
      }

      await _firestore
          .collection('rpts')
          .doc(widget.rptId)
          .collection('titles')
          .doc(title.id)
          .collection('subtitles')
          .doc(subtitle.id)
          .update(dataUpdate);

      await _loadRptData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCompleted
                ? 'Program berhasil ditandai selesai'
                : 'Status selesai berhasil dibatalkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error mengubah status selesai: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: RPTStyles.mainColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: RPTStyles.mainColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'RPT ${_rptData!.childName}',
          style: const TextStyle(
            color: RPTStyles.mainColor,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _isDeleting ? null : _deleteRPT,
            tooltip: 'Hapus RPT',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: RPTStyles.mainColor,
        onRefresh: _loadRptData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RPTHeaderCard(rptData: _rptData!),
            const SizedBox(height: 16),
            ...(_rptData!.titles.asMap().entries.map(
                  (entry) => RPTTitleCard(
                    rptId: widget.rptId,
                    title: entry.value,
                    index: entry.key,
                    therapistId: _rptData!.therapistId, // Tambahkan ini
                    therapistName: _rptData!.therapistName,
                    onUpdated: _loadRptData,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
