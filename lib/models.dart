class FoodItem {
  const FoodItem({
    this.id,
    required this.name,
    required this.store,
    required this.category,
    required this.lastPriceCents,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String store;
  final String category;
  final int lastPriceCents;
  final DateTime createdAt;

  FoodItem copyWith({
    int? id,
    String? name,
    String? store,
    String? category,
    int? lastPriceCents,
    DateTime? createdAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      store: store ?? this.store,
      category: category ?? this.category,
      lastPriceCents: lastPriceCents ?? this.lastPriceCents,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'store': store,
    'category': category,
    'last_price_cents': lastPriceCents,
    'created_at': createdAt.toIso8601String(),
  };

  factory FoodItem.fromMap(Map<String, Object?> map) => FoodItem(
    id: map['id'] as int?,
    name: map['name'] as String,
    store: map['store'] as String,
    category: map['category'] as String,
    lastPriceCents: map['last_price_cents'] as int,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}

class PurchaseEntry {
  const PurchaseEntry({
    this.id,
    this.foodItemId,
    required this.itemName,
    required this.store,
    required this.category,
    required this.amountCents,
    this.servings = 1,
    required this.purchasedAt,
    required this.note,
    required this.isConfirmed,
  });

  final int? id;
  final int? foodItemId;
  final String itemName;
  final String store;
  final String category;
  final int amountCents;
  final int servings;
  final DateTime purchasedAt;
  final String note;
  final bool isConfirmed;

  PurchaseEntry copyWith({
    int? id,
    int? foodItemId,
    String? itemName,
    String? store,
    String? category,
    int? amountCents,
    int? servings,
    DateTime? purchasedAt,
    String? note,
    bool? isConfirmed,
  }) {
    return PurchaseEntry(
      id: id ?? this.id,
      foodItemId: foodItemId ?? this.foodItemId,
      itemName: itemName ?? this.itemName,
      store: store ?? this.store,
      category: category ?? this.category,
      amountCents: amountCents ?? this.amountCents,
      servings: servings ?? this.servings,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      note: note ?? this.note,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'food_item_id': foodItemId,
    'item_name': itemName,
    'store': store,
    'category': category,
    'amount_cents': amountCents,
    'servings': servings,
    'purchased_at': purchasedAt.toIso8601String(),
    'note': note,
    'is_confirmed': isConfirmed ? 1 : 0,
  };

  factory PurchaseEntry.fromMap(Map<String, Object?> map) => PurchaseEntry(
    id: map['id'] as int?,
    foodItemId: map['food_item_id'] as int?,
    itemName: map['item_name'] as String,
    store: map['store'] as String,
    category: map['category'] as String,
    amountCents: map['amount_cents'] as int,
    servings: map['servings'] as int? ?? 1,
    purchasedAt: DateTime.parse(map['purchased_at'] as String),
    note: map['note'] as String? ?? '',
    isConfirmed: (map['is_confirmed'] as int) == 1,
  );
}

class AppSettings {
  const AppSettings({
    this.name = 'Adi',
    this.university = 'Georgia State University',
    this.weeklyBudgetCents = 10000,
    this.dailyBudgetCents = 2000,
    this.calorieGoal,
    this.carbGoalGrams,
    this.proteinGoalGrams,
    this.fatGoalGrams,
    this.favoritePlaces = const [
      'Saxbys',
      'Azalea Fresh Market',
      'Blossom Tree',
      'BrickStone Cafe & Restaurant',
    ],
    this.location = 'Downtown Atlanta campus',
    this.notificationsEnabled = false,
  });

  final String name;
  final String university;
  final int weeklyBudgetCents;
  final int dailyBudgetCents;
  final int? calorieGoal;
  final int? carbGoalGrams;
  final int? proteinGoalGrams;
  final int? fatGoalGrams;
  final List<String> favoritePlaces;
  final String location;
  final bool notificationsEnabled;

  AppSettings copyWith({
    String? name,
    String? university,
    int? weeklyBudgetCents,
    int? dailyBudgetCents,
    int? calorieGoal,
    int? carbGoalGrams,
    int? proteinGoalGrams,
    int? fatGoalGrams,
    List<String>? favoritePlaces,
    String? location,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      name: name ?? this.name,
      university: university ?? this.university,
      weeklyBudgetCents: weeklyBudgetCents ?? this.weeklyBudgetCents,
      dailyBudgetCents: dailyBudgetCents ?? this.dailyBudgetCents,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      carbGoalGrams: carbGoalGrams ?? this.carbGoalGrams,
      proteinGoalGrams: proteinGoalGrams ?? this.proteinGoalGrams,
      fatGoalGrams: fatGoalGrams ?? this.fatGoalGrams,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      location: location ?? this.location,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

String inferCategory(String itemName) {
  final name = itemName.toLowerCase();
  const drinkWords = [
    'drink',
    'coffee',
    'tea',
    'water',
    'soda',
    'juice',
    'energy',
    'monster',
    'latte',
    'smoothie',
  ];
  if (drinkWords.any(name.contains)) return 'Drinks';

  const foodWords = [
    'sandwich',
    'wrap',
    'salad',
    'meal',
    'lunch',
    'dinner',
    'snack',
    'food',
    'burrito',
    'pizza',
  ];
  if (foodWords.any(name.contains)) return 'Food';
  return 'Misc';
}

int? parseMoneyToCents(String raw) {
  final value = raw.replaceAll(r'$', '').replaceAll(',', '').trim();
  if (value.isEmpty) return null;
  final match = RegExp(r'^(\d+)(?:\.(\d{0,2}))?$').firstMatch(value);
  if (match == null) return null;
  final dollars = int.tryParse(match.group(1)!);
  if (dollars == null) return null;
  final centsText = (match.group(2) ?? '').padRight(2, '0');
  final cents = centsText.isEmpty ? 0 : int.parse(centsText);
  return dollars * 100 + cents;
}

String formatMoney(int cents) {
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  return '$sign\$${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
