import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'id DESC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
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
      'isNew': 0,
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
}
