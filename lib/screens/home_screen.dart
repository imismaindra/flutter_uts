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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCart();
    });
  }

  Future<void> _syncCart() async {
    final productProvider = context.read<ProductProvider>();
    final cartProvider = context.read<CartProvider>();
    
    // Tunggu sampai produk dimuat jika belum
    if (productProvider.products.isEmpty) {
      await productProvider.init();
    }
    
    if (mounted) {
      await cartProvider.loadCartFromDb(productProvider.products);
    }
  }

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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          SafeArea(
            child: _activeIndex == 0 
                ? _buildHomeView(provider) 
                : _buildShopView(context, provider, products, categories),
          ),
          
          // Premium Floating Navigation Bar
          _buildFloatingNavBar(context),
        ],
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHomeView(ProductProvider provider) {
    final featuredProducts = provider.products.take(3).toList();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          _buildHeroBanner(provider),
          const SizedBox(height: 24),
          _buildCategoryQuickAccess(provider),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('NEW ARRIVALS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                TextButton(
                  onPressed: () => setState(() => _activeIndex = 1),
                  child: Text('VIEW ALL', style: GoogleFonts.outfit(color: const Color(0xFF6B7280), fontWeight: FontWeight.w800, fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: featuredProducts.length,
              itemBuilder: (ctx, i) => TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (i * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                ),
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 16),
                  child: ProductCard(product: featuredProducts[i], index: i),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildBrandStory(),
        ],
      ),
    );
  }

  Widget _buildCategoryQuickAccess(ProductProvider provider) {
    final categories = provider.categories.where((c) => c != 'All').toList();
    final categoryColors = {
      'Road Bike': const Color(0xFF1E3A8A),
      'MTB': const Color(0xFF064E3B),
      'Folding': const Color(0xFF4C1D95),
      'Gravel': const Color(0xFF78350F),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('EXPLORE COLLECTIONS', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: const Color(0xFF9CA3AF))),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final baseColor = categoryColors[cat] ?? const Color(0xFF111827);
              
              return GestureDetector(
                onTap: () {
                  provider.setSelectedCategory(cat);
                  setState(() => _activeIndex = 1);
                },
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 500 + (i * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                  ),
                  child: Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Dark Blueprint Overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF111827).withOpacity(0.7),
                              const Color(0xFF1E3A8A).withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.toUpperCase(), 
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFD9FF2E),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('DISCOVER SERIES', 
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 15,
                        bottom: 0,
                        top: 0,
                        child: Icon(
                          _categoryIcons[cat] ?? Icons.pedal_bike_rounded,
                          color: Colors.white.withOpacity(0.1),
                          size: 80,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          ),
        ),
      ],
    );
  }

  Widget _buildShopView(BuildContext context, ProductProvider provider, List products, List<String> categories) {
    return Column(
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
    );
  }

  Widget _buildHeroBanner(ProductProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.pedal_bike_rounded, size: 200, color: const Color(0xFFD9FF2E)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFD9FF2E), borderRadius: BorderRadius.circular(4)),
                  child: Text('FEATURED', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 10)),
                ),
                const SizedBox(height: 12),
                Text('UNLEASH THE\nPERFORMANCE', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, height: 1)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _activeIndex = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9FF2E),
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('SHOP NOW', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandStory() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: const Color(0xFFD9FF2E), size: 32),
          const SizedBox(height: 16),
          Text('ENGINEERED FOR\nEXCELLENCE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, height: 1.1)),
          const SizedBox(height: 8),
          Text('Every Element bike is a masterpiece of technology and design, crafted for those who demand more from their ride.', 
            style: GoogleFonts.outfit(color: const Color(0xFF6B7280), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: const Icon(Icons.menu_rounded, color: Color(0xFF111827), size: 24),
            ),
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
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Color(0xFF1A1A1A)),
              onPressed: () => _showFilterSheet(context),
            ),
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Consumer<ProductProvider>(
          builder: (context, provider, _) => Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 40,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FILTER & SORT',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.resetFilters();
                        Navigator.pop(ctx);
                      },
                      child: Text('RESET', style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Price Range Section
                Text(
                  'PRICE RANGE',
                  style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${provider.minPrice.toInt()}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: const Color(0xFF111827))),
                    Text('\$${provider.maxPrice.toInt()}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: const Color(0xFF111827))),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(provider.minPrice, provider.maxPrice),
                  min: 0,
                  max: 10000,
                  divisions: 20,
                  activeColor: const Color(0xFFD9FF2E),
                  inactiveColor: const Color(0xFFF3F4F6),
                  onChanged: (RangeValues values) {
                    provider.setPriceRange(values.start, values.end);
                  },
                ),
                const SizedBox(height: 32),

                // Sort Section
                Text(
                  'SORT BY',
                  style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ['Newest', 'Price: Low to High', 'Price: High to Low'].map((s) {
                    final isSelected = s == provider.sortBy;
                    return GestureDetector(
                      onTap: () => provider.setSortBy(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF111827) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFF111827) : const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.outfit(
                            color: isSelected ? const Color(0xFFD9FF2E) : const Color(0xFF6B7280),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: const Color(0xFFD9FF2E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('APPLY FILTERS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Drawer(
      backgroundColor: const Color(0xFF111827),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF111827),
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (auth.isLoggedIn) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Color(0xFFD9FF2E), shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF111827), size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auth.userEmail?.split('@')[0].toUpperCase() ?? 'USER',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ] else ...[
                  Image.network(
                    'https://www.elementbike.id/wp-content/uploads/2021/04/Logo-Element-Bike-Horizontal-300x75.png',
                    width: 200,
                    color: const Color(0xFFD9FF2E),
                    errorBuilder: (_, __, ___) => Text(
                      'ELEMENT',
                      style: GoogleFonts.outfit(color: const Color(0xFFD9FF2E), fontWeight: FontWeight.w900, fontSize: 28),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _drawerItem(Icons.info_outline_rounded, 'ABOUT ELEMENT'),
          _drawerItem(Icons.storefront_rounded, 'STORE LOCATOR'),
          _drawerItem(Icons.support_agent_rounded, 'SUPPORT'),
          const Divider(color: Colors.white10, height: 40),
          if (auth.isLoggedIn)
            _drawerItem(Icons.logout_rounded, 'SIGN OUT', 
              color: const Color(0xFFEF4444),
              onTap: () {
                auth.logout();
                Navigator.pop(context);
              }
            )
          else
            _drawerItem(Icons.login_rounded, 'SIGN IN', 
              color: const Color(0xFFD9FF2E),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              }
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'v1.0.0 PRO EDITION',
              style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white.withOpacity(0.7)),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          color: color ?? Colors.white, 
          fontWeight: FontWeight.w600, 
          fontSize: 13, 
          letterSpacing: 0.5
        ),
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  void _handleProfileTap(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (auth.isAdmin) {
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
