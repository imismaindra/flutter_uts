import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AppToast.error(context, 'Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().login(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        AppToast.success(context, 'Login successful. Welcome back!');
        Navigator.pushReplacementNamed(context, '/');
      }
    } else {
      if (mounted) {
        AppToast.error(context, 'Invalid email or password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              // Brand Logo/Emblem
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9FF2E), width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.pedal_bike_rounded, color: Color(0xFFD9FF2E), size: 40),
              ),
              const SizedBox(height: 40),
              Text(
                'WELCOME BACK',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your premium account',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 60),
              
              // Inputs
              _buildInput('EMAIL ADDRESS', _emailController, Icons.alternate_email_rounded),
              const SizedBox(height: 24),
              _buildInput('PASSWORD', _passwordController, Icons.lock_outline_rounded, isPassword: true),
              
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'FORGOT PASSWORD?',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD9FF2E),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9FF2E),
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111827)))
                    : Text('SIGN IN', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DON\'T HAVE AN ACCOUNT?',
                      style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'SIGN UP',
                        style: GoogleFonts.outfit(color: const Color(0xFFD9FF2E), fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _obscurePassword = true;

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }
}
