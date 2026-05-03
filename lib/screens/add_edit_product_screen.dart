import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  double _rating = 4.5;
  bool _isNew = false;
  bool _isSaving = false;
  Product? _editProduct;

  final List<String> _categoryOptions = [
    'Road',
    'MTB',
    'Folding',
    'Gravel',
    'Urban',
    'Kids',
    'Electric',
    'Other',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editProduct == null) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is Product) {
        _editProduct = arg;
        _nameCtrl.text = arg.name;
        _categoryCtrl.text = arg.category;
        _priceCtrl.text = arg.price.toStringAsFixed(0);
        _imageCtrl.text = arg.image;
        _descCtrl.text = arg.description;
        _rating = arg.rating;
        _isNew = arg.isNew;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => _editProduct != null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final product = Product(
      id: _editProduct?.id,
      name: _nameCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      image: _imageCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      rating: _rating,
      isNew: _isNew,
    );

    final provider = context.read<ProductProvider>();
    if (_isEditing) {
      await provider.updateProduct(product);
    } else {
      await provider.addProduct(product);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF111827),
          content: Text(
            _isEditing
                ? '${product.name.toUpperCase()} UPDATED'
                : '${product.name.toUpperCase()} ADDED TO CATALOG',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFFD9FF2E)),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'EDIT BIKE' : 'ADD NEW MODEL',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Preview Image ─────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _imageCtrl.text.isNotEmpty ? 220 : 0,
              margin: EdgeInsets.only(bottom: _imageCtrl.text.isNotEmpty ? 24 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFF3F4F6),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageCtrl.text.isNotEmpty
                  ? Image.network(
                      _imageCtrl.text,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.broken_image_rounded,
                                size: 48, color: Color(0xFFD1D5DB)),
                            const SizedBox(height: 12),
                            Text(
                              'INVALID IMAGE URL',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            _buildSectionHeader('CORE INFORMATION'),
            const SizedBox(height: 16),
            _buildField(
              controller: _nameCtrl,
              label: 'MODEL NAME',
              icon: Icons.pedal_bike_rounded,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _categoryOptions.contains(_categoryCtrl.text) && _categoryCtrl.text.isNotEmpty
                  ? _categoryCtrl.text
                  : null,
              decoration: _inputDecoration('CATEGORY', Icons.grid_view_rounded),
              items: _categoryOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _categoryCtrl.text = v);
              },
              validator: (v) =>
                  v == null || v.isEmpty ? 'Category is required' : null,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, 
                  color: const Color(0xFF111827),
                  fontSize: 14),
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 16),

            _buildField(
              controller: _priceCtrl,
              label: 'PRICE (USD)',
              icon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                if (double.tryParse(v.trim()) == null) return 'Invalid format';
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('ASSETS & DESCRIPTION'),
            const SizedBox(height: 16),
            
            _buildField(
              controller: _imageCtrl,
              label: 'IMAGE SOURCE URL',
              icon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Image URL is required' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _descCtrl,
              label: 'TECHNICAL DESCRIPTION',
              icon: Icons.subject_rounded,
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Description is required' : null,
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('ATTRIBUTES'),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RATING',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _rating.toStringAsFixed(1),
                          style: GoogleFonts.outfit(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _rating,
                    min: 1,
                    max: 5,
                    divisions: 8,
                    activeColor: const Color(0xFF111827),
                    inactiveColor: const Color(0xFFE5E7EB),
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                  const Divider(height: 32),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'NEW COLLECTION STATUS',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    value: _isNew,
                    onChanged: (v) => setState(() => _isNew = v),
                    activeColor: colorScheme.primary,
                    activeTrackColor: const Color(0xFF111827),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // ── Save Button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                      )
                    : Text(
                        _isEditing ? 'UPDATE MODEL' : 'PUBLISH TO CATALOG',
                        style: GoogleFonts.outfit(
                            fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: const Color(0xFF111827)),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.0,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(
        color: const Color(0xFF9CA3AF),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF111827)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.outfit(
          fontWeight: FontWeight.w700, 
          color: const Color(0xFF111827),
          fontSize: 15),
      decoration: _inputDecoration(label, icon),
    );
  }
}

