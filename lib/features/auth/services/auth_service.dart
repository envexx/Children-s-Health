import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../config/routes/app_routes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign In untuk patient
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google Sign In dibatalkan';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw 'Login gagal';

      // Cek apakah email sudah terdaftar di collection admin atau terapis
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();
      final terapisDoc =
          await _firestore.collection('terapis').doc(user.uid).get();

      if (adminDoc.exists || terapisDoc.exists) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        throw 'Email ini terdaftar sebagai admin/terapis. Gunakan email lain untuk akun patient.';
      }

      // Cek atau buat dokumen patient
      final patientDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!patientDoc.exists) {
        // Buat dokumen patient baru
        final userData = {
          'name': user.displayName ?? 'Patient',
          'email': user.email,
          'role': 'patient',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'lastLoginDevice': 'mobile',
          'isActive': true,
          'uid': user.uid,
          'photoURL': user.photoURL,
          'loginMethod': 'google'
        };

        await _firestore.collection('users').doc(user.uid).set(userData);
        return {'user': user, 'role': 'patient', 'userData': userData};
      }

      // Update last login untuk patient yang sudah ada
      await patientDoc.reference.update({
        'lastLogin': FieldValue.serverTimestamp(),
        'lastLoginDevice': 'mobile',
      });

      return {'user': user, 'role': 'patient', 'userData': patientDoc.data()};
    } catch (e) {
      throw e.toString();
    }
  }

  // Login with email and password (untuk semua role)
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw 'Login gagal';

      // Cek di collection admins
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();
      if (adminDoc.exists) {
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
        await terapisDoc.reference.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'lastLoginDevice': 'mobile',
        });
        return {'user': user, 'role': 'terapis', 'userData': terapisDoc.data()};
      }

      // Cek di collection users (patients)
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        await userDoc.reference.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'lastLoginDevice': 'mobile',
        });
        return {'user': user, 'role': 'patient', 'userData': userDoc.data()};
      }

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

  // Register patient with email
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      // Cek email di semua collection
      final emailExistsInAdmins = await _checkEmailExists('admins', email);
      final emailExistsInTerapis = await _checkEmailExists('terapis', email);
      final emailExistsInUsers = await _checkEmailExists('users', email);

      if (emailExistsInAdmins || emailExistsInTerapis || emailExistsInUsers) {
        throw 'Email sudah terdaftar';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw 'Registrasi gagal';

      final userData = {
        'name': name,
        'email': email,
        'role': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'lastLoginDevice': 'mobile',
        'isActive': true,
        'uid': user.uid,
        'loginMethod': 'email'
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      return {'user': user, 'role': 'patient', 'userData': userData};
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
      await _googleSignIn.signOut();
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
      if (userDoc.exists) return 'patient';

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
      case 'patient':
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
        case 'patient':
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

  Future<bool> isPatient() async {
    final role = await getCurrentUserRole();
    return role == 'patient';
  }
}
