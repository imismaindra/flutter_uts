import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable Content ──────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Image ────────────────────────────────────────────
                SizedBox(
                  height: 450,
                  width: double.infinity,
                  child: Hero(
                    tag: 'image_${product.id}',
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(
                          Icons.broken_image_rounded,
                          size: 80,
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Product Info ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        product.name,
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rating row
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            final filled = i < product.rating.floor();
                            return Icon(
                              filled ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 20,
                              color: filled ? const Color(0xFFD9FF2E) : Colors.grey[300],
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${product.rating}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Price
                      Text(
                        product.formattedPrice,
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Specification Header
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'TECHNICAL SPECIFICATIONS',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        product.description,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF4B5563),
                          fontSize: 16,
                          height: 1.7,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Feature Grid (Simulated)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: const [
                          _SpecChip(icon: Icons.bolt_rounded, label: 'Pro Aero Frame'),
                          _SpecChip(icon: Icons.balance_rounded, label: '7.8kg Weight'),
                          _SpecChip(icon: Icons.settings_rounded, label: 'Shimano 105'),
                        ],
                      ),

                      // Bottom spacing for button
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Back Button & Actions overlay ────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back
                      _CircleBtn(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      // Edit & Delete (admin only)
                      if (context.watch<AuthProvider>().isAdmin)
                        Row(
                          children: [
                            _CircleBtn(
                              icon: Icons.edit_rounded,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/add-edit',
                                  arguments: product,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _CircleBtn(
                              icon: Icons.delete_rounded,
                              iconColor: Colors.red[600]!,
                              onTap: () => _confirmDelete(context, product),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Buy Button ────────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  final cart = context.read<CartProvider>();
                  cart.addToCart(product);
                  final totalItems = cart.totalItems;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF111827),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFFD9FF2E), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Added to your collection',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        textColor: const Color(0xFFD9FF2E),
                        onPressed: () => Navigator.pushNamed(context, '/cart'),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, weight: 800),
                    const SizedBox(width: 12),
                    Text(
                      'ADD TO CART',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'REMOVE PRODUCT',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to remove "${product.name}" from the catalog?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (product.id != null) {
                await context.read<ProductProvider>().deleteProduct(
                  product.id!,
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text('REMOVE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF111827)),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF111827),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: iconColor, size: 24),
        ),
      ),
    );
  }
}

