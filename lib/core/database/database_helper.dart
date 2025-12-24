import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('carts_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        uid $textType,
        email $textType,
        name $textType,
        phone $textTypeNullable,
        location $textTypeNullable,
        latitude $realType DEFAULT 0.0,
        longitude $realType DEFAULT 0.0,
        createdAt $textType,
        UNIQUE(uid)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id $idType,
        orderId $textType,
        userId $textType,
        totalAmount $realType,
        status $textType,
        paymentMethod $textType,
        deliveryAddress $textType,
        phoneNumber $textType,
        latitude $realType DEFAULT 0.0,
        longitude $realType DEFAULT 0.0,
        createdAt $textType,
        UNIQUE(orderId)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id $idType,
        orderId $textType,
        productId $textType,
        productName $textType,
        productImage $textTypeNullable,
        price $realType,
        quantity $intType,
        FOREIGN KEY (orderId) REFERENCES orders (orderId) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_users_uid ON users(uid)');
    await db.execute('CREATE INDEX idx_orders_userId ON orders(userId)');
    await db.execute(
      'CREATE INDEX idx_order_items_orderId ON order_items(orderId)',
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Clear all tables
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('order_items');
    await db.delete('orders');
    await db.delete('users');
  }
}
