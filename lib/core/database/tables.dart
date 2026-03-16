// import 'package:flutter/material.dart';

// class Users extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get username => text().unique()();
//   TextColumn get password => text()(); // In a real app, hash this!
//   TextColumn get role =>
//       text().withDefault(const Constant('seller'))(); // 'admin', 'seller'
// }

// class Categories extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get name => text()();
// }

// class Products extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get name => text()();
//   TextColumn get barcode => text().nullable()();
//   RealColumn get price => real()();
//   IntColumn get stock => integer()();
//   IntColumn get categoryId => integer().references(Categories, #id)();
//   DateTimeColumn get expiryDate => dateTime().nullable()();
// }
