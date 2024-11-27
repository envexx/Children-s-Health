// lib/features/terapis/widgets/rpt_title_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/rpt_model_terapis.dart';
import '../constants/styles.dart';
// import '../dialogs/edit_dialogs.dart';
import 'rpt_subtitle_card.dart';

class RPTTitleCard extends StatelessWidget {
  final TitleModel title;
  final int index;
  final VoidCallback onUpdated;
  final String therapistId; // Tambahkan ini
  final String therapistName;
  final String rptId;

  const RPTTitleCard({
    Key? key,
    required this.title,
    required this.index,
    required this.onUpdated,
    required this.rptId,
    required this.therapistId,
    required this.therapistName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleHeader(context),
          _buildSubtitlesList(),
        ],
      ),
    );
  }

  Widget _buildTitleHeader(BuildContext context) {
    final bool allSubtitlesCompleted = title.subtitles.every((subtitle) =>
        subtitle.activities.every((activity) => activity.ratings.isNotEmpty));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: allSubtitlesCompleted
            ? Colors.green.withOpacity(0.1)
            : RPTStyles.mainColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Index Number Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: allSubtitlesCompleted ? Colors.green : RPTStyles.mainColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title Text
          Expanded(
            child: Row(
              children: [
                Icon(
                  allSubtitlesCompleted ? Icons.check_circle : Icons.category,
                  color: allSubtitlesCompleted
                      ? Colors.green
                      : RPTStyles.mainColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: allSubtitlesCompleted
                          ? Colors.green
                          : RPTStyles.mainColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: RPTStyles.mainColor,
            size: 20,
          ),
          onPressed: () => _showEditTitleDialog(context),
          tooltip: 'Edit Judul',
        ),
        // Add Subtitle Button
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: RPTStyles.mainColor,
            size: 20,
          ),
          onPressed: () => _showAddSubtitleDialog(context),
          tooltip: 'Tambah Sub Judul',
        ),
      ],
    );
  }

  Widget _buildSubtitlesList() {
    if (title.subtitles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Belum ada sub judul',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: title.subtitles.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => RPTSubtitleCard(
        subtitle: title.subtitles[index],
        titleId: title.id,
        subtitleIndex: index,
        rptId: rptId,
        therapistId: therapistId, // Tambahkan ini
        therapistName: therapistName,
        onUpdated: onUpdated,
      ),
    );
  }

  void _showEditTitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Judul',
          style: TextStyle(
            color: RPTStyles.mainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: EditTitleForm(
          initialTitle: title.title,
          onSubmit: (newTitle) async {
            Navigator.pop(context);
            await _updateTitle(context, newTitle);
          },
        ),
      ),
    );
  }

  void _showAddSubtitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tambah Sub Judul',
          style: TextStyle(
            color: RPTStyles.mainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: AddSubtitleForm(
          onSubmit: (subtitle) async {
            Navigator.pop(context);
            await _addSubtitle(context, subtitle);
          },
        ),
      ),
    );
  }

  Future<void> _updateTitle(BuildContext context, String newTitle) async {
    try {
      await FirebaseFirestore.instance
          .collection('rpts')
          .doc(rptId)
          .collection('titles')
          .doc(title.id)
          .update({
        'title': newTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      onUpdated();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Judul berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui judul')),
        );
      }
    }
  }

  Future<void> _addSubtitle(BuildContext context, String subtitle) async {
    try {
      await FirebaseFirestore.instance
          .collection('rpts')
          .doc(rptId)
          .collection('titles')
          .doc(title.id)
          .collection('subtitles')
          .add({
        'subtitle': subtitle,
        'createdAt': FieldValue.serverTimestamp(),
        'order': title.subtitles.length,
      });

      onUpdated();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sub judul berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan sub judul')),
        );
      }
    }
  }
}

// Form Widgets
class EditTitleForm extends StatefulWidget {
  final String initialTitle;
  final Function(String) onSubmit;

  const EditTitleForm({
    Key? key,
    required this.initialTitle,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<EditTitleForm> createState() => _EditTitleFormState();
}

class _EditTitleFormState extends State<EditTitleForm> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Judul',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: RPTStyles.mainColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  widget.onSubmit(_controller.text.trim());
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
      ],
    );
  }
}

class AddSubtitleForm extends StatefulWidget {
  final Function(String) onSubmit;

  const AddSubtitleForm({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddSubtitleForm> createState() => _AddSubtitleFormState();
}

class _AddSubtitleFormState extends State<AddSubtitleForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Sub Judul',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: RPTStyles.mainColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  widget.onSubmit(_controller.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: RPTStyles.mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tambah'),
            ),
          ],
        ),
      ],
    );
  }
}
