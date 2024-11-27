// lib/features/auth/services/admin_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> signInAdmin(
      String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final adminDoc =
          await _firestore.collection('admins').doc(result.user!.uid).get();

      if (!adminDoc.exists) {
        throw 'Bukan akun admin';
      }

      if (!(adminDoc.data()?['isActive'] ?? false)) {
        throw 'Akun admin tidak aktif';
      }

      // Update lastLogin
      await _firestore
          .collection('admins')
          .doc(result.user!.uid)
          .update({'lastLogin': FieldValue.serverTimestamp()});

      return {
        'user': result.user,
        'userData': adminDoc.data(),
      };
    } catch (e) {
      print('Error admin sign in: $e');
      rethrow;
    }
  }

  Future<void> createDefaultAdmin() async {
    try {
      const String adminEmail = 'yametbatamtibn@gmail.com';
      const String adminPassword = 'yametbatamtiban';

      final adminDoc = await _firestore
          .collection('admins')
          .where('email', isEqualTo: adminEmail)
          .get();

      if (adminDoc.docs.isEmpty) {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );

        final Map<String, dynamic> adminData = {
          'uid': userCredential.user!.uid,
          'email': adminEmail,
          'name': 'Admin YAMET',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': null,
          'isActive': true,
          'phone': '',
          'address': 'Batam Tiban',
        };

        await _firestore
            .collection('admins')
            .doc(userCredential.user!.uid)
            .set(adminData);

        print('Admin default berhasil dibuat');
      }
    } catch (e) {
      print('Error creating admin: $e');
      rethrow;
    }
  }
}
