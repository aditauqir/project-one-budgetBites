import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import 'data/app_database.dart';
import 'data/preferences_store.dart';
import 'models.dart';

/// Thrown when a meal still has saved receipts. The app uses a restriction
/// policy: the user clears the linked receipts first, so spending history is
/// never detached or deleted without an explicit choice.
class MealInUseException implements Exception {
  const MealInUseException(this.purchaseCount);

  final int purchaseCount;

  @override
  String toString() =>
      'MealInUseException: $purchaseCount receipt(s) still linked';
}

class AppController extends ChangeNotifier {
  AppController({AppDatabase? database, PreferencesStore? preferences})
    : _database = database ?? AppDatabase.instance,
      _preferences = preferences ?? PreferencesStore();

  final AppDatabase _database;
  final PreferencesStore _preferences;

  AppSettings settings = const AppSettings();
  List<FoodItem> foodItems = const [];
  List<PurchaseEntry> purchases = const [];
  bool isLoading = true;
  String? loadError;

  Future<void> load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      settings = await _preferences.load();
      await refresh(notify: false);
    } catch (error) {
      loadError = 'Could not load saved data. Please restart the app.';
      debugPrint('Budget Bites load failed: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({bool notify = true}) async {
    foodItems = await _database.getFoodItems();
    purchases = await _database.getPurchases();
    if (notify) notifyListeners();
  }

  Future<void> saveSettings(AppSettings value) async {
    settings = value;
    await _preferences.save(value);
    notifyListeners();
  }

  Future<FoodItem> saveFoodItem({
    int? id,
    required String name,
    required String store,
    required int priceCents,
  }) async {
    if (id == null) {
      final duplicate = foodItems.where(
        (item) =>
            item.name.toLowerCase() == name.trim().toLowerCase() &&
            item.store.toLowerCase() == store.trim().toLowerCase(),
      );
      if (duplicate.isNotEmpty) id = duplicate.first.id;
    }
    final originalMatches = id == null
        ? const <FoodItem>[]
        : foodItems.where((item) => item.id == id).toList();
    final original = originalMatches.isEmpty ? null : originalMatches.first;
    final item = FoodItem(
      id: id,
      name: name.trim(),
      store: store.trim(),
      category: inferCategory(name),
      lastPriceCents: priceCents,
      createdAt: original?.createdAt ?? DateTime.now(),
    );
    if (id == null) {
      final newId = await _database.insertFoodItem(item);
      final saved = item.copyWith(id: newId);
      await refresh();
      return saved;
    }
    await _database.updateFoodItem(item);
    await refresh();
    return item;
  }

  Future<void> deleteFoodItem(FoodItem item) async {
    if (item.id == null) return;
    // Restriction policy: block the delete while receipts point at this meal.
    // Counted from the loaded list first for a friendly dialog, then enforced
    // again by the database foreign key in case the list is stale.
    final linked = linkedPurchaseCount(item.id!);
    if (linked > 0) throw MealInUseException(linked);
    try {
      await _database.deleteFoodItem(item.id!);
    } on DatabaseException {
      throw MealInUseException(linkedPurchaseCount(item.id!));
    }
    await refresh();
  }

  int linkedPurchaseCount(int mealId) =>
      purchases.where((purchase) => purchase.foodItemId == mealId).length;

  // every receipt needs a meal link, even when it started from New item.
  // hey willow, every new receipt gets a meal id now. old unlinked receipts still show in History.
  Future<void> savePurchase(PurchaseEntry entry) async {
    if (entry.amountCents < 0 ||
        entry.itemName.trim().isEmpty ||
        entry.store.trim().isEmpty ||
        entry.servings < 1) {
      throw ArgumentError('Invalid purchase');
    }
    // actual receipt price does not overwrite the saved meal estimate.
    await _database.saveLinkedPurchase(
      entry.copyWith(category: inferCategory(entry.itemName)),
    );
    await refresh();
  }

  // a confirmed purchase cannot be reset as if it never happened.
  Future<void> cancelPlan(PurchaseEntry entry) async {
    if (entry.id == null || entry.isConfirmed) return;
    await _database.cancelPlan(entry.id!);
    await refresh();
  }

  Future<void> deletePurchase(PurchaseEntry entry) async {
    if (entry.id == null) return;
    await _database.deletePurchase(entry.id!);
    await refresh();
  }

  List<PurchaseEntry> get confirmedPurchases =>
      purchases.where((purchase) => purchase.isConfirmed).toList();

  List<PurchaseEntry> get plannedPurchases =>
      purchases.where((purchase) => !purchase.isConfirmed).toList();

  int get spentTodayCents => confirmedPurchases
      .where(
        (purchase) =>
            isSameDay(purchase.purchasedAt, DateTime.now()) &&
            !purchase.purchasedAt.isAfter(DateTime.now()),
      )
      .fold(0, (total, purchase) => total + purchase.amountCents);

  int get spentThisWeekCents {
    final now = DateTime.now();
    final monday = dateOnly(now).subtract(Duration(days: now.weekday - 1));
    return confirmedPurchases
        .where(
          (purchase) =>
              !purchase.purchasedAt.isBefore(monday) &&
              !purchase.purchasedAt.isAfter(now),
        )
        .fold(0, (total, purchase) => total + purchase.amountCents);
  }

  int get remainingTodayCents => settings.dailyBudgetCents - spentTodayCents;

  int get remainingWeekCents => settings.weeklyBudgetCents - spentThisWeekCents;

  List<PurchaseEntry> get todaysChecklist =>
      purchases
          .where((purchase) => isSameDay(purchase.purchasedAt, DateTime.now()))
          .toList()
        ..sort((a, b) => a.purchasedAt.compareTo(b.purchasedAt));

  int spentOnDay(DateTime day) => confirmedPurchases
      .where(
        (purchase) =>
            isSameDay(purchase.purchasedAt, day) &&
            !purchase.purchasedAt.isAfter(DateTime.now()),
      )
      .fold(0, (total, purchase) => total + purchase.amountCents);

  int spentInCategory(String category, {bool thisWeekOnly = true}) {
    final now = DateTime.now();
    final monday = dateOnly(now).subtract(Duration(days: now.weekday - 1));
    return confirmedPurchases
        .where(
          (purchase) =>
              purchase.category == category &&
              (!thisWeekOnly ||
                  (!purchase.purchasedAt.isBefore(monday) &&
                      !purchase.purchasedAt.isAfter(now))) &&
              !purchase.purchasedAt.isAfter(now),
        )
        .fold(0, (total, purchase) => total + purchase.amountCents);
  }

  int get suggestedDailyBudgetCents {
    final now = DateTime.now();
    final daysLeft = 8 - now.weekday;
    final remaining = math.max(0, remainingWeekCents);
    return math.min(settings.dailyBudgetCents, remaining ~/ daysLeft);
  }

  String get suggestionExplanation {
    final days = 8 - DateTime.now().weekday;
    return '${formatMoney(math.max(0, remainingWeekCents))} left across $days day${days == 1 ? '' : 's'} this week';
  }
}
