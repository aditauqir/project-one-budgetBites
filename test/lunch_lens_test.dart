import 'package:budgetbites/logic/lunch_lens.dart';
import 'package:budgetbites/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a receipt for the helper tests. Only the fields Lunch Lens reads
/// are varied, so each test states exactly what matters.
PurchaseEntry receipt(
  int cents, {
  int? id,
  int? mealId = 1,
  DateTime? at,
  bool confirmed = true,
  String note = '',
}) {
  return PurchaseEntry(
    id: id,
    foodItemId: mealId,
    itemName: 'Test meal',
    store: 'Test store',
    category: 'Food',
    amountCents: cents,
    purchasedAt: at ?? DateTime(2026, 10, 24, 12),
    note: note,
    isConfirmed: confirmed,
  );
}

void main() {
  final now = DateTime(2026, 10, 25, 12);

  group('three-price mean', () {
    test('normal case: 450, 600, 750 -> 600, baseline 750', () {
      // The 650 receipt is the *later actual* used only to score the estimate,
      // so it is deliberately not in the input list.
      final estimate = estimateLunch(
        [
          receipt(450, id: 1, at: DateTime(2026, 10, 21)),
          receipt(600, id: 2, at: DateTime(2026, 10, 22)),
          receipt(750, id: 3, at: DateTime(2026, 10, 23)),
        ],
        mealId: 1,
        before: DateTime(2026, 10, 24),
      );

      expect(estimate, isNotNull);
      expect(estimate!.cents, 600);
      expect(estimate.baselineCents, 750);
      expect(estimate.inputs.map((e) => e.amountCents), [750, 600, 450]);
      // Absolute error for the later 650 receipt, helper vs baseline.
      expect((estimate.cents - 650).abs(), 50);
      expect((estimate.baselineCents - 650).abs(), 100);
    });

    test('fewer than three earlier receipts returns no estimate', () {
      final estimate = estimateLunch(
        [
          receipt(450, id: 1, at: DateTime(2026, 10, 21)),
          receipt(600, id: 2, at: DateTime(2026, 10, 22)),
        ],
        mealId: 1,
        before: now,
      );

      expect(estimate, isNull);
    });

    test('boundary: 0, 0, 1 rounds to 0 cents', () {
      final estimate = estimateLunch(
        [
          receipt(0, id: 1, at: DateTime(2026, 10, 21)),
          receipt(0, id: 2, at: DateTime(2026, 10, 22)),
          receipt(1, id: 3, at: DateTime(2026, 10, 23)),
        ],
        mealId: 1,
        before: now,
      );

      expect(estimate!.cents, 0);
      expect(estimate.baselineCents, 1);
    });

    test('rounds to the nearest cent', () {
      final estimate = estimateLunch(
        [
          receipt(100, id: 1, at: DateTime(2026, 10, 21)),
          receipt(100, id: 2, at: DateTime(2026, 10, 22)),
          receipt(101, id: 3, at: DateTime(2026, 10, 23)),
        ],
        mealId: 1,
        before: now,
      );

      // 301 / 3 = 100.33
      expect(estimate!.cents, 100);
    });
  });
}
