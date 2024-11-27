import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'terapis_dashboard.dart';
import 'terapis_rpt.dart';
import 'terapis_profile.dart';
import '../../config/routes/app_routes.dart';

class TerapisBaseScreen extends StatefulWidget {
  final int initialIndex;

  const TerapisBaseScreen({Key? key, required this.initialIndex})
      : super(key: key);

  @override
  State<TerapisBaseScreen> createState() => _TerapisBaseScreenState();
}

class _TerapisBaseScreenState extends State<TerapisBaseScreen> {
  late int _selectedIndex;
  DateTime? _lastBackPressTime;
  final _auth = FirebaseAuth.instance;
  late String terapisId;
  late List<Widget> _screens;

  final List<String> _titles = [
    'YAMET Terapis',
    'Data RPT',
    'Re-evaluasi',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    terapisId = _auth.currentUser?.uid ?? '';
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = [
      TerapisDashboard(terapisId: terapisId),
      const TerapisRpt(),
      Container(), // Placeholder untuk Re-evaluasi karena akan di-handle dengan route
      const TerapisProfile(),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      if (index == 2) {
        // Index untuk Re-evaluasi
        Navigator.pushNamed(
          context,
          AppRoutes.terapisReEvaluasi,
          arguments: {
            'terapisId': terapisId, // ID terapis yang sedang login
          },
        );
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    }
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
        if (mounted) {
          await AppRoutes.handleLogout(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal logout. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFF4461F2),
              ),
              onPressed: _handleLogout,
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
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Dashboard',
                  ),
                  _buildNavBarItem(
                    index: 1,
                    icon: Icons.description_outlined,
                    activeIcon: Icons.description,
                    label: 'RPT',
                  ),
                  _buildNavBarItem(
                    index: 2,
                    icon: Icons
                        .assessment_outlined, // Ganti icon untuk Re-evaluasi
                    activeIcon:
                        Icons.assessment, // Ganti icon untuk Re-evaluasi
                    label: 'Re-evaluasi',
                  ),
                  _buildNavBarItem(
                    index: 3,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person,
                    label: 'Profile',
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
