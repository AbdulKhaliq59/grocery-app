import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:grocery_app/utils/constants.dart';
import 'package:grocery_app/models/user_model.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/models/cart_item_model.dart';
import 'package:grocery_app/models/shopping_list_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE ${AppConstants.userTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        profile_image TEXT
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE ${AppConstants.productTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        image_path TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        rating REAL DEFAULT 0.0,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Create cart items table
    await db.execute('''
      CREATE TABLE ${AppConstants.cartTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.userTable} (id),
        FOREIGN KEY (product_id) REFERENCES ${AppConstants.productTable} (id)
      )
    ''');

    // Create shopping list table
    await db.execute('''
      CREATE TABLE ${AppConstants.shoppingListTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        is_purchased INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.userTable} (id),
        FOREIGN KEY (product_id) REFERENCES ${AppConstants.productTable} (id)
      )
    ''');

    // Insert sample products
    await _insertSampleProducts(db);
  }

  Future<void> _insertSampleProducts(Database db) async {
    List<Map<String, dynamic>> products = [
      {
        'name': 'Fresh Apples',
        'price': 2.99,
        'image_path': 'assets/images/apple.png',
        'category': 'Fruits',
        'description': 'Fresh and juicy apples from local farms. Rich in vitamins and fiber.',
        'rating': 4.5,
      },
      {
        'name': 'Organic Bananas',
        'price': 1.99,
        'image_path': 'assets/images/banana.png',
        'category': 'Fruits',
        'description': 'Organic bananas grown without pesticides. Perfect for smoothies and snacks.',
        'rating': 4.3,
      },
      {
        'name': 'Fresh Broccoli',
        'price': 3.49,
        'image_path': 'assets/images/broccoli.png',
        'category': 'Vegetables',
        'description': 'Fresh broccoli florets. High in nutrients and antioxidants.',
        'rating': 4.1,
      },
      {
        'name': 'Organic Carrots',
        'price': 2.49,
        'image_path': 'assets/images/carrot.png',
        'category': 'Vegetables',
        'description': 'Organic carrots, perfect for salads, cooking, or juicing.',
        'rating': 4.4,
      },
      {
        'name': 'Whole Milk',
        'price': 3.99,
        'image_path': 'assets/images/milk.png',
        'category': 'Dairy',
        'description': 'Fresh whole milk from grass-fed cows. Rich and creamy.',
        'rating': 4.7,
      },
      {
        'name': 'Cheddar Cheese',
        'price': 5.99,
        'image_path': 'assets/images/cheese.png',
        'category': 'Dairy',
        'description': 'Aged cheddar cheese with rich flavor. Perfect for sandwiches and cooking.',
        'rating': 4.6,
      },
      {
        'name': 'Whole Wheat Bread',
        'price': 3.29,
        'image_path': 'assets/images/bread.png',
        'category': 'Bakery',
        'description': 'Freshly baked whole wheat bread. High in fiber and nutrients.',
        'rating': 4.2,
      },
      {
        'name': 'Chicken Breast',
        'price': 7.99,
        'image_path': 'assets/images/chicken.png',
        'category': 'Meat',
        'description': 'Fresh boneless chicken breast. High in protein and low in fat.',
        'rating': 4.5,
      },
    ];

    for (var product in products) {
      await db.insert(AppConstants.productTable, product);
    }
  }

  // User methods
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    User hashedUser = User(
      email: user.email,
      password: _hashPassword(user.password),
      name: user.name,
      profileImage: user.profileImage,
    );
    return await db.insert(AppConstants.userTable, hashedUser.toMap());
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    String hashedPassword = _hashPassword(password);
    
    List<Map<String, dynamic>> maps = await db.query(
      AppConstants.userTable,
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    
    List<Map<String, dynamic>> maps = await db.query(
      AppConstants.userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Product methods
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.productTable);
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productTable,
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    
    List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM ${AppConstants.productTable}'
    );
    return List.generate(maps.length, (i) => maps[i]['category'] as String);
  }

  // Cart methods
  Future<int> addToCart(CartItem cartItem) async {
    final db = await database;
    
    // Check if the item already exists in the cart
    List<Map<String, dynamic>> existingItems = await db.query(
      AppConstants.cartTable,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [cartItem.userId, cartItem.productId],
    );
    
    if (existingItems.isNotEmpty) {
      // Update quantity if item exists
      int existingId = existingItems.first['id'];
      int existingQuantity = existingItems.first['quantity'];
      
      return await db.update(
        AppConstants.cartTable,
        {'quantity': existingQuantity + cartItem.quantity},
        where: 'id = ?',
        whereArgs: [existingId],
      );
    } else {
      // Insert new item if it doesn't exist
      return await db.insert(AppConstants.cartTable, cartItem.toMap());
    }
  }

  Future<int> updateCartItemQuantity(int id, int quantity) async {
    final db = await database;
    return await db.update(
      AppConstants.cartTable,
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeFromCart(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.cartTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearCart(int userId) async {
    final db = await database;
    return await db.delete(
      AppConstants.cartTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<CartItem>> getCartItems(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.cartTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    List<CartItem> cartItems = [];
    
    for (var map in maps) {
      int productId = map['product_id'];
      Product? product = await getProductById(productId);
      
      if (product != null) {
        cartItems.add(CartItem.fromMap(map, product: product));
      }
    }
    
    return cartItems;
  }

  // Shopping list methods
  Future<int> addToShoppingList(ShoppingListItem item) async {
    final db = await database;
    
    // Check if the item already exists in the shopping list
    List<Map<String, dynamic>> existingItems = await db.query(
      AppConstants.shoppingListTable,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [item.userId, item.productId],
    );
    
    if (existingItems.isNotEmpty) {
      // Item already exists, return its ID
      return existingItems.first['id'];
    } else {
      // Insert new item
      return await db.insert(AppConstants.shoppingListTable, item.toMap());
    }
  }

  Future<int> updateShoppingListItemStatus(int id, bool isPurchased) async {
    final db = await database;
    return await db.update(
      AppConstants.shoppingListTable,
      {'is_purchased': isPurchased ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeFromShoppingList(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.shoppingListTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ShoppingListItem>> getShoppingList(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.shoppingListTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    List<ShoppingListItem> shoppingList = [];
    
    for (var map in maps) {
      int productId = map['product_id'];
      Product? product = await getProductById(productId);
      
      if (product != null) {
        shoppingList.add(ShoppingListItem.fromMap(map, product: product));
      }
    }
    
    return shoppingList;
  }
}
