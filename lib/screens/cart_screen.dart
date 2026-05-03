import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'MY CART',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          if (cart.totalItems > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${cart.totalItems} ITEMS',
                style: GoogleFonts.outfit(
                  color: colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                // ── Item List ───────────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItem(context, item, cart);
                    },
                  ),
                ),

                // ── Order Summary + Checkout ────────────────────────────────
                _buildCheckoutBar(context, cart),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, item, CartProvider cart) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              item.product.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: const Color(0xFFF3F4F6),
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name.toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: const Color(0xFF111827)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.category.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.product.formattedPrice,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Delete
              GestureDetector(
                onTap: () => cart.removeItem(item.product.id!),
                child: const Icon(Icons.close_rounded,
                    color: Color(0xFF9CA3AF), size: 20),
              ),
              const SizedBox(height: 24),

              // +/- controls
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    _qtyBtn(
                      icon: Icons.remove_rounded,
                      onTap: () => cart.decrement(item.product.id!),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, 
                            fontSize: 14,
                            color: const Color(0xFF111827)),
                      ),
                    ),
                    _qtyBtn(
                      icon: Icons.add_rounded,
                      onTap: () => cart.increment(item.product.id!),
                      isPrimary: true,
                      primaryColor: const Color(0xFF111827),
                      iconColor: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    Color primaryColor = Colors.white,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon,
            size: 16,
            color: isPrimary ? (iconColor ?? Colors.white) : const Color(0xFF111827)),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cart) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = cart.totalPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SUBTOTAL',
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              Text(
                total >= 1000
                    ? '\$${(total / 1000).toStringAsFixed(1)}K'
                    : '\$${total.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SHIPPING',
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              Text('FREE',
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF10B981), 
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(
                total >= 1000
                    ? '\$${(total / 1000).toStringAsFixed(1)}K'
                    : '\$${total.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _checkout(context, cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                'PROCEED TO CHECKOUT',
                style: GoogleFonts.outfit(
                    fontSize: 15, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 64, color: Color(0xFFD1D5DB)),
            ),
            const SizedBox(height: 32),
            Text(
              'YOUR CART IS EMPTY',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Explore our premium collection and start your cycling journey today.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  color: const Color(0xFF6B7280),
                  fontSize: 15,
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('START SHOPPING',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkout(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('ORDER CONFIRMED',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Text(
          'Your request for ${cart.totalItems} items has been received. Our team will contact you shortly for payment and delivery.',
          style: GoogleFonts.outfit(height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: Text('GREAT', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
