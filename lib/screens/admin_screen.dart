import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/currency_formatter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ProductProvider>();
    final products = provider.products;

    if (!auth.isAdmin) {
      return _buildAccessDenied(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(provider, products),
            _buildInventoryTab(context, provider, products),
            _buildUsersTab(context, auth),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 1 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/add-edit'),
            backgroundColor: const Color(0xFF111827),
            foregroundColor: const Color(0xFFD9FF2E),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'NEW MODEL',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
          )
        : null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 140,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HELLO, ${auth.userEmail?.split('@')[0].toUpperCase() ?? 'ADMIN'}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'CONTROL CENTER',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PRO',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD9FF2E),
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFF111827)),
          onPressed: () {
            context.read<AuthProvider>().logout();
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        labelColor: const Color(0xFF111827),
        unselectedLabelColor: const Color(0xFF9CA3AF),
        indicatorColor: const Color(0xFFD9FF2E),
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.only(top: 8),
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0),
        tabs: const [
          Tab(text: 'ANALYTICS'),
          Tab(text: 'INVENTORY'),
          Tab(text: 'USERS'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(ProductProvider provider, List<dynamic> products) {
    final totalInventoryValue = products.fold<double>(0, (sum, p) => sum + p.price);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANALYTICS OVERVIEW',
            style: GoogleFonts.outfit(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Stats Row
          Row(
            children: [
              _buildStatCard(
                'TOTAL STOCK',
                '${products.length}',
                Icons.inventory_2_rounded,
                const Color(0xFFD9FF2E),
                'Items',
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'VALUATION',
                CurrencyFormatter.formatIDR(totalInventoryValue),
                Icons.account_balance_wallet_rounded,
                Colors.white,
                'IDR',
                isCompact: true,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Chart Section
          _buildChartSection(),

          const SizedBox(height: 32),
          
          // Category Distribution
          _buildCategoryDistribution(provider),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REVENUE GROWTH',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+24.8%',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD9FF2E),
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LAST 30 DAYS',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATEGORY SPREAD',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          ...provider.categories.where((c) => c != 'All').map((cat) {
            final count = provider.products.where((p) => p.category == cat).length;
            final percent = count / provider.products.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text('$count items', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF111827)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(BuildContext context, ProductProvider provider, List<dynamic> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildAdminProductCard(context, product, provider);
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, String unit, {bool isCompact = false}) {
    final isDark = bgColor != Colors.white;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: !isDark ? Border.all(color: const Color(0xFFE5E7EB)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.1) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF111827), size: 20),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: isCompact ? 18 : 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111827),
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827).withOpacity(0.5),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '• $unit',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProductCard(BuildContext context, dynamic product, ProductProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.category,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatIDR(product.price),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF111827), size: 22),
                onPressed: () => Navigator.pushNamed(context, '/add-edit', arguments: product),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
                onPressed: () => _showDeleteDialog(context, product, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, AuthProvider auth) {
    return FutureBuilder(
      future: auth.fetchUsers(),
      builder: (context, snapshot) {
        final users = auth.users;
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline_rounded, size: 64, color: Color(0xFFD1D5DB)),
                const SizedBox(height: 16),
                Text(
                  'NO USERS REGISTERED',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isAdmin = user['role'] == 'admin';
            final email = user['email'] as String;
            final initial = email[0].toUpperCase();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isAdmin ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                    child: Text(
                      initial,
                      style: GoogleFonts.outfit(
                        color: isAdmin ? const Color(0xFFD9FF2E) : const Color(0xFF111827),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        Text(
                          isAdmin ? 'SYSTEM ADMINISTRATOR' : 'PREMIUM MEMBER',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isAdmin) // Prevent deleting self/admins for safety in this demo
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                      onPressed: () => _showDeleteUserDialog(context, user, auth),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteUserDialog(BuildContext context, Map<String, dynamic> user, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('REVOKE ACCESS?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Text('This will permanently remove the account for ${user['email']}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.deleteUser(user['id']);
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('REVOKE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic product, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('DELETE MODEL?', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Text('This will permanently remove ${product.name} from the active inventory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteProduct(product.id!);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('DELETE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD9FF2E).withOpacity(0.2)),
                ),
                child: const Icon(Icons.lock_person_rounded, size: 60, color: Color(0xFFD9FF2E)),
              ),
              const SizedBox(height: 32),
              Text(
                'SECURITY PROTOCOL',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2.0, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'You do not have administrative clearance to access this portal.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: const Color(0xFF9CA3AF), height: 1.5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9FF2E),
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('RETURN TO STOREFRONT', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9FF2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.4, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.2);

    // Draw area gradient
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD9FF2E).withOpacity(0.3),
          const Color(0xFFD9FF2E).withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.5), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



