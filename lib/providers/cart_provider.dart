import 'package:flutter/material.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  int? _userId;

  void setUserId(int? id) {
    _userId = id;
    if (id == null) {
      _items.clear();
      notifyListeners();
    }
  }

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, i) => sum + i.product.price * i.quantity);

  bool contains(int? productId) =>
      _items.any((i) => i.product.id == productId);

  Future<void> loadCartFromDb(List<Product> allProducts) async {
    if (_userId == null) return;
    final cartData = await DatabaseHelper.instance.getCartItems(_userId!);
    _items.clear();
    for (var data in cartData) {
      final productId = data['productId'];
      final quantity = data['quantity'];
      final product = allProducts.firstWhere((p) => p.id == productId, orElse: () => Product(id: -1, name: '', category: '', price: 0, image: '', description: ''));
      if (product.id != -1) {
        _items.add(CartItem(product: product, quantity: quantity));
      }
    }
    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    if (_userId == null) return;
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
      await DatabaseHelper.instance.updateCartQuantity(product.id!, _items[index].quantity, _userId!);
    } else {
      _items.add(CartItem(product: product));
      await DatabaseHelper.instance.addToCart(product.id!, 1, _userId!);
    }
    notifyListeners();
  }

  Future<void> increment(int productId) async {
    if (_userId == null) return;
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index != -1) {
      _items[index].quantity++;
      await DatabaseHelper.instance.updateCartQuantity(productId, _items[index].quantity, _userId!);
      notifyListeners();
    }
  }

  Future<void> decrement(int productId) async {
    if (_userId == null) return;
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index != -1) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
        await DatabaseHelper.instance.removeFromCart(productId, _userId!);
      } else {
        _items[index].quantity--;
        await DatabaseHelper.instance.updateCartQuantity(productId, _items[index].quantity, _userId!);
      }
      notifyListeners();
    }
  }

  Future<void> removeItem(int productId) async {
    if (_userId == null) return;
    _items.removeWhere((i) => i.product.id == productId);
    await DatabaseHelper.instance.removeFromCart(productId, _userId!);
    notifyListeners();
  }

  Future<void> clearCart() async {
    if (_userId == null) return;
    _items.clear();
    await DatabaseHelper.instance.clearCart(_userId!);
    notifyListeners();
  }
}
