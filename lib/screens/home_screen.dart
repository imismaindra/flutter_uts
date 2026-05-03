import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _activeIndex = 0;

  static const _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'Road Bike': Icons.directions_bike_rounded,
    'MTB': Icons.terrain_rounded,
    'Folding': Icons.layers_rounded,
    'Gravel': Icons.alt_route_rounded,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.filteredProducts;
    final categories = provider.categories;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                _buildHeaderSection(provider),
                const SizedBox(height: 24),
                _buildSearchBar(context),
                const SizedBox(height: 12),
                _buildCategories(categories, provider),
                Expanded(
                  child: products.isEmpty 
                    ? _buildEmptyState()
                    : _buildProductGrid(products, provider),
                ),
              ],
            ),
          ),
          
          // Premium Floating Navigation Bar
          _buildFloatingNavBar(context),
        ],
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            'https://www.elementbike.id/wp-content/uploads/2021/04/Logo-Element-Bike-Horizontal-300x75.png',
            height: 24,
            errorBuilder: (_, __, ___) => Text(
              'ELEMENT',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: const Icon(Icons.menu_rounded, color: Color(0xFF111827), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COLLECTION 2024',
            style: GoogleFonts.outfit(
              color: const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.selectedCategory == 'All' 
                ? 'PREMIUM SERIES' 
                : provider.selectedCategory.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => context.read<ProductProvider>().setSearchQuery(v),
          decoration: InputDecoration(
            hintText: 'Search by model...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1A1A1A)),
            suffixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF1A1A1A)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(List<String> categories, ProductProvider provider) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isSelected = cat == provider.selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: () => context.read<ProductProvider>().setSelectedCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? null : Border.all(color: const Color(0xFFE5E7EB)),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: isSelected ? const Color(0xFFD9FF2E) : const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List products, ProductProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ProductCard(product: products[i], index: i),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'NO MODELS FOUND',
            style: GoogleFonts.outfit(
              color: Colors.grey[500],
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827).withOpacity(0.9),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _navItem(0, Icons.home_filled, 'HOME'),
                  _navItem(1, Icons.explore_rounded, 'SHOP'),
                  _navItem(2, Icons.shopping_bag_rounded, 'CART', 
                    badge: context.watch<CartProvider>().totalItems,
                    onTap: () => Navigator.pushNamed(context, '/cart')
                  ),
                  _navItem(3, Icons.person_rounded, 'PROFILE', 
                    onTap: () => _handleProfileTap(context)
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, {int badge = 0, VoidCallback? onTap}) {
    final isSelected = _activeIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _activeIndex = index);
        if (onTap != null) onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD9FF2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF111827) : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            if (badge > 0)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFD9FF2E), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$badge',
                    style: GoogleFonts.outfit(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    if (!context.watch<AuthProvider>().isAdmin) return null;
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/add-edit'),
      backgroundColor: const Color(0xFFD9FF2E),
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.add_rounded),
    );
  }

  void _handleProfileTap(BuildContext context) {
    if (context.read<AuthProvider>().isAdmin) {
      Navigator.pushNamed(context, '/admin');
    } else {
      _showAdminLoginDialog(context);
    }
  }

  void _showAdminLoginDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text(
          'ADMIN ACCESS',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter security PIN to access the management portal.',
              style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, letterSpacing: 4),
              decoration: InputDecoration(
                hintText: 'PIN CODE',
                hintStyle: GoogleFonts.outfit(letterSpacing: 0, fontWeight: FontWeight.w500, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == '1234') {
                context.read<AuthProvider>().setAdmin(true);
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/admin');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: const Color(0xFFD9FF2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text('VERIFY', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}


