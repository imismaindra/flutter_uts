import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AppToast.error(context, 'Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      name: _nameController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        AppToast.success(context, 'Account created successfully!');
        Navigator.pushReplacementNamed(context, '/');
      }
    } else {
      if (mounted) {
        AppToast.error(context, 'Registration failed. Try another email');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'CREATE ACCOUNT',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join the premium Element Bike community',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
              
              _buildInput('FULL NAME', _nameController, Icons.person_outline_rounded),
              const SizedBox(height: 24),
              _buildInput('EMAIL ADDRESS', _emailController, Icons.alternate_email_rounded),
              const SizedBox(height: 24),
              _buildInput('PASSWORD', _passwordController, Icons.lock_outline_rounded, isPassword: true),
              
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9FF2E),
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111827)))
                    : Text('CREATE ACCOUNT', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ALREADY HAVE AN ACCOUNT?',
                      style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'SIGN IN',
                        style: GoogleFonts.outfit(color: const Color(0xFFD9FF2E), fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
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
