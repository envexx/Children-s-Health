// lib/core/models/terapis_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TerapisModel {
  final String id;
  final String nama;
  final String email;
  final String noHp;
  final String spesialisasi;
  final bool isActive;
  final Timestamp createdAt;

  TerapisModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.spesialisasi,
    required this.createdAt,
    this.isActive = true,
  });

  factory TerapisModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TerapisModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      noHp: data['noHp'] ?? '',
      spesialisasi: data['spesialisasi'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'email': email,
      'noHp': noHp,
      'spesialisasi': spesialisasi,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
