// lib/features/admin/services/admin_terapis_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/terapis_model.dart';

class AdminTerapisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Membuat akun terapis baru
  Future<Map<String, dynamic>> createTerapis({
    required String nama,
    required String email,
    required String password,
    required String noHp,
    required String spesialisasi,
  }) async {
    try {
      // Buat akun authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Buat data terapis di Firestore
      final terapisData = {
        'nama': nama,
        'email': email,
        'noHp': noHp,
        'spesialisasi': spesialisasi,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Simpan ke Firestore dengan ID dari Authentication
      await _firestore
          .collection('terapis')
          .doc(userCredential.user!.uid)
          .set(terapisData);

      return {
        'success': true,
        'message': 'Terapis berhasil ditambahkan',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah';
          break;
        default:
          message = 'Terjadi kesalahan pada autentikasi';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Mendapatkan daftar semua terapis
  Stream<List<TerapisModel>> getTerapisList() {
    return _firestore
        .collection('terapis')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TerapisModel.fromFirestore(doc))
          .toList();
    });
  }

  // Mendapatkan terapis by ID
  Future<TerapisModel?> getTerapisById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('terapis').doc(id).get();
      if (doc.exists) {
        return TerapisModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting terapis: $e');
      return null;
    }
  }

  // Update data terapis
  Future<Map<String, dynamic>> updateTerapis(TerapisModel terapis) async {
    try {
      await _firestore
          .collection('terapis')
          .doc(terapis.id)
          .update(terapis.toFirestore());

      return {
        'success': true,
        'message': 'Data terapis berhasil diperbarui',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui data terapis: $e',
      };
    }
  }

  // Update status aktif terapis
  Future<Map<String, dynamic>> updateTerapisStatus(
      String id, bool isActive) async {
    try {
      await _firestore.collection('terapis').doc(id).update({
        'isActive': isActive,
      });
      return {
        'success': true,
        'message': 'Status terapis berhasil diperbarui',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui status terapis: $e',
      };
    }
  }

  // Reset password terapis
  Future<Map<String, dynamic>> resetTerapisPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Link reset password telah dikirim ke email terapis',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = 'Terjadi kesalahan saat reset password';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim reset password: $e',
      };
    }
  }

  // Hapus terapis
  Future<Map<String, dynamic>> deleteTerapis(String id) async {
    try {
      // Dapatkan data terapis
      DocumentSnapshot doc =
          await _firestore.collection('terapis').doc(id).get();
      if (!doc.exists) {
        return {
          'success': false,
          'message': 'Terapis tidak ditemukan',
        };
      }

      // Hapus dari Firestore
      await _firestore.collection('terapis').doc(id).delete();

      // Hapus dari Authentication
      User? user = await _auth.currentUser;
      if (user != null && user.uid == id) {
        await user.delete();
      }

      return {
        'success': true,
        'message': 'Terapis berhasil dihapus',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus terapis: $e',
      };
    }
  }

  // Cari terapis berdasarkan nama atau spesialisasi
  Stream<List<TerapisModel>> searchTerapis(String query) {
    return _firestore
        .collection('terapis')
        .orderBy('nama')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TerapisModel.fromFirestore(doc))
              .toList();
        });
  }

  // Mendapatkan total terapis aktif
  Future<int> getTotalActiveTerapis() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('terapis')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.size;
    } catch (e) {
      print('Error getting total active terapis: $e');
      return 0;
    }
  }
}
