// lib/features/terapis/dialogs/edit_dialog.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/styles.dart';
// import '../../../core/models/rpt_model_terapis.dart';

class EditDialogs {
  static Future<void> show({
    required BuildContext context,
    required String type,
    required String rptId,
    required String titleId,
    String? subtitleId,
    String? activityId,
    String? initialValue,
    required VoidCallback onSaved,
  }) async {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    String dialogTitle;
    String labelText;
    int maxLines;

    switch (type) {
      case 'title':
        dialogTitle = 'Edit Judul';
        labelText = 'Judul';
        maxLines = 1;
        break;
      case 'subtitle':
        dialogTitle =
            subtitleId != null ? 'Edit Sub Judul' : 'Tambah Sub Judul';
        labelText = 'Sub Judul';
        maxLines = 1;
        break;
      case 'activity':
        dialogTitle = activityId != null ? 'Edit Kegiatan' : 'Tambah Kegiatan';
        labelText = 'Deskripsi Kegiatan';
        maxLines = 3;
        break;
      default:
        throw ArgumentError('Type tidak valid: $type');
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditDialog(
        title: dialogTitle,
        controller: controller,
        maxLines: maxLines,
        labelText: labelText,
        onSave: (value) => _handleSave(
          context: context,
          type: type,
          rptId: rptId,
          titleId: titleId,
          subtitleId: subtitleId,
          activityId: activityId,
          value: value,
          onSaved: onSaved,
        ),
      ),
    );
  }

  static Future<void> _handleSave({
    required BuildContext context,
    required String type,
    required String rptId,
    required String titleId,
    String? subtitleId,
    String? activityId,
    required String value,
    required VoidCallback onSaved,
  }) async {
    try {
      final trimmedValue = value.trim();
      if (trimmedValue.isEmpty) {
        throw Exception('Value tidak boleh kosong');
      }

      DocumentReference docRef;
      Map<String, dynamic> data;
      String successMessage;

      switch (type) {
        case 'title':
          docRef = FirebaseFirestore.instance
              .collection('rpts')
              .doc(rptId)
              .collection('titles')
              .doc(titleId);
          data = {
            'title': trimmedValue,
            'updatedAt': FieldValue.serverTimestamp(),
          };
          successMessage = 'Judul berhasil diperbarui';
          break;

        case 'subtitle':
          if (activityId != null) {
            // Edit subtitle
            docRef = FirebaseFirestore.instance
                .collection('rpts')
                .doc(rptId)
                .collection('titles')
                .doc(titleId)
                .collection('subtitles')
                .doc(subtitleId);
            data = {
              'subtitle': trimmedValue,
              'updatedAt': FieldValue.serverTimestamp(),
            };
            successMessage = 'Sub judul berhasil diperbarui';
          } else {
            // Add new subtitle
            final CollectionReference subRef = FirebaseFirestore.instance
                .collection('rpts')
                .doc(rptId)
                .collection('titles')
                .doc(titleId)
                .collection('subtitles');
            data = {
              'subtitle': trimmedValue,
              'isCompleted': false,
              'createdAt': FieldValue.serverTimestamp(),
            };
            await subRef.add(data);
            successMessage = 'Sub judul berhasil ditambahkan';
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(successMessage)),
              );
            }
            onSaved();
            return;
          }
          break;

        case 'activity':
          if (subtitleId == null) {
            throw Exception('subtitleId diperlukan untuk activity');
          }
          if (activityId != null) {
            // Edit activity
            docRef = FirebaseFirestore.instance
                .collection('rpts')
                .doc(rptId)
                .collection('titles')
                .doc(titleId)
                .collection('subtitles')
                .doc(subtitleId)
                .collection('activities')
                .doc(activityId);
            data = {
              'description': trimmedValue,
              'updatedAt': FieldValue.serverTimestamp(),
            };
            successMessage = 'Kegiatan berhasil diperbarui';
          } else {
            // Add new activity
            final CollectionReference actRef = FirebaseFirestore.instance
                .collection('rpts')
                .doc(rptId)
                .collection('titles')
                .doc(titleId)
                .collection('subtitles')
                .doc(subtitleId)
                .collection('activities');
            data = {
              'description': trimmedValue,
              'isCompleted': false,
              'createdAt': FieldValue.serverTimestamp(),
            };
            await actRef.add(data);
            successMessage = 'Kegiatan berhasil ditambahkan';
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(successMessage)),
              );
            }
            onSaved();
            return;
          }
          break;

        default:
          throw ArgumentError('Type tidak valid: $type');
      }

      await docRef.update(data);
      onSaved();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      print('Error in EditDialogs._handleSave: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan perubahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Reusable Edit Dialog Widget
class EditDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final Function(String) onSave;
  final int maxLines;
  final String? labelText;
  final bool isSubmitting;

  const EditDialog({
    Key? key,
    required this.title,
    required this.controller,
    required this.onSave,
    this.maxLines = 1,
    this.labelText,
    this.isSubmitting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          color: RPTStyles.mainColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText ?? title,
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: RPTStyles.mainColor),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSubmitting
              ? null
              : () {
                  if (controller.text.trim().isNotEmpty) {
                    onSave(controller.text);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: RPTStyles.mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
