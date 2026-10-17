import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasePath = p.join(await getDatabasesPath(), 'budget_bites.db');
    _database = await openDatabase(
      databasePath,
      version: 2,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE food_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            store TEXT NOT NULL,
            category TEXT NOT NULL,
            last_price_cents INTEGER NOT NULL CHECK(last_price_cents >= 0),
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_item_id INTEGER,
            item_name TEXT NOT NULL,
            store TEXT NOT NULL,
            category TEXT NOT NULL,
            amount_cents INTEGER NOT NULL CHECK(amount_cents >= 0),
            servings INTEGER NOT NULL DEFAULT 1 CHECK(servings > 0),
            purchased_at TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            is_confirmed INTEGER NOT NULL DEFAULT 1 CHECK(is_confirmed IN (0, 1)),
            FOREIGN KEY(food_item_id) REFERENCES food_items(id) ON DELETE SET NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX purchases_date_index ON purchases(purchased_at)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE purchases ADD COLUMN servings INTEGER NOT NULL DEFAULT 1 CHECK(servings > 0)',
          );
        }
      },
    );
    return _database!;
  }

  Future<List<FoodItem>> getFoodItems() async {
    final rows = await (await database).query(
      'food_items',
      orderBy: 'name COLLATE NOCASE ASC, store COLLATE NOCASE ASC',
    );
    return rows.map(FoodItem.fromMap).toList();
  }

  Future<int> insertFoodItem(FoodItem item) async {
    final values = item.toMap()..remove('id');
    return (await database).insert('food_items', values);
  }

  Future<int> updateFoodItem(FoodItem item) async {
    if (item.id == null) throw ArgumentError('Food item id is required.');
    return (await database).update(
      'food_items',
      item.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteFoodItem(int id) async {
    return (await database).delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PurchaseEntry>> getPurchases() async {
    final rows = await (await database).query(
      'purchases',
      orderBy: 'purchased_at DESC, id DESC',
    );
    return rows.map(PurchaseEntry.fromMap).toList();
  }

  Future<int> insertPurchase(PurchaseEntry entry) async {
    final values = entry.toMap()..remove('id');
    return (await database).insert('purchases', values);
  }

  Future<int> updatePurchase(PurchaseEntry entry) async {
    if (entry.id == null) throw ArgumentError('Purchase id is required.');
    return (await database).update(
      'purchases',
      entry.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deletePurchase(int id) async {
    return (await database).delete(
      'purchases',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
