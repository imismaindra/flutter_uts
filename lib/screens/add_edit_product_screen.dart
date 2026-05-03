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
    'Road Bike',
    'MTB',
    'Folding',
    'Gravel',
    'Urban',
    'Kids',
    'Electric',
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
    try {
      if (_isEditing) {
        await provider.updateProduct(product);
      } else {
        await provider.addProduct(product);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEditing ? 'EDIT MODEL' : 'NEW COLLECTION',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
            color: const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Image Preview Card
            _buildImagePreview(),
            const SizedBox(height: 32),
            
            _buildSectionHeader('SPECIFICATIONS'),
            const SizedBox(height: 20),
            _buildField(
              controller: _nameCtrl,
              label: 'MODEL IDENTIFIER',
              hint: 'e.g., ELEMENT POLICE TORONTO',
              icon: Icons.badge_outlined,
              validator: (v) => v!.isEmpty ? 'Identifier required' : null,
            ),
            const SizedBox(height: 20),
            _buildCategoryDropdown(),
            const SizedBox(height: 20),
            _buildField(
              controller: _priceCtrl,
              label: 'RETAIL PRICE (USD)',
              hint: '0.00',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Price required' : null,
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('MARKETING & ASSETS'),
            const SizedBox(height: 20),
            _buildField(
              controller: _imageCtrl,
              label: 'PRODUCT IMAGE URL',
              hint: 'https://...',
              icon: Icons.image_search_outlined,
              onChanged: (_) => setState(() {}),
              validator: (v) => v!.isEmpty ? 'Image URL required' : null,
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _descCtrl,
              label: 'TECHNICAL OVERVIEW',
              hint: 'Detailed specifications and features...',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Description required' : null,
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('ATTRIBUTES'),
            const SizedBox(height: 20),
            _buildAttributesCard(),
            
            const SizedBox(height: 48),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final hasImage = _imageCtrl.text.isNotEmpty;
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _imageCtrl.text,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PREVIEW',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD9FF2E),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate_outlined, size: 48, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          Text(
            'NO IMAGE SELECTED',
            style: GoogleFonts.outfit(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 2.0,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: const Color(0xFFD1D5DB), fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, color: const Color(0xFF111827), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF111827), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'CATEGORY',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _categoryOptions.contains(_categoryCtrl.text) ? _categoryCtrl.text : null,
          items: _categoryOptions
              .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
              .toList(),
          onChanged: (v) => setState(() => _categoryCtrl.text = v!),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.grid_view_rounded, color: Color(0xFF111827), size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttributesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BRAND RATING',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _rating.toStringAsFixed(1),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFD9FF2E),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: const Color(0xFF111827),
            inactiveColor: const Color(0xFFF3F4F6),
            onChanged: (v) => setState(() => _rating = v),
          ),
          const Divider(height: 40),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'NEW ARRIVAL BADGE',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12),
            ),
            subtitle: Text(
              'Display in featured collection',
              style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF9CA3AF)),
            ),
            value: _isNew,
            onChanged: (v) => setState(() => _isNew = v),
            activeColor: const Color(0xFF111827),
            activeTrackColor: const Color(0xFFD9FF2E),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111827),
          foregroundColor: const Color(0xFFD9FF2E),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(
                _isEditing ? 'UPDATE SPECIFICATIONS' : 'PUBLISH TO CATALOG',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
      ),
    );
  }
}
