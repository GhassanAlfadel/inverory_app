class User {
  final int? id;
  final String username;
  final String password;
  final String role;
  final String? name;
  final String? branch;
  final bool isActive;

  User({
    this.id,
    required this.username,
    required this.password,
    this.role = 'seller',
    this.name,
    this.branch,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'name': name,
      'branch': branch,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'] ?? 'seller',
      name: map['name'],
      branch: map['branch'],
      isActive: (map['isActive'] ?? 1) == 1,
    );
  }
}

class Category {
  final int? id;
  final String name;
  final String? description;

  Category({this.id, required this.name, this.description});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}

class Product {
  final int? id;
  final String name;
  final String? scientificName;
  final String? manufacturer;
  final String? barcode;
  final double price; // Sale price per box
  final int stock; // Total boxes
  final int stripsPerBox;
  final double? salePricePerStrip;
  final double? purchasePrice;
  final int categoryId;
  final DateTime? expiryDate;
  final String? description;
  final String? indications;
  final String? warnings;
  final String? imagePath;

  // Electronics specific fields
  final String? processor;
  final String? ram;
  final String? storage;
  final String? gpu;
  final String? model;
  final String? color;
  final bool? isTouchScreen;

  Product({
    this.id,
    required this.name,
    this.scientificName,
    this.manufacturer,
    this.barcode,
    required this.price,
    required this.stock,
    this.stripsPerBox = 1,
    this.salePricePerStrip,
    this.purchasePrice,
    required this.categoryId,
    this.expiryDate,
    this.description,
    this.indications,
    this.warnings,
    this.imagePath,
    this.processor,
    this.ram,
    this.storage,
    this.gpu,
    this.model,
    this.color,
    this.isTouchScreen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'manufacturer': manufacturer,
      'barcode': barcode,
      'price': price,
      'stock': stock,
      'stripsPerBox': stripsPerBox,
      'salePricePerStrip': salePricePerStrip,
      'purchasePrice': purchasePrice,
      'categoryId': categoryId,
      'expiryDate': expiryDate?.toIso8601String(),
      'description': description,
      'indications': indications,
      'warnings': warnings,
      'imagePath': imagePath,
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'gpu': gpu,
      'model': model,
      'color': color,
      'isTouchScreen': isTouchScreen == null ? null : (isTouchScreen! ? 1 : 0),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      scientificName: map['scientificName'],
      manufacturer: map['manufacturer'],
      barcode: map['barcode'],
      price: _toDouble(map['price']) ?? 0.0,
      stock: map['stock'] ?? 0,
      stripsPerBox: map['stripsPerBox'] ?? 1,
      salePricePerStrip: _toDouble(map['salePricePerStrip']),
      purchasePrice: _toDouble(map['purchasePrice']),
      categoryId: map['categoryId'],
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      description: map['description'],
      indications: map['indications'],
      warnings: map['warnings'],
      imagePath: map['imagePath'],
      processor: map['processor'],
      ram: map['ram'],
      storage: map['storage'],
      gpu: map['gpu'],
      model: map['model'],
      color: map['color'],
      isTouchScreen: map['isTouchScreen'] == null
          ? null
          : (map['isTouchScreen'] == 1),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return null;
  }
}

class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String? category;
  final String? description;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: _toDouble(map['amount']) ?? 0.0,
      date: DateTime.parse(map['date']),
      category: map['category'],
      description: map['description'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return null;
  }
}

class Supplier {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;

  Supplier({this.id, required this.name, this.phone, this.email, this.address});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
    );
  }
}

class Purchase {
  final int? id;
  final int supplierId;
  final DateTime date;
  final double totalAmount;
  final String? notes;

  Purchase({
    this.id,
    required this.supplierId,
    required this.date,
    required this.totalAmount,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'date': date.toIso8601String(),
      'total_amount': totalAmount,
      'notes': notes,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      supplierId: map['supplier_id'],
      date: DateTime.parse(map['date']),
      totalAmount: _toDouble(map['total_amount']) ?? 0.0,
      notes: map['notes'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return null;
  }
}

class PurchaseItem {
  final int? id;
  final int purchaseId;
  final int productId;
  final int quantity;
  final double purchasePrice;

  PurchaseItem({
    this.id,
    required this.purchaseId,
    required this.productId,
    required this.quantity,
    required this.purchasePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
    };
  }

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      id: map['id'],
      purchaseId: map['purchase_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      purchasePrice: _toDouble(map['purchase_price']) ?? 0.0,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return null;
  }
}

class AppSettings {
  final int? id;
  final String pharmacyName;
  final String? phone;
  final String? address;
  final String? email;
  final String? workingHours;
  final String? logoPath;
  final String currency;
  final int lowStockLimit;
  final bool showPrice;
  final bool showImage;

  AppSettings({
    this.id,
    required this.pharmacyName,
    this.phone,
    this.address,
    this.email,
    this.workingHours,
    this.logoPath,
    this.currency = 'SDG',
    this.lowStockLimit = 10,
    this.showPrice = true,
    this.showImage = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pharmacyName': pharmacyName,
      'phone': phone,
      'address': address,
      'email': email,
      'workingHours': workingHours,
      'logoPath': logoPath,
      'currency': currency,
      'lowStockLimit': lowStockLimit,
      'showPrice': showPrice ? 1 : 0,
      'showImage': showImage ? 1 : 0,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'],
      pharmacyName: map['pharmacyName'] ?? 'Pharmacy App',
      phone: map['phone'],
      address: map['address'],
      email: map['email'],
      workingHours: map['workingHours'],
      logoPath: map['logoPath'],
      currency: map['currency'] ?? 'SDG',
      lowStockLimit: map['lowStockLimit'] ?? 10,
      showPrice: (map['showPrice'] ?? 1) == 1,
      showImage: (map['showImage'] ?? 1) == 1,
    );
  }
}

class PaymentMethod {
  final int? id;
  final String name;
  final bool isActive;

  PaymentMethod({this.id, required this.name, this.isActive = true});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'isActive': isActive ? 1 : 0};
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      isActive: (map['isActive'] ?? 1) == 1,
    );
  }
}

class Shift {
  final int? id;
  final int userId;
  final DateTime startTime;
  final DateTime? endTime;
  final double startBalance;
  final double? endBalance;
  final String status;

  Shift({
    this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.startBalance,
    this.endBalance,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'start_balance': startBalance,
      'end_balance': endBalance,
      'status': status,
    };
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'],
      userId: map['user_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      startBalance: (map['start_balance'] as num).toDouble(),
      endBalance: map['end_balance'] != null
          ? (map['end_balance'] as num).toDouble()
          : null,
      status: map['status'] ?? 'active',
    );
  }
}

class Sale {
  final int? id;
  final int shiftId;
  final DateTime date;
  final double totalAmount;
  final double discount;
  final String paymentMethod;

  Sale({
    this.id,
    required this.shiftId,
    required this.date,
    required this.totalAmount,
    this.discount = 0.0,
    this.paymentMethod = 'cash',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shift_id': shiftId,
      'date': date.toIso8601String(),
      'total_amount': totalAmount,
      'discount': discount,
      'payment_method': paymentMethod,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      shiftId: map['shift_id'],
      date: DateTime.parse(map['date']),
      totalAmount: (map['total_amount'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      paymentMethod: map['payment_method'] ?? 'cash',
    );
  }
}

class SaleItem {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }
}
