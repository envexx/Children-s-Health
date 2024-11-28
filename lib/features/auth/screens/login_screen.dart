import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../config/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Handle login with email/password
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final result = await _authService.signIn(
          _emailController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Selamat datang, ${result['userData']?['nama'] ?? 'User'}'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          _authService.getInitialRoute(result['role']),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Selamat datang, ${result['userData']?['nama'] ?? 'Patient'}'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        _authService.getInitialRoute('patient'),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Container
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4461F2).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.medical_services_rounded,
                        size: 60,
                        color: Color(0xFF4461F2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Welcome Text
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF4461F2), Color(0xFF6E8AFF)],
                    ).createShader(bounds),
                    child: const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silakan masuk untuk melanjutkan',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(
                      'Email',
                      'Masukkan email Anda',
                      Icons.email_outlined,
                    ),
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _buildPasswordDecoration(),
                    validator: _passwordValidator,
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.forgotPassword),
                      child: const Text('Lupa Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF4461F2),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // OR Divider
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Atau',
                            style: TextStyle(color: Color(0xFF6B7280))),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google Sign In Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Image.asset('assets/google_logo.png', height: 24),
                    label: const Text(
                      'Masuk dengan Google',
                      style: TextStyle(
                        color: Color(0xFF1A1E25),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun?',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: Color(0xFF4461F2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for input decoration
  InputDecoration _buildInputDecoration(
      String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4461F2), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  InputDecoration _buildPasswordDecoration() {
    return _buildInputDecoration(
            'Password', 'Masukkan password Anda', Icons.lock_outline)
        .copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFF6B7280),
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    );
  }

  // Validators
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email harus diisi';
    if (!value.contains('@')) return 'Email tidak valid';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password harus diisi';
    return null;
  }
}
