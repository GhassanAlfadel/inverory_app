import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inverory_app/main.dart';
import 'package:inverory_app/core/database/app_database.dart';
import 'package:inverory_app/core/auth/auth_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for running sqflite in tests if needed,
    // though ideally we should mock the database.
    // For this smoke test, we'll try to let it run or rely on the fact
    // that on mobile it uses platform channels.
    // For unit tests on desktop, we need sqflite_common_ffi.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Login screen demonstrates title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      InventoryApp(database: AppDatabase(), authRepository: AuthRepository()),
    );

    // Verify that the login screen title is present.
    expect(find.text('صيدلية الشفاء'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsNWidgets(2));
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}
