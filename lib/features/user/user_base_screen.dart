// lib/features/user/user_base_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_dashboard.dart';
import 'user_keluhan.dart';
import 'user_laporan.dart';
import './user_assessment.dart';
import '../auth/services/auth_service.dart';
import '../../config/routes/app_routes.dart';

class UserBaseScreen extends StatefulWidget {
  final int initialIndex;

  const UserBaseScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<UserBaseScreen> createState() => _UserBaseScreenState();
}

class _UserBaseScreenState extends State<UserBaseScreen> {
  late int _selectedIndex;
  DateTime? _lastBackPressTime;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = [
    const UserDashboard(),
    const UserKeluhan(),
    const UserLaporan(),
    const UserAssessment(),
  ];

  final List<String> _titles = [
    'YAMET',
    'Keluhan',
    'Laporan',
    'Assessment',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _navigateToProfile() async {
    Navigator.pushNamed(context, AppRoutes.userProfile);
  }

  Future<void> _handleLogout() async {
    try {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (shouldLogout ?? false) {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal logout. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    } else {
      if (_lastBackPressTime == null ||
          DateTime.now().difference(_lastBackPressTime!) >
              const Duration(seconds: 2)) {
        _lastBackPressTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tekan sekali lagi untuk keluar'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: _selectedIndex != 0
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF4461F2),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                )
              : null,
          title: Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              color: Color(0xFF4461F2),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: _selectedIndex != 0,
          actions: [
            PopupMenuButton<String>(
              offset: const Offset(0, 45),
              icon: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF4461F2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF4461F2),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    _navigateToProfile();
                    break;
                  case 'logout':
                    _handleLogout();
                    break;
                }
              },
            ),
            const SizedBox(width: 8),
          ],
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem(
                    index: 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                  ),
                  _buildNavBarItem(
                    index: 1,
                    icon: Icons.message_outlined,
                    activeIcon: Icons.message_rounded,
                    label: 'Keluhan',
                  ),
                  _buildNavBarItem(
                    index: 2,
                    icon: Icons.description_outlined,
                    activeIcon: Icons.description_rounded,
                    label: 'Laporan',
                  ),
                  _buildNavBarItem(
                    index: 3,
                    icon: Icons.assessment_outlined,
                    activeIcon: Icons.assessment_rounded,
                    label: 'Assessment',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4461F2).withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? const Color(0xFF4461F2)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF4461F2)
                    : const Color(0xFF6B7280),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
