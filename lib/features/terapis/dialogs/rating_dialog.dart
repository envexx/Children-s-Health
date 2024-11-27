// lib/features/terapis/dialogs/rating_dialog.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/styles.dart';

class RatingDialog extends StatefulWidget {
  final String rptId;
  final String titleId;
  final String subtitleId;
  final String? activityId;
  final String therapistId;
  final String therapistName;
  final VoidCallback onRatingAdded;
  final double? initialRating;
  final String? initialNotes;
  final String? ratingId;

  const RatingDialog({
    Key? key,
    required this.rptId,
    required this.titleId,
    required this.subtitleId,
    this.activityId,
    required this.therapistId,
    required this.therapistName,
    required this.onRatingAdded,
    this.initialRating,
    this.initialNotes,
    this.ratingId,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required String rptId,
    required String titleId,
    required String subtitleId,
    String? activityId,
    required String therapistId,
    required String therapistName,
    required VoidCallback onRatingAdded,
    double? initialRating,
    String? initialNotes,
    String? ratingId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        rptId: rptId,
        titleId: titleId,
        subtitleId: subtitleId,
        activityId: activityId,
        therapistId: therapistId,
        therapistName: therapistName,
        onRatingAdded: onRatingAdded,
        initialRating: initialRating,
        initialNotes: initialNotes,
        ratingId: ratingId,
      ),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final TextEditingController _notesController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _notesController.text = widget.initialNotes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.ratingId != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEditing ? 'Edit Rating' : 'Tambah Rating',
        style: TextStyle(
          color: RPTStyles.mainColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Stars
            _buildRatingStars(),
            const SizedBox(height: 24),

            // Rating Value Display
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: RPTStyles.mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Rating: ${_rating.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: RPTStyles.mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes TextField
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: RPTStyles.mainColor),
                ),
              ),
            ),

            // Terapis Info
            const SizedBox(height: 16),
            Text(
              'Terapis: ${widget.therapistName}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  _notesController.clear();
                  Navigator.pop(context);
                },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRating,
          style: ElevatedButton.styleFrom(
            backgroundColor: RPTStyles.mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(isEditing ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = starValue.toDouble()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              _rating >= starValue ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon berikan rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final ratingData = {
        'value': _rating,
        'notes': _notesController.text.trim(),
        'therapistId': widget.therapistId,
        'therapistName': widget.therapistName,
      };

      final baseRef = FirebaseFirestore.instance
          .collection('rpts')
          .doc(widget.rptId)
          .collection('titles')
          .doc(widget.titleId)
          .collection('subtitles')
          .doc(widget.subtitleId);

      final targetRef = widget.activityId != null
          ? baseRef.collection('activities').doc(widget.activityId)
          : baseRef;

      if (widget.ratingId != null) {
        // Update existing rating
        await targetRef.collection('ratings').doc(widget.ratingId).update({
          ...ratingData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new rating
        await targetRef.collection('ratings').add({
          ...ratingData,
          'date': FieldValue.serverTimestamp(),
        });
      }

      widget.onRatingAdded();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.ratingId != null
                  ? 'Rating berhasil diperbarui'
                  : 'Rating berhasil ditambahkan',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error submitting rating: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan rating'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// Helper widget for reusable star rating display
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
