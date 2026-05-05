import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  String? _avatarPath;
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(text: auth.userName);
    _emailCtrl = TextEditingController(text: auth.userEmail);
    _passwordCtrl = TextEditingController();
    _avatarPath = auth.userAvatar;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      
      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
        final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
        
        setState(() {
          _avatarPath = savedImage.path;
        });
      }
    } catch (e) {
      AppToast.error(context, 'Failed to pick image: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    
    try {
      final success = await auth.updateProfile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text.trim() : null,
        avatar: _avatarPath,
      );
      
      if (success && mounted) {
        AppToast.success(context, 'PROFILE UPDATED SUCCESSFULLY');
        Navigator.pop(context);
      } else if (mounted) {
        AppToast.error(context, 'UPDATE FAILED');
      }
    } catch (e) {
      if (mounted) AppToast.error(context, 'ERROR: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ACCOUNT PROFILE',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
            color: const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD9FF2E), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _avatarPath != null
                          ? Image.file(File(_avatarPath!), fit: BoxFit.cover)
                          : Center(
                              child: Text(
                                auth.userName?[0].toUpperCase() ?? 'U',
                                style: GoogleFonts.outfit(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFD9FF2E), size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9FF2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  auth.isAdmin ? 'ADMINISTRATOR' : 'MEMBER',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            _buildField(
              controller: _nameCtrl,
              label: 'FULL NAME',
              hint: 'Enter your name',
              icon: Icons.person_outline_rounded,
              validator: (v) => v!.isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 24),
            _buildField(
              controller: _emailCtrl,
              label: 'EMAIL ADDRESS',
              hint: 'Enter your email',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Email required' : null,
            ),
            const SizedBox(height: 24),
            _buildField(
              controller: _passwordCtrl,
              label: 'NEW PASSWORD',
              hint: 'Leave blank to keep current',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: const Color(0xFFD9FF2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD9FF2E)))
                    : Text(
                        'SAVE CHANGES',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: const Color(0xFFD1D5DB), fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, color: const Color(0xFF111827), size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
