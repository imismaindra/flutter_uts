import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../main.dart'; // Add this for navigatorKey
import '../providers/auth_provider.dart';
import '../utils/app_toast.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Immersive Hero Section ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 400,
                backgroundColor: const Color(0xFFF3F4F6),
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: const Color(0xFFF3F4F6),
                    child: Center(
                      child: Hero(
                        tag: 'image_${product.id}',
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: product.image.startsWith('http')
                            ? Image.network(
                                product.image,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.pedal_bike_rounded, size: 100, color: Color(0xFFD1D5DB)),
                              )
                            : Image.file(
                                File(product.image),
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.pedal_bike_rounded, size: 100, color: Color(0xFFD1D5DB)),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Product Details Content ─────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -32, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb / Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.category.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.formattedPrice,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFD9FF2E),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Product Name
                      Text(
                        product.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Rating Summary
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFD9FF2E), size: 22),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(height: 14, width: 1.5, color: const Color(0xFFE5E7EB)),
                          const SizedBox(width: 12),
                          Text(
                            '120 REVIEWS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Description Section
                      _buildSectionTitle('THE STORY'),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF4B5563),
                          fontSize: 16,
                          height: 1.7,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Technical Specifications Grid
                      _buildSectionTitle('TECHNICAL DATA'),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.2,
                        children: const [
                          _TechnicalItem(icon: Icons.architecture_rounded, label: 'FRAME', value: 'ALX ALLOY'),
                          _TechnicalItem(icon: Icons.settings_rounded, label: 'FORK', value: 'CARBON'),
                          _TechnicalItem(icon: Icons.speed_rounded, label: 'DRIVETRAIN', value: 'SHIMANO 105'),
                          _TechnicalItem(icon: Icons.balance_rounded, label: 'WEIGHT', value: '8.4 KG'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Header Actions (Glassmorphic) ────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    if (context.watch<AuthProvider>().isAdmin)
                      Row(
                        children: [
                          _GlassButton(
                            icon: Icons.edit_rounded,
                            onTap: () => Navigator.pushNamed(context, '/add-edit', arguments: product),
                          ),
                          const SizedBox(width: 12),
                          _GlassButton(
                            icon: Icons.delete_rounded,
                            color: Colors.red[400],
                            onTap: () => _confirmDelete(context, product),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.favorite_border_rounded, color: Color(0xFF111827)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CartProvider>().addToCart(product);
                        AppToast.success(context, 'ADDED TO COLLECTION');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        foregroundColor: const Color(0xFFD9FF2E),
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'ADD TO COLLECTION',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: const Color(0xFFD9FF2E)),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('DELETE MODEL', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to remove this model from the catalog?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (product.id != null) await context.read<ProductProvider>().deleteProduct(product.id!);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}

class _TechnicalItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TechnicalItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
              Text(value, style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF111827), fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _GlassButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color ?? const Color(0xFF111827), size: 24),
          ),
        ),
      ),
    );
  }
}


