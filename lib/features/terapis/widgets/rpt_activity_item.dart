// lib/features/terapis/widgets/rpt_activity_item.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/rpt_model_terapis.dart';
import '../constants/styles.dart';
import '../dialogs/rating_dialog.dart';

class RPTActivityItem extends StatelessWidget {
  final ActivityModel activity;
  final String titleId;
  final String subtitleId;
  final int activityIndex;
  final String rptId;
  final VoidCallback onUpdated;
  final bool isSubtitleCompleted;
  final String therapistId;
  final String therapistName;

  const RPTActivityItem({
    Key? key,
    required this.activity,
    required this.titleId,
    required this.subtitleId,
    required this.activityIndex,
    required this.rptId,
    required this.onUpdated,
    required this.therapistId,
    required this.therapistName,
    this.isSubtitleCompleted = false,
  }) : super(key: key);

  bool get isActivityCompleted => activity.ratings.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityHeader(context),
          if (isActivityCompleted) ...[
            const SizedBox(height: 8),
            _buildRatingsList(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          child: Icon(
            isActivityCompleted ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isActivityCompleted ? Colors.green : RPTStyles.mainColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            activity.description,
            style: TextStyle(
              fontSize: 14,
              color: isActivityCompleted
                  ? const Color.fromARGB(255, 45, 45, 45)
                  : Colors.black87,
              // decoration:
              // isActivityCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (!isSubtitleCompleted) ...[
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: RPTStyles.mainColor,
              size: 20,
            ),
            onPressed: () => _showEditActivityDialog(context),
            tooltip: 'Edit Kegiatan',
          ),
          IconButton(
            icon: Icon(
              activity.ratings.isEmpty ? Icons.star_outline : Icons.star,
              color:
                  activity.ratings.isEmpty ? RPTStyles.mainColor : Colors.amber,
              size: 20,
            ),
            onPressed: () => _showRatingDialog(context),
            tooltip:
                activity.ratings.isEmpty ? 'Tambah Rating' : 'Lihat Rating',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Hapus Kegiatan',
          ),
        ],
      ],
    );
  }

  Widget _buildRatingsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.star, color: RPTStyles.mainColor, size: 16),
              const SizedBox(width: 4),
              Text(
                'Rating Terakhir',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: RPTStyles.mainColor,
                ),
              ),
            ],
          ),
        ),
        ...activity.ratings
            .map((rating) => _buildRatingItem(context, rating))
            .toList(),
      ],
    );
  }

  Widget _buildRatingItem(BuildContext context, RatingModel rating) {
    return Container(
      margin: const EdgeInsets.only(left: 24, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RPTStyles.mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: StarRating(rating: rating.value),
                  ),
                ],
              ),
              if (!isSubtitleCompleted)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: RPTStyles.mainColor, size: 20),
                  onSelected: (value) =>
                      _handleRatingAction(context, value, rating),
                  itemBuilder: (context) => _buildRatingMenuItems(context),
                ),
            ],
          ),
          if (rating.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catatan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(rating.notes!, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Oleh: ${rating.therapistName}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<PopupMenuItem<String>> _buildRatingMenuItems(BuildContext context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: RPTStyles.mainColor, size: 20),
              const SizedBox(width: 8),
              const Text('Edit Rating'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Rating', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ];

  void _handleRatingAction(
      BuildContext context, String action, RatingModel rating) {
    if (action == 'edit') {
      _showRatingDialog(context, rating);
    } else if (action == 'delete') {
      _showDeleteRatingConfirmation(context, rating.id);
    }
  }

  void _showEditActivityDialog(BuildContext context) {
    final controller = TextEditingController(text: activity.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Kegiatan',
          style: TextStyle(
            color: RPTStyles.mainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Deskripsi Kegiatan',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: RPTStyles.mainColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _updateActivity(context, controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RPTStyles.mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, [RatingModel? existingRating]) {
    RatingDialog.show(
      context: context,
      rptId: rptId,
      titleId: titleId,
      subtitleId: subtitleId,
      activityId: activity.id,
      therapistId: therapistId,
      therapistName: therapistName,
      onRatingAdded: onUpdated,
      initialRating: existingRating?.value,
      initialNotes: existingRating?.notes,
      ratingId: existingRating?.id,
    );
  }

  void _showDeleteRatingConfirmation(BuildContext context, String ratingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Rating',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus rating ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteRating(context, ratingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Kegiatan',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus kegiatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteActivity(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateActivity(
      BuildContext context, String newDescription) async {
    try {
      await FirebaseFirestore.instance
          .collection('rpts')
          .doc(rptId)
          .collection('titles')
          .doc(titleId)
          .collection('subtitles')
          .doc(subtitleId)
          .collection('activities')
          .doc(activity.id)
          .update({
        'description': newDescription,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      onUpdated();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kegiatan berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui kegiatan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRating(BuildContext context, String ratingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rpts')
          .doc(rptId)
          .collection('titles')
          .doc(titleId)
          .collection('subtitles')
          .doc(subtitleId)
          .collection('activities')
          .doc(activity.id)
          .collection('ratings')
          .doc(ratingId)
          .delete();

      onUpdated();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating berhasil dihapus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus rating'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteActivity(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('rpts')
          .doc(rptId)
          .collection('titles')
          .doc(titleId)
          .collection('subtitles')
          .doc(subtitleId)
          .collection('activities')
          .doc(activity.id)
          .delete();

      onUpdated();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kegiatan berhasil dihapus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus kegiatan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
