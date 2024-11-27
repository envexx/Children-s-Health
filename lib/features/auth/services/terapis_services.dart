// lib/services/terapis_service.dart

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TerapisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTerapis(Map<String, dynamic> terapisData) async {
    try {
      await _firestore.collection('terapis').add({
        ...terapisData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'role': 'terapis', // Tambahkan role terapis
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTerapis({
    required String terapisId,
    required Map<String, dynamic> terapisData,
  }) async {
    try {
      await _firestore.collection('terapis').doc(terapisId).update({
        ...terapisData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTerapis(String terapisId) async {
    try {
      await _firestore.collection('terapis').doc(terapisId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
