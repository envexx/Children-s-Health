import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/routes/app_routes.dart';

class UserDashboard extends StatefulWidget {
  final VoidCallback? onNavigationItemSelected;

  const UserDashboard({
    Key? key,
    this.onNavigationItemSelected,
  }) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists) {
          setState(() {
            _userName = userData.data()?['name'] ?? 'User';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToKeluhan() {
    Navigator.pushReplacementNamed(context, AppRoutes.userKeluhan);
  }

  void _navigateToLaporan() {
    Navigator.pushReplacementNamed(context, AppRoutes.userLaporan);
  }

  void _navigateToAssessment() {
    Navigator.pushReplacementNamed(context, AppRoutes.userAssessment);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive scaling
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate scale factor based on design width (assuming 375px as base)
    final scale = screenWidth / 375;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4461F2),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4461F2),
      onRefresh: _loadUserData,
      child: ListView(
        padding: EdgeInsets.all(24 * scale),
        children: [
          // Welcome Section
          Text(
            'Hello, $_userName',
            style: TextStyle(
              fontSize: 28 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1E25),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Welcome back to YAMET',
            style: TextStyle(
              fontSize: 16 * scale,
              color: const Color(0xFF6B7280),
            ),
          ),

          SizedBox(height: 32 * scale),

          // Info Card
          InkWell(
            onTap: _navigateToKeluhan,
            borderRadius: BorderRadius.circular(16 * scale),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF4461F2),
                borderRadius: BorderRadius.circular(16 * scale),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4461F2).withOpacity(0.2),
                    blurRadius: 16 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: Colors.white,
                      size: 24 * scale,
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    'Your Medical Treatment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Monitor perkembangan anak Anda dengan mudah',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32 * scale),

          // Quick Menu Section
          Text(
            'Quick Menu',
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1E25),
            ),
          ),

          SizedBox(height: 16 * scale),

          // Menu Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16 * scale,
            crossAxisSpacing: 16 * scale,
            childAspectRatio: 1.1,
            children: [
              _buildMenuCard(
                title: 'Keluhan',
                subtitle: 'Submit keluhan Anda',
                icon: Icons.message_outlined,
                color: const Color(0xFF4461F2),
                onTap: _navigateToKeluhan,
                scale: scale,
              ),
              _buildMenuCard(
                title: 'Laporan',
                subtitle: 'Lihat perkembangan',
                icon: Icons.description_outlined,
                color: const Color(0xFF4461F2),
                onTap: _navigateToLaporan,
                scale: scale,
              ),
              _buildMenuCard(
                title: 'Assessment',
                subtitle: 'Data evaluasi',
                icon: Icons.assessment_outlined,
                color: const Color(0xFF4461F2),
                onTap: _navigateToAssessment,
                scale: scale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double scale,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * scale),
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(icon, size: 24 * scale, color: color),
            ),
            SizedBox(height: 12 * scale),
            Text(
              title,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1E25),
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12 * scale,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
