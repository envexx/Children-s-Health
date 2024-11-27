// lib/config/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Auth Screens Import
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password.dart';

// Admin Route Import
import '../../features/admin/admin_base_screen.dart';
import '../../features/admin/admin_terapis.dart';
import '../../features/admin/admin_terapis_detail.dart';
import '../../features/admin/admin_rpt_list.dart';
import '../../features/admin/admin_rpt_detail.dart';
import '../../features/admin/admin_keluhan_list.dart';
import '../../features/admin/admin_keluhan_detail.dart';
import '../../features/admin/admin_anak.dart';

// Terapis Route Import
import '../../features/terapis/terapis_base_screen.dart';
import '../../features/terapis/terapis_rpt_list.dart';
import '../../features/terapis/terapis_rpt_create.dart';
import '../../features/terapis/terapis_rpt_detail.dart';
import '../../features/terapis/terapis_rpt_edit.dart';
import '../../features/terapis/terapis_laporan_list.dart';
import '../../features/terapis/terapis_laporan_create.dart';
import '../../features/terapis/terapis_laporan_detail.dart';
import '../../features/terapis/terapis_re_evaluasi.dart';
import '../../features/terapis/terapis_re_evaluasi_detail.dart';

// User Route Import
import '../../features/user/user_base_screen.dart';
import '../../features/user/user_profile.dart';
import '../../features/user/user_keluhan_review.dart';
import '../../features/user/user_keluhan1.dart';
import '../../features/user/user_keluhan2.dart';
import '../../features/user/user_keluhan3.dart';
import '../../features/user/user_keluhan4.dart';
import '../../features/user/user_keluhan5.dart';
import '../../features/user/user_keluhan6.dart';
import '../../features/user/user_keluhan7.dart';

class AppRoutes {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  // Routes String Declaration
  static const String root = '/';
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Admin Routes
  static const String adminBase = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminKeluhan = '/admin/keluhan';
  static const String adminRpt = '/admin/rpt';
  static const String adminProfile = '/admin/profile';
  static const String adminTerapisList = '/admin/terapis/list';
  static const String adminTerapisDetail = '/admin/terapis/detail';
  static const String adminRptList = '/admin/rpt/list';
  static const String adminRptDetail = '/admin/rpt/detail';
  static const String adminKeluhanList = '/admin/keluhan/list';
  static const String adminKeluhanDetail = '/admin/keluhan/detail';
  static const String adminChildren = '/admin/children';

  // Terapis Routes
  static const String terapisBase = '/terapis';
  static const String terapisDashboard = '/terapis/dashboard';
  static const String terapisRpt = '/terapis/rpt';
  static const String terapisLaporan = '/terapis/laporan';
  static const String terapisProfile = '/terapis/profile';
  static const String terapisRptList = '/terapis/rpt/list';
  static const String terapisRptCreate = '/terapis/rpt/create';
  static const String terapisRptDetail = '/terapis/rpt/detail';
  static const String terapisRptEdit = '/terapis/rpt/edit';
  static const String terapisLaporanList = '/terapis/laporan/list';
  static const String terapisLaporanCreate = '/terapis/laporan/create';
  static const String terapisLaporanDetail = '/terapis/laporan/detail';
  static const String terapisReEvaluasi = '/terapis/reevaluasi';
  static const String terapisReEvaluasiDetail = '/terapis/reevaluasi/detail';

  // User Routes
  static const String userBase = '/user';
  static const String userDashboard = '/user/dashboard';
  static const String userKeluhan = '/user/keluhan';
  static const String userLaporan = '/user/laporan';
  static const String userAssessment = '/user/assessment';
  static const String userProfile = '/user/profile';
  static const String userKeluhanReview = '/user/review';
  static const String userKeluhan1 = '/user/keluhan/1';
  static const String userKeluhan2 = '/user/keluhan/2';
  static const String userKeluhan3 = '/user/keluhan/3';
  static const String userKeluhan4 = '/user/keluhan/4';
  static const String userKeluhan5 = '/user/keluhan/5';
  static const String userKeluhan6 = '/user/keluhan/6';
  static const String userKeluhan7 = '/user/keluhan/7';

  // Helper Functions
  static Future<String?> _checkUserRole(String uid) async {
    try {
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) return 'admin';

      final terapisDoc = await _firestore.collection('terapis').doc(uid).get();
      if (terapisDoc.exists) return 'terapis';

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) return 'user';

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> handleLogout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        login,
        (route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final user = _auth.currentUser;
    final args = settings.arguments;

    // Handle splash screen
    if (settings.name == splash) {
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    }

    // Handle auth routes
    if (settings.name == login ||
        settings.name == register ||
        settings.name == forgotPassword) {
      if (user != null) {
        return MaterialPageRoute(
          builder: (context) => FutureBuilder<String?>(
            future: _checkUserRole(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                String route;
                switch (snapshot.data) {
                  case 'admin':
                    route = adminDashboard;
                    break;
                  case 'terapis':
                    route = terapisDashboard;
                    break;
                  default:
                    route = userDashboard;
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    route,
                    (route) => false,
                  );
                });
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      }

      return MaterialPageRoute(
        builder: (_) => settings.name == login
            ? const LoginScreen()
            : settings.name == register
                ? const RegisterScreen()
                : const ForgotPasswordScreen(),
      );
    }

    // Check auth for other routes
    if (user == null) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    }

    // Role-based routing
    return MaterialPageRoute(
      builder: (context) => FutureBuilder<String?>(
        future: _checkUserRole(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final role = snapshot.data!;
            final requestedRoute = settings.name!;
            bool hasAccess = false;

            // Check route access
            if (role == 'admin' && requestedRoute.startsWith('/admin')) {
              hasAccess = true;
            } else if (role == 'terapis' &&
                requestedRoute.startsWith('/terapis')) {
              hasAccess = true;
            } else if (role == 'user' && requestedRoute.startsWith('/user')) {
              hasAccess = true;
            }

            if (!hasAccess) {
              String route;
              switch (role) {
                case 'admin':
                  route = adminDashboard;
                  break;
                case 'terapis':
                  route = terapisDashboard;
                  break;
                default:
                  route = userDashboard;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  route,
                  (route) => false,
                );
              });
              return const Center(child: CircularProgressIndicator());
            }

            // Return appropriate screen based on route
            switch (settings.name) {
              // Admin Routes
              case adminBase:
              case adminDashboard:
                return const AdminBaseScreen(initialIndex: 0);
              case adminKeluhan:
                return const AdminBaseScreen(initialIndex: 1);
              case adminRpt:
                return const AdminBaseScreen(initialIndex: 2);
              case adminProfile:
                return const AdminBaseScreen(initialIndex: 3);
              case adminTerapisList:
                return AdminTerapisList();
              case adminTerapisDetail:
                if (args is String) {
                  return AdminTerapisDetail(terapisId: args);
                }
                return _buildErrorScreen();

              case adminRptList:
                print('Processing adminRptList route with args: $args');
                if (args == null) {
                  print('Error: No arguments provided for RPT list');
                  return _buildErrorScreen();
                }

                if (args is! Map<String, dynamic>) {
                  print('Error: Arguments is not Map<String, dynamic>');
                  print('Actual type: ${args.runtimeType}');
                  return _buildErrorScreen();
                }

                final terapisId = args['terapisId'];
                final terapisName = args['terapisName'];

                if (terapisId == null || terapisName == null) {
                  print('Error: Missing required arguments');
                  print('terapisId: $terapisId');
                  print('terapisName: $terapisName');
                  return _buildErrorScreen();
                }

                if (terapisId is! String || terapisName is! String) {
                  print('Error: Invalid argument types');
                  print('terapisId type: ${terapisId.runtimeType}');
                  print('terapisName type: ${terapisName.runtimeType}');
                  return _buildErrorScreen();
                }

                print('Creating AdminRptList with:');
                print('terapisId: $terapisId');
                print('terapisName: $terapisName');

                return AdminRptList(
                  terapisId: terapisId,
                  terapisName: terapisName,
                );
              case adminRptDetail:
                if (args is Map<String, dynamic>) {
                  return AdminRptDetail(
                    rptId: args['rptId'],
                    terapisName: args['terapisName'],
                  );
                }
                return _buildErrorScreen();
              case adminKeluhanList:
                return const AdminKeluhanList();
              case adminKeluhanDetail:
                if (args is Map<String, dynamic>) {
                  return AdminKeluhanDetail(keluhanData: args);
                }
                return _buildErrorScreen();
              case adminChildren:
                return ChildrenListScreen();
              // Terapis Routes
              case terapisBase:
              case terapisDashboard:
                return const TerapisBaseScreen(initialIndex: 0);
              case terapisRpt:
                return const TerapisBaseScreen(initialIndex: 1);
              case terapisLaporan:
                return const TerapisBaseScreen(initialIndex: 2);
              case terapisProfile:
                return const TerapisBaseScreen(initialIndex: 3);
              case terapisRptList:
                return const TerapisRptList();
              case terapisRptCreate:
                return const TerapisRptCreate();
              case terapisRptDetail:
                if (args is String) {
                  return TerapisRptDetail(rptId: args);
                }
                return _buildErrorScreen();
              case terapisRptEdit:
                if (args is Map<String, dynamic>) {
                  return TerapisRptEdit(rptData: args);
                }
                return _buildErrorScreen();
              case terapisLaporanList:
                return const TerapisLaporanList();
              case terapisLaporanCreate:
                return const TerapisLaporanCreate();
              case terapisLaporanDetail:
                if (args is Map<String, dynamic>) {
                  return TerapisLaporanDetail(laporanData: args);
                }
                return _buildErrorScreen();

              case terapisReEvaluasi:
                print('Processing terapisReEvaluasi route with args: $args');
                if (args == null) {
                  print('Error: No arguments provided for ReEvaluasi');
                  return _buildErrorScreen();
                }

                if (args is! Map<String, dynamic>) {
                  print('Error: Arguments is not Map<String, dynamic>');
                  print('Actual type: ${args.runtimeType}');
                  return _buildErrorScreen();
                }

                final terapisId = args['terapisId'];

                if (terapisId == null) {
                  print('Error: Missing required arguments');
                  print('terapisId: $terapisId');
                  return _buildErrorScreen();
                }

                if (terapisId is! String) {
                  print('Error: Invalid argument type');
                  print('terapisId type: ${terapisId.runtimeType}');
                  return _buildErrorScreen();
                }

                print('Creating TerapisReEvaluasi with:');
                print('terapisId: $terapisId');

                return TerapisReEvaluasi(terapisId: terapisId);

              case terapisReEvaluasiDetail:
                if (args is Map<String, dynamic>) {
                  return TerapisReEvaluasiDetail(
                    rptId: args['rptId'],
                    childName: args['childName'],
                    reviewStatus: args['reviewStatus'] ?? const {},
                  );
                }
                return _buildErrorScreen();

              // User Routes
              case userBase:
              case userDashboard:
                return const UserBaseScreen(initialIndex: 0);
              case userKeluhan:
                return const UserBaseScreen(initialIndex: 1);
              case userLaporan:
                return const UserBaseScreen(initialIndex: 2);
              case userAssessment:
                return const UserBaseScreen(initialIndex: 3);
              case userProfile:
                return const UserProfile();
              case userKeluhanReview:
                return const UserKeluhanReview();
              case userKeluhan1:
                return const UserKeluhan1();
              case userKeluhan2:
                return const UserKeluhan2();
              case userKeluhan3:
                return const UserKeluhan3();
              case userKeluhan4:
                return const UserKeluhan4();
              case userKeluhan5:
                return const UserKeluhan5();
              case userKeluhan6:
                return const UserKeluhan6();
              case userKeluhan7:
                return const UserKeluhan7();

              default:
                return _buildErrorScreen();
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            handleLogout(context);
          });
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  static Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Halaman tidak ditemukan',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _auth.signOut(),
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    );
  }
}
