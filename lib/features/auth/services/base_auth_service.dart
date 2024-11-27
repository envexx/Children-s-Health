// lib/features/auth/services/base_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login dengan email dan password (fungsi dasar)
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Email tidak terdaftar';
      } else if (e.code == 'wrong-password') {
        throw 'Password salah';
      }
      throw 'Terjadi kesalahan: ${e.message}';
    }
  }

  // Register user baru (fungsi dasar)
  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Password terlalu lemah';
      } else if (e.code == 'email-already-in-use') {
        throw 'Email sudah terdaftar';
      }
      throw 'Terjadi kesalahan: ${e.message}';
    }
  }

  // Sign out (fungsi umum)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Fungsi helper untuk mengecek role
  Future<String?> checkUserRole(String uid) async {
    try {
      // Cek di collection admin
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) return 'admin';

      // Cek di collection terapis
      final terapisDoc = await _firestore.collection('terapis').doc(uid).get();
      if (terapisDoc.exists) return 'terapis';

      // Cek di collection users
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) return 'user';

      return null;
    } catch (e) {
      print('Error checking role: $e');
      return null;
    }
  }
}
