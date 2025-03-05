import 'package:jahit_baju/data/model/product.dart';
import 'package:logger/web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  Logger logger = Logger();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  _initDB() async {
    logger.d("Database initialized");
    String path = await getDatabasesPath();
    return await openDatabase(join(path, 'jahitbaju.db'), version: 1,
        onCreate: (db, version) async {
      await db.execute('''CREATE TABLE product_cache(
        id INTEGER PRIMARY KEY,
        data TEXT
      )''');
    });
  }

  Future<bool> insertProductCache(String data) async {
    final db = await database;
    await db.insert('product_cache', {'id' : 1, 'data': data},
        conflictAlgorithm: ConflictAlgorithm.replace);
    logger.d("Insert cache successful ${data}");
    return true;
  }

  Future<List<Product>?> getProductCache() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('product_cache');
    logger.d("read cache successful ${maps}");
    if (maps.isNotEmpty) {
      final List<Product> allProducts = maps
        .map((map) => Product.fromJsonList(map['data'])) // Convert JSON string ke List<Product>
        .expand((productList) => productList) // Flatten nested lists
        .toList();
    
    return allProducts;
    }
    return null;
  }

  Future<void> clearCache() async {
    logger.d("clear cache successful");
    final db = await database;
    await db.delete('product_cache');
  }

  void deleteDatabaseManually() async {
    logger.d("delete cache successful");
    String path = join(await getDatabasesPath(), 'jahitbaju.db');
    await deleteDatabase(path);
  }
}
