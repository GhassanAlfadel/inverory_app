import 'package:flutter/foundation.dart' hide Category;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'models.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize FFI for Windows/Desktop
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory_app.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'seller',
        name TEXT,
        branch TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        scientificName TEXT,
        manufacturer TEXT,
        barcode TEXT,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        stripsPerBox INTEGER DEFAULT 1,
        salePricePerStrip REAL,
        purchasePrice REAL,
        categoryId INTEGER NOT NULL,
        expiryDate TEXT,
        description TEXT,
        warnings TEXT,
        imagePath TEXT,
        processor TEXT,
        ram TEXT,
        storage TEXT,
        gpu TEXT,
        model TEXT,
        color TEXT,
        isTouchScreen INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplier_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        total_amount REAL NOT NULL,
        notes TEXT,
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        purchase_price REAL NOT NULL,
        FOREIGN KEY (purchase_id) REFERENCES purchases (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        start_balance REAL NOT NULL,
        end_balance REAL,
        status TEXT DEFAULT 'active',
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shift_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        total_amount REAL NOT NULL,
        discount REAL DEFAULT 0,
        payment_method TEXT DEFAULT 'cash',
        FOREIGN KEY (shift_id) REFERENCES shifts (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pharmacyName TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        email TEXT,
        workingHours TEXT,
        logoPath TEXT,
        currency TEXT DEFAULT 'SDG',
        lowStockLimit INTEGER DEFAULT 10,
        showPrice INTEGER DEFAULT 1,
        showImage INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isActive INTEGER DEFAULT 1
      )
    ''');

    await _seedData(db);
    await _seedVersion8Data(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN scientificName TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN manufacturer TEXT');
      await db.execute(
        'ALTER TABLE products ADD COLUMN stripsPerBox INTEGER DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE products ADD COLUMN salePricePerStrip REAL',
      );
      await db.execute('ALTER TABLE products ADD COLUMN purchasePrice REAL');
      await db.execute('ALTER TABLE products ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN indications TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN warnings TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN imagePath TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE categories ADD COLUMN description TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS suppliers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          email TEXT,
          address TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS purchases (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          supplier_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          total_amount REAL NOT NULL,
          notes TEXT,
          FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS purchase_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          purchase_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          purchase_price REAL NOT NULL,
          FOREIGN KEY (purchase_id) REFERENCES purchases (id),
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT,
          start_balance REAL NOT NULL,
          end_balance REAL,
          status TEXT DEFAULT 'active',
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          shift_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          total_amount REAL NOT NULL,
          discount REAL DEFAULT 0,
          payment_method TEXT DEFAULT 'cash',
          FOREIGN KEY (shift_id) REFERENCES shifts (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sale_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL,
          subtotal REAL NOT NULL,
          FOREIGN KEY (sale_id) REFERENCES sales (id),
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');
    }
    if (oldVersion < 7) {
      // Check if columns exist before adding them to avoid errors if they were partially added
      var tableInfo = await db.rawQuery('PRAGMA table_info(users)');
      var columns = tableInfo.map((e) => e['name']).toList();
      if (!columns.contains('name')) {
        await db.execute('ALTER TABLE users ADD COLUMN name TEXT');
      }
      if (!columns.contains('branch')) {
        await db.execute('ALTER TABLE users ADD COLUMN branch TEXT');
      }
      if (!columns.contains('isActive')) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN isActive INTEGER DEFAULT 1',
        );
      }
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          category TEXT,
          description TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pharmacyName TEXT NOT NULL,
          phone TEXT,
          address TEXT,
          email TEXT,
          workingHours TEXT,
          logoPath TEXT,
          currency TEXT DEFAULT 'SDG',
          lowStockLimit INTEGER DEFAULT 10,
          showPrice INTEGER DEFAULT 1,
          showImage INTEGER DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS payment_methods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          isActive INTEGER DEFAULT 1
        )
      ''');

      // Seed default settings and payment methods if upgrading
      await _seedVersion8Data(db);
    }
    if (oldVersion < 9) {
      await db.execute('ALTER TABLE products ADD COLUMN processor TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN ram TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN storage TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN gpu TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN model TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN color TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN isTouchScreen INTEGER');
    }
  }

  Future<void> _seedVersion8Data(DatabaseExecutor db) async {
    final settingsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM settings'),
    );
    if (settingsCount == 0) {
      await db.insert('settings', {
        'pharmacyName': 'صيدلية الشفاء',
        'phone': '0123456789',
        'address': 'الخرطوم، شارع المشتل',
        'email': 'contact@pharmacy.com',
        'workingHours': 'من 7 صباحًا إلى 11 مساءً يوميًا',
        'currency': 'SDG',
        'lowStockLimit': 10,
        'showPrice': 1,
        'showImage': 1,
      });
      debugPrint('Seeded settings');
    }

    final pmCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM payment_methods'),
    );
    if (pmCount == 0) {
      final methods = ['نقداً', 'بنكك - MBOK', 'فوري', 'تطبيق أوكاش'];
      for (var name in methods) {
        await db.insert('payment_methods', {'name': name, 'isActive': 1});
      }
      debugPrint('Seeded payment methods');
    }
  }

  Future<void> _seedData(DatabaseExecutor db) async {
    // Seed Users
    final admin = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['superadmin'],
    );
    if (admin.isEmpty) {
      await db.insert('users', {
        'username': 'superadmin',
        'password': 'admin123',
        'role': 'admin',
      });
      debugPrint('Seeded superadmin user');
    }

    // Seed Categories
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if (count == 0) {
      final categories = ['هواتف', 'لاب توب', 'ملحقات', 'عام'];
      for (var name in categories) {
        await db.insert('categories', {'name': name});
      }
      debugPrint('Seeded categories');
    }

    // Seed Suppliers
    final supplierCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM suppliers'),
    );
    if (supplierCount == 0) {
      await db.insert('suppliers', {
        'name': 'شركة الأمل للأدوية',
        'phone': '0123456789',
        'address': 'الخرطوم، السودان',
      });
      await db.insert('suppliers', {
        'name': 'المستشار الطبي',
        'phone': '0987654321',
        'address': 'أمدرمان',
      });
      debugPrint('Seeded suppliers');
    }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('sale_items');
      await txn.delete('sales');
      await txn.delete('purchase_items');
      await txn.delete('purchases');
      await txn.delete('shifts');
      await txn.delete('expenses');
      await txn.delete('products');
      await txn.delete('categories');
      await txn.delete('suppliers');
      await txn.delete('payment_methods');
      await txn.delete('settings');

      // Re-seed essential data
      await _seedData(txn);
      await _seedVersion8Data(txn);
    });
  }

  // Auth Methods
  Future<User?> login(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ? AND isActive = 1',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // User Management
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<int> addUser(User user) async {
    final db = await database;
    final map = user.toMap();
    map.remove('id');
    return await db.insert('users', map);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Product Methods
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<void> addProduct(Product product) async {
    final db = await database;
    // Remove id from map to let DB auto-increment
    final map = product.toMap();
    map.remove('id');
    await db.insert('products', map);
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
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

  // Categories
  Future<int> addCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Expense Methods
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<void> addExpense(Expense expense) async {
    final db = await database;
    final map = expense.toMap();
    map.remove('id');
    await db.insert('expenses', map);
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Supplier Methods
  Future<List<Supplier>> getSuppliers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('suppliers');
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }

  Future<int> addSupplier(Supplier supplier) async {
    final db = await database;
    final map = supplier.toMap();
    map.remove('id');
    return await db.insert('suppliers', map);
  }

  Future<int> updateSupplier(Supplier supplier) async {
    final db = await database;
    return await db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  // Purchase Methods
  Future<int> addPurchase(Purchase purchase, List<PurchaseItem> items) async {
    final db = await database;
    return await db.transaction((txn) async {
      final purchaseMap = purchase.toMap();
      purchaseMap.remove('id');
      final purchaseId = await txn.insert('purchases', purchaseMap);

      for (var item in items) {
        final itemMap = {
          'purchase_id': purchaseId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'purchase_price': item.purchasePrice,
        };
        await txn.insert('purchase_items', itemMap);

        // Update product stock
        await txn.rawUpdate(
          'UPDATE products SET stock = stock + ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
      return purchaseId;
    });
  }

  Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, s.name as supplier_name 
      FROM purchases p 
      JOIN suppliers s ON p.supplier_id = s.id 
      ORDER BY p.date DESC
    ''');
  }

  Future<Map<String, dynamic>?> getPurchaseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT p.*, s.name as supplier_name, s.phone as supplier_phone, 
             s.email as supplier_email, s.address as supplier_address
      FROM purchases p 
      JOIN suppliers s ON p.supplier_id = s.id 
      WHERE p.id = ?
    ''',
      [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPurchaseItems(int purchaseId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT pi.*, p.name as product_name, p.scientificName as product_scientific_name
      FROM purchase_items pi
      JOIN products p ON pi.product_id = p.id
      WHERE pi.purchase_id = ?
    ''',
      [purchaseId],
    );
  }

  // Report Methods
  Future<Map<String, double>> getTotalsForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    // Sales Total
    final salesRes = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM sales WHERE date BETWEEN ? AND ?',
      [startStr, endStr],
    );
    final salesTotal = _toDouble(salesRes.first['total']) ?? 0.0;

    // Purchases Total
    final purchasesRes = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM purchases WHERE date BETWEEN ? AND ?',
      [startStr, endStr],
    );
    final purchasesTotal = _toDouble(purchasesRes.first['total']) ?? 0.0;

    // Expenses Total
    final expensesRes = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?',
      [startStr, endStr],
    );
    final expensesTotal = _toDouble(expensesRes.first['total']) ?? 0.0;

    return {
      'sales': salesTotal,
      'purchases': purchasesTotal,
      'expenses': expensesTotal,
      'net': salesTotal - purchasesTotal - expensesTotal,
    };
  }

  Future<List<Map<String, dynamic>>> getSalesByProduct(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT p.name, SUM(si.quantity) as total_quantity, SUM(si.subtotal) as total_amount
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      JOIN sales s ON si.sale_id = s.id
      WHERE s.date BETWEEN ? AND ?
      GROUP BY p.id
      ORDER BY total_amount DESC
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
  }

  // Settings Methods
  Future<AppSettings> getSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AppSettings.fromMap(maps.first);
    }
    // Return default if not found
    return AppSettings(pharmacyName: 'صيدلية الشفاء');
  }

  Future<void> updateSettings(AppSettings settings) async {
    final db = await database;
    final maps = await db.query('settings', limit: 1);
    if (maps.isNotEmpty) {
      await db.update(
        'settings',
        settings.toMap(),
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    } else {
      final map = settings.toMap();
      map.remove('id');
      await db.insert('settings', map);
    }
  }

  // Payment Methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('payment_methods');
    return List.generate(maps.length, (i) => PaymentMethod.fromMap(maps[i]));
  }

  Future<int> addPaymentMethod(PaymentMethod method) async {
    final db = await database;
    final map = method.toMap();
    map.remove('id');
    return await db.insert('payment_methods', map);
  }

  Future<int> updatePaymentMethod(PaymentMethod method) async {
    final db = await database;
    return await db.update(
      'payment_methods',
      method.toMap(),
      where: 'id = ?',
      whereArgs: [method.id],
    );
  }

  Future<int> deletePaymentMethod(int id) async {
    final db = await database;
    return await db.delete('payment_methods', where: 'id = ?', whereArgs: [id]);
  }

  // Shift Methods
  Future<int> startShift(Shift shift) async {
    final db = await database;
    final map = shift.toMap();
    map.remove('id');
    return await db.insert('shifts', map);
  }

  Future<void> endShift(int shiftId, double endBalance) async {
    final db = await database;
    await db.update(
      'shifts',
      {
        'end_time': DateTime.now().toIso8601String(),
        'end_balance': endBalance,
        'status': 'closed',
      },
      where: 'id = ?',
      whereArgs: [shiftId],
    );
  }

  Future<Shift?> getActiveShift(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shifts',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'active'],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Shift.fromMap(maps.first);
    }
    return null;
  }

  // Sale Methods
  Future<int> createSale(Sale sale, List<SaleItem> items) async {
    final db = await database;
    return await db.transaction((txn) async {
      final saleMap = sale.toMap();
      saleMap.remove('id');
      final saleId = await txn.insert('sales', saleMap);

      for (var item in items) {
        final itemMap = {
          'sale_id': saleId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'subtotal': item.subtotal,
        };
        await txn.insert('sale_items', itemMap);

        // Update product stock
        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
      return saleId;
    });
  }

  Future<List<Map<String, dynamic>>> getSalesHistory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT s.*, u.username as seller_name 
      FROM sales s 
      JOIN shifts sh ON s.shift_id = sh.id 
      JOIN users u ON sh.user_id = u.id 
      ORDER BY s.date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT si.*, p.name as product_name, p.model as product_model
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      WHERE si.sale_id = ?
    ''',
      [saleId],
    );
  }

  Future<void> returnSaleItem(int saleItemId, int returnQuantity) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Get sale item details
      final List<Map<String, dynamic>> items = await txn.query(
        'sale_items',
        where: 'id = ?',
        whereArgs: [saleItemId],
      );
      if (items.isEmpty) throw Exception('Item not found');
      final item = items.first;
      final saleId = item['sale_id'];
      final productId = item['product_id'];
      final currentQuantity = item['quantity'];
      final price = item['price'];

      if (returnQuantity > currentQuantity) {
        throw Exception('Return quantity exceeds current quantity');
      }

      // 2. Update product stock
      await txn.rawUpdate(
        'UPDATE products SET stock = stock + ? WHERE id = ?',
        [returnQuantity, productId],
      );

      // 3. Update or delete sale item
      if (returnQuantity == currentQuantity) {
        await txn.delete(
          'sale_items',
          where: 'id = ?',
          whereArgs: [saleItemId],
        );
      } else {
        final newQuantity = currentQuantity - returnQuantity;
        final newSubtotal = price * newQuantity;
        await txn.update(
          'sale_items',
          {'quantity': newQuantity, 'subtotal': newSubtotal},
          where: 'id = ?',
          whereArgs: [saleItemId],
        );
      }

      // 4. Update sale total
      final returnAmount = price * returnQuantity;
      await txn.rawUpdate(
        'UPDATE sales SET total_amount = total_amount - ? WHERE id = ?',
        [returnAmount, saleId],
      );
    });
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }
}
