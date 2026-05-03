import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Newest'; // Newest, Price: Low to High, Price: High to Low
  bool _isLoading = false;
  String? _error;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ─── Getters ────────────────────────────────────────────────────────────────
  List<Product> get products => _products;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<Product> get filteredProducts {
    final filtered = _products.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Apply Sorting
    switch (_sortBy) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Newest':
      default:
        // Newest based on ID if timestamp not available
        filtered.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
        break;
    }

    return filtered;
  }

  // ─── Initialization ─────────────────────────────────────────────────────────
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    // Jangan panggil notifyListeners() di sini — init() bisa dipanggil
    // synchronous saat create(), widget tree belum siap menerima rebuild.
    try {
      if (kIsWeb) {
        // sqflite tidak support web — gunakan data in-memory
        // Bungkus dalam Future agar berjalan async (tidak sync saat create)
        await Future.microtask(
            () => _products = DatabaseHelper.defaultProducts());
      } else {
        _products = await _dbHelper.getAllProducts();
      }
    } catch (e) {
      _error = 'Gagal memuat data: $e';
      _products = DatabaseHelper.defaultProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Filter & Search ────────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  // ─── CRUD ───────────────────────────────────────────────────────────────────
  Future<void> addProduct(Product product) async {
    try {
      if (kIsWeb) {
        final newId = _products.isEmpty
            ? 1
            : (_products.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
        final newProduct = product.copyWith(id: newId);
        _products.insert(0, newProduct);
      } else {
        final id = await _dbHelper.insertProduct(product);
        _products.insert(0, product.copyWith(id: id));
      }
      notifyListeners();
    } catch (e) {
      _error = 'Gagal menambah produk: $e';
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      if (!kIsWeb) {
        await _dbHelper.updateProduct(product);
      }
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal memperbarui produk: $e';
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      if (!kIsWeb) {
        await _dbHelper.deleteProduct(id);
      }
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Gagal menghapus produk: $e';
      notifyListeners();
    }
  }
}