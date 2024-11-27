import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/routes/app_routes.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'totalTerapis': 0,
    'totalChildren': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final terapisSnapshot = await _firestore.collection('terapis').get();
      final childrenSnapshot = await _firestore.collection('children').get();

      if (mounted) {
        setState(() {
          _stats = {
            'totalUsers': usersSnapshot.docs.length,
            'totalTerapis': terapisSnapshot.docs.length,
            'totalChildren': childrenSnapshot.docs.length,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Error loading stats: $e');
    }
  }

  void _navigateToDataList(BuildContext context, String type) {
    switch (type) {
      case 'terapis':
        Navigator.pushNamed(context, AppRoutes.adminTerapisList);
        break;
      case 'users':
        // Navigator.pushNamed(context, AppRoutes.adminUsersList);
        break;
      case 'children':
        Navigator.pushNamed(context, AppRoutes.adminChildren);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Stats Card with Gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF3B82F6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Total Data',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                        'Users', _stats['totalUsers'], Icons.people_outline),
                    _buildStatItem('Terapis', _stats['totalTerapis'],
                        Icons.medical_services_outlined),
                    _buildStatItem(
                        'Anak', _stats['totalChildren'], Icons.child_care),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Welcome Message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Selamat Datang, Admin!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Access Title
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Access Menu
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAccessItem(
                context,
                'Data User',
                Icons.people,
                () => _navigateToDataList(context, 'users'),
              ),
              _buildQuickAccessItem(
                context,
                'Data Terapis',
                Icons.medical_services,
                () => _navigateToDataList(context, 'terapis'),
              ),
              _buildQuickAccessItem(
                context,
                'Data Anak',
                Icons.child_care,
                () => _navigateToDataList(context, 'children'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 2, // 2 items per row
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
