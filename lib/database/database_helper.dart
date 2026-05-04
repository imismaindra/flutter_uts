import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');
    return await openDatabase(
      path, 
      version: 3, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE cart (
          productId INTEGER PRIMARY KEY,
          quantity INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'user'
        )
      ''');
      // Create a default admin
      await db.insert('users', {
        'email': 'admin@element.com',
        'password': 'password123',
        'role': 'admin'
      });
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL,
        description TEXT NOT NULL,
        rating REAL NOT NULL DEFAULT 4.5,
        isNew INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE cart (
        productId INTEGER PRIMARY KEY,
        quantity INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user'
      )
    ''');
    // Create a default admin
    await db.insert('users', {
      'email': 'admin@element.com',
      'password': 'password123',
      'role': 'admin'
    });
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    final initialProducts = _defaultProductMaps();
    for (final product in initialProducts) {
      await db.insert('products', product);
    }
  }

  // CRUD Operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    if (db == null) return 0;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query('products', orderBy: 'id DESC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    if (db == null) return 0;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    if (db == null) return 0;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Cart Operations
  Future<void> addToCart(int productId, int quantity) async {
    final db = await database;
    if (db == null) return;
    await db.insert(
      'cart',
      {'productId': productId, 'quantity': quantity},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromCart(int productId) async {
    final db = await database;
    if (db == null) return;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  Future<void> updateCartQuantity(int productId, int quantity) async {
    final db = await database;
    if (db == null) return;
    await db.update(
      'cart',
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    if (db == null) return [];
    return await db.query('cart');
  }

  Future<void> clearCart() async {
    final db = await database;
    if (db == null) return;
    await db.delete('cart');
  }

  static List<Map<String, dynamic>> _defaultProductMaps() => [
    {
      'name': 'Element AeroMax CF Pro',
      'category': 'Road Bike',
      'price': 1250.0,
      'image': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=800&q=80',
      'description': 'Sepeda road bike karbon performa tinggi yang dirancang untuk kecepatan dan kenyamanan jarak jauh. Dilengkapi dengan grupset Shimano Ultegra dan roda aero karbon.',
      'rating': 4.9,
      'isNew': 1,
    },
    {
      'name': 'Element Mountain 2.0',
      'category': 'MTB',
      'price': 850.0,
      'image': 'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?auto=format&fit=crop&w=800&q=80',
      'description': 'Sepeda gunung hardtail dengan suspensi udara 120mm, drivetrain 1x12 speed, dan ban tubeless-ready untuk menaklukkan medan off-road yang menantang.',
      'rating': 4.7,
      'isNew': 0,
    },
    {
      'name': 'Element Pikes Gen 2',
      'category': 'Folding',
      'price': 450.0,
      'image': 'https://images.unsplash.com/photo-1559348349-86f1f65817fe?auto=format&fit=crop&w=800&q=80',
      'description': 'Sepeda lipat ringkas yang sempurna untuk komuting perkotaan. Mudah dilipat dan dibawa ke transportasi umum atau disimpan di bawah meja kantor.',
      'rating': 4.8,
      'isNew': 1,
    },
    {
      'name': 'Element Gravel X',
      'category': 'Gravel',
      'price': 950.0,
      'image': 'https://images.unsplash.com/photo-1541625602330-2277a1cd1f88?auto=format&fit=crop&w=800&q=80',
      'description': 'Kombinasi antara road bike dan MTB, Gravel X siap menemani petualangan Anda di segala medan, mulai dari aspal mulus hingga jalan berkerikil.',
      'rating': 4.6,
      'isNew': 0,
    },
    {
      'name': 'Element Road Racer',
      'category': 'Road Bike',
      'price': 750.0,
      'image': 'https://images.unsplash.com/photo-1532298229144-0ee0511810dd?auto=format&fit=crop&w=800&q=80',
      'description': 'Road bike entry-level yang gesit dan responsif. Cocok untuk pemula yang ingin memulai hobi bersepeda balap.',
      'rating': 4.5,
      'isNew': 0,
    },
    {
      'name': 'Element Folding Max',
      'category': 'Folding',
      'price': 550.0,
      'image': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      'description': 'Sepeda lipat dengan roda 20 inci untuk stabilitas lebih baik namun tetap mudah disimpan.',
      'rating': 4.7,
      'isNew': 1,
    },
  ];

  /// Kembalikan default products sebagai objek Product (untuk web fallback)
  static List<Product> defaultProducts() {
    return _defaultProductMaps()
        .asMap()
        .entries
        .map((e) => Product.fromMap({...e.value, 'id': e.key + 1}))
        .toList()
        .reversed
        .toList();
  }
  // ─── AUTH OPERATIONS ────────────────────────────────────────────────────────
  Future<int> registerUser(String email, String password, {String role = 'user'}) async {
    final db = await database;
    if (db == null) return -1;
    try {
      return await db.insert('users', {
        'email': email,
        'password': password,
        'role': role,
      });
    } catch (e) {
      return -1; // Email already exists or other error
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    if (db == null) return null;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
