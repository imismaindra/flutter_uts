import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedPayment = 'Credit Card';

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
          onPressed: _previousStep,
        ),
        title: Text(
          'SECURE CHECKOUT',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildShippingStep(),
                _buildPaymentStep(),
                _buildSuccessStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _currentStep < 2 ? _buildBottomAction() : null,
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          _stepNode(0, 'Shipping'),
          _stepLine(0),
          _stepNode(1, 'Payment'),
          _stepLine(1),
          _stepNode(2, 'Success'),
        ],
      ),
    );
  }

  Widget _stepNode(int index, String label) {
    bool isActive = _currentStep >= index;
    bool isCurrent = _currentStep == index;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: const Color(0xFFD9FF2E), width: 2) : null,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check_rounded, color: Color(0xFFD9FF2E), size: 16)
                : Text('${index + 1}',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    )),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: isActive ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _stepLine(int index) {
    bool isActive = _currentStep > index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Container(
          height: 2,
          color: isActive ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
        ),
      ),
    );
  }

  Widget _buildShippingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SHIPPING DETAILS',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Where should we deliver your premium ride?',
              style: GoogleFonts.outfit(color: const Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 32),
          _inputField('FULL NAME', _nameController, Icons.person_outline_rounded),
          const SizedBox(height: 20),
          _inputField('DELIVERY ADDRESS', _addressController, Icons.location_on_outlined, maxLines: 3),
          const SizedBox(height: 20),
          _inputField('PHONE NUMBER', _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    final cart = context.read<CartProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PAYMENT METHOD',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
          const SizedBox(height: 32),
          _paymentOption('Credit Card', Icons.credit_card_rounded),
          const SizedBox(height: 12),
          _paymentOption('Bank Transfer', Icons.account_balance_rounded),
          const SizedBox(height: 12),
          _paymentOption('Crypto / Bitcoin', Icons.currency_bitcoin_rounded),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _summaryRow('Order Value', '\$${cart.totalPrice.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                _summaryRow('Shipping', 'FREE', color: const Color(0xFFD9FF2E)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.white10),
                ),
                _summaryRow('TOTAL', '\$${cart.totalPrice.toStringAsFixed(2)}', isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFD9FF2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF111827), size: 64),
            ),
            const SizedBox(height: 40),
            Text(
              'RIDE READY!',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your order has been secured. Our fulfillment team is preparing your premium bicycle for the ultimate experience.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFF6B7280),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().clearCart();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'RETURN TO SHOWROOM',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF111827)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
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

  Widget _paymentOption(String title, IconData icon) {
    bool isSelected = _selectedPayment == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: const Color(0xFFD9FF2E), width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFD9FF2E) : const Color(0xFF9CA3AF)),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : const Color(0xFF111827),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.radio_button_checked_rounded, color: Color(0xFFD9FF2E))
            else
              const Icon(Icons.radio_button_off_rounded, color: Color(0xFFD9FF2E)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w700,
            fontSize: isTotal ? 14 : 12,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color ?? (isTotal ? const Color(0xFFD9FF2E) : Colors.white),
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 24 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF111827),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            _currentStep == 1 ? 'FINALIZE ORDER' : 'CONTINUE',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}
