// lib/features/auth/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/routes/app_routes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      // Login dengan Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw 'Login gagal';
      }

      // Cek di collection admins
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();
      if (adminDoc.exists) {
        // Update last login untuk admin
        await adminDoc.reference.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'lastLoginDevice': 'mobile',
        });

        return {'user': user, 'role': 'admin', 'userData': adminDoc.data()};
      }

      // Cek di collection terapis
      final terapisDoc =
          await _firestore.collection('terapis').doc(user.uid).get();
      if (terapisDoc.exists) {
        // Update last login untuk terapis
        await terapisDoc.reference.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'lastLoginDevice': 'mobile',
        });

        return {'user': user, 'role': 'terapis', 'userData': terapisDoc.data()};
      }

      // Cek di collection users
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        // Update last login untuk user
        await userDoc.reference.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'lastLoginDevice': 'mobile',
        });

        return {'user': user, 'role': 'user', 'userData': userDoc.data()};
      }

      // Jika tidak ditemukan di semua collection, logout dan throw error
      await _auth.signOut();
      throw 'Akun tidak ditemukan';
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      // Cek apakah email sudah terdaftar di salah satu collection
      final emailExistsInAdmins = await _checkEmailExists('admins', email);
      final emailExistsInTerapis = await _checkEmailExists('terapis', email);
      final emailExistsInUsers = await _checkEmailExists('users', email);

      if (emailExistsInAdmins || emailExistsInTerapis || emailExistsInUsers) {
        throw 'Email sudah terdaftar';
      }

      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw 'Registrasi gagal';

      // Create user document in users collection
      final userData = {
        'nama': name,
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'lastLoginDevice': 'mobile',
        'isActive': true,
        'uid': user.uid,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      return {
        'user': user,
        'role': 'user',
        'userData': userData,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password terlalu lemah (minimal 6 karakter)';
          break;
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Gagal logout: $e';
    }
  }

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();
      if (adminDoc.exists) return 'admin';

      final terapisDoc =
          await _firestore.collection('terapis').doc(user.uid).get();
      if (terapisDoc.exists) return 'terapis';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) return 'user';

      return null;
    } catch (e) {
      return null;
    }
  }

  // Get initial route based on role
  String getInitialRoute(String role) {
    switch (role) {
      case 'admin':
        return AppRoutes.adminDashboard;
      case 'terapis':
        return AppRoutes.terapisDashboard;
      case 'user':
        return AppRoutes.userDashboard;
      default:
        return AppRoutes.login;
    }
  }

  // Get current user data based on role
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final role = await getCurrentUserRole();
      if (role == null) return null;

      DocumentSnapshot? doc;
      switch (role) {
        case 'admin':
          doc = await _firestore.collection('admins').doc(user.uid).get();
          break;
        case 'terapis':
          doc = await _firestore.collection('terapis').doc(user.uid).get();
          break;
        case 'user':
          doc = await _firestore.collection('users').doc(user.uid).get();
          break;
      }

      if (doc != null && doc.exists) {
        return {
          'uid': user.uid,
          'role': role,
          ...doc.data() as Map<String, dynamic>,
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current Firebase user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Helper method untuk cek email exists
  Future<bool> _checkEmailExists(String collection, String email) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Helper methods for role checking
  Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'admin';
  }

  Future<bool> isTerapis() async {
    final role = await getCurrentUserRole();
    return role == 'terapis';
  }

  Future<bool> isUser() async {
    final role = await getCurrentUserRole();
    return role == 'user';
  }
}
