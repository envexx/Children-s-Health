// lib/features/terapis/widgets/rpt_subtitle_card.dart (Part 1)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/rpt_model_terapis.dart';
import '../constants/styles.dart';
import 'rpt_activity_item.dart';
import '../dialogs/rating_dialog.dart';
import '../dialogs/edit_dialogs.dart';
import '../dialogs/confirmation_dialog.dart';

class RPTSubtitleCard extends StatelessWidget {
  final SubtitleModel subtitle;
  final String titleId;
  final int subtitleIndex;
  final String rptId;
  final String therapistId;
  final String therapistName;
  final VoidCallback onUpdated;

  const RPTSubtitleCard({
    Key? key,
    required this.subtitle,
    required this.titleId,
    required this.subtitleIndex,
    required this.rptId,
    required this.therapistId,
    required this.therapistName,
    required this.onUpdated,
  }) : super(key: key);

  String _getSubtitleLabel() {
    return String.fromCharCode(65 + subtitleIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubtitleHeader(context),
          _buildContent(context),
          if (subtitle.isCompleted) _buildCompletionBadge(),
        ],
      ),
    );
  }

  Widget _buildSubtitleHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: subtitle.isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: subtitle.isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : RPTStyles.mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getSubtitleLabel(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    subtitle.isCompleted ? Colors.green : RPTStyles.mainColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtitle.subtitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration:
                    subtitle.isCompleted ? TextDecoration.lineThrough : null,
                color: subtitle.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          if (!subtitle.isCompleted) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: RPTStyles.mainColor,
              onPressed: () => _showEditDialog(context, 'subtitle'),
              tooltip: 'Edit Sub Judul',
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              color: RPTStyles.mainColor,
              onPressed: () => _showEditDialog(context, 'activity'),
              tooltip: 'Tambah Kegiatan',
            ),
          ],
          IconButton(
            icon: Icon(
              subtitle.isCompleted
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: subtitle.isCompleted ? Colors.green : Colors.grey,
              size: 20,
            ),
            onPressed: () => _handleCompletion(context),
            tooltip: subtitle.isCompleted
                ? 'Tandai Belum Selesai'
                : 'Tandai Selesai',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (subtitle.activities.isEmpty && (subtitle.ratings?.isEmpty ?? true)) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Belum ada kegiatan',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle.activities.isNotEmpty) _buildActivitiesList(),
        if (subtitle.ratings?.isNotEmpty ?? false) _buildRatingsList(context),
      ],
    );
  }

  Widget _buildActivitiesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: subtitle.activities.length,
      itemBuilder: (context, index) => RPTActivityItem(
        activity: subtitle.activities[index],
        titleId: titleId,
        subtitleId: subtitle.id,
        activityIndex: index,
        rptId: rptId,
        therapistId: therapistId,
        therapistName: therapistName,
        onUpdated: onUpdated,
        isSubtitleCompleted: subtitle.isCompleted,
      ),
    );
  } // lib/features/terapis/widgets/rpt_subtitle_card.dart (Part 2)

  Widget _buildRatingsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: RPTStyles.mainColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RPTStyles.mainColor,
                    ),
                  ),
                ],
              ),
              if (!subtitle.isCompleted)
                TextButton.icon(
                  onPressed: () => _showRatingDialog(context),
                  icon: Icon(Icons.add, size: 18, color: RPTStyles.mainColor),
                  label: Text(
                    'Tambah Rating',
                    style: TextStyle(
                      fontSize: 12,
                      color: RPTStyles.mainColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...subtitle.ratings!.map(
            (rating) => _buildRatingItem(context, rating),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBadge() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(
            'Selesai',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.completedAt != null) ...[
            const SizedBox(width: 4),
            Text(
              '• ${_formatDate(subtitle.completedAt!)}',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingItem(BuildContext context, RatingModel rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              StarRating(rating: rating.value),
              if (!subtitle.isCompleted) _buildRatingActions(context, rating),
            ],
          ),
          if (rating.notes?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                rating.notes!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oleh: ${rating.therapistName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                _formatDate(rating.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingActions(BuildContext context, RatingModel rating) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: RPTStyles.mainColor, size: 20),
      onSelected: (value) => _handleRatingAction(context, value, rating),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit Rating'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Hapus Rating', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleRatingAction(
      BuildContext context, String action, RatingModel rating) {
    switch (action) {
      case 'edit':
        _showRatingDialog(context, rating);
        break;
      case 'delete':
        _showDeleteConfirmation(context, rating.id);
        break;
    }
  }

  void _showEditDialog(BuildContext context, String type) {
    EditDialogs.show(
      context: context,
      type: type,
      rptId: rptId,
      titleId: titleId,
      subtitleId: subtitle.id,
      initialValue: type == 'subtitle' ? subtitle.subtitle : '',
      onSaved: onUpdated,
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, String ratingId) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus Rating',
      message: 'Apakah Anda yakin ingin menghapus rating ini?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDanger: true,
    );

    if (confirmed && context.mounted) {
      await _deleteRating(context, ratingId);
    }
  }

  void _showRatingDialog(BuildContext context, [RatingModel? existingRating]) {
    RatingDialog.show(
      context: context,
      rptId: rptId,
      titleId: titleId,
      subtitleId: subtitle.id,
      therapistId: therapistId,
      therapistName: therapistName,
      onRatingAdded: onUpdated,
      initialRating: existingRating?.value,
      initialNotes: existingRating?.notes,
      ratingId: existingRating?.id,
    );
  }

  Future<void> _handleCompletion(BuildContext context) async {
    if (subtitle.isCompleted) {
      _showCompletionConfirmation(context);
    } else {
      if (subtitle.canBeCompleted) {
        _showCompletionConfirmation(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Semua kegiatan harus memiliki rating sebelum menyelesaikan sub judul',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showCompletionConfirmation(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: subtitle.isCompleted
          ? 'Batalkan Penyelesaian'
          : 'Selesaikan Sub Judul',
      message: subtitle.isCompleted
          ? 'Apakah Anda yakin ingin membatalkan penyelesaian sub judul ini?'
          : 'Apakah Anda yakin ingin menyelesaikan sub judul ini?',
      confirmText: subtitle.isCompleted ? 'Batalkan' : 'Selesaikan',
      cancelText: 'Batal',
      isDanger: subtitle.isCompleted,
      confirmColor: subtitle.isCompleted ? Colors.orange : Colors.green,
    );

    if (confirmed && context.mounted) {
      await _toggleComplete(context);
    }
  }

  Future<void> _toggleComplete(BuildContext context) async {
    try {
      final newStatus = !subtitle.isCompleted;
      await FirebaseFirestore.instance
          .collection('rpts')
          .doc(rptId)
          .collection('titles')
          .doc(titleId)
          .collection('subtitles')
          .doc(subtitle.id)
          .update({
        'isCompleted': newStatus,
        'completedAt': newStatus ? FieldValue.serverTimestamp() : null,
      });

      onUpdated();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? 'Sub judul berhasil diselesaikan'
                  : 'Status sub judul berhasil diperbarui',
            ),
            backgroundColor: newStatus ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengubah status sub judul'),
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
          .doc(subtitle.id)
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

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Widget helper untuk menampilkan rating bintang
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool showValue;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 16,
    this.color = Colors.amber,
    this.showValue = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showValue) ...[
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size,
            ),
          ),
          const SizedBox(width: 4),
        ],
        ...List.generate(
          5,
          (index) => Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: color,
            size: size,
          ),
        ),
      ],
    );
  }
}
