import '../models.dart';

// keep the three inputs too, so we can explain where the number came from.
class LunchEstimate {
  const LunchEstimate(this.inputs, this.cents, this.baselineCents);
  final List<PurchaseEntry> inputs;
  final int cents;
  final int baselineCents;
}

// only earlier receipts for this meal. dont let a receipt predict itself.
LunchEstimate? estimateLunch(
  Iterable<PurchaseEntry> purchases, {
  required int? mealId,
  required DateTime before,
  int? editingId,
}) {
  if (mealId == null) return null;
  // skip other meals, plans, bad amounts, and any future info.
  final valid =
      purchases
          .where(
            (entry) =>
                entry.isConfirmed &&
                entry.foodItemId == mealId &&
                entry.id != editingId &&
                entry.amountCents >= 0 &&
                (entry.purchasedAt.isBefore(before) ||
                    (editingId != null &&
                        entry.purchasedAt.isAtSameMomentAs(before) &&
                        entry.id != null &&
                        entry.id! < editingId)),
          )
          .toList()
        ..sort((a, b) {
          final time = b.purchasedAt.compareTo(a.purchasedAt);
          return time != 0 ? time : (b.id ?? 0).compareTo(a.id ?? 0);
        });
  if (valid.length < 3) return null;
  // newest three only. tied times use the receipt id so the order stays stable.
  final inputs = valid.take(3).toList();
  final sum = inputs.fold(0, (total, entry) => total + entry.amountCents);
  // cents are whole numbers. adding 1 before dividing by 3 rounds to nearest cent.
  return LunchEstimate(inputs, (sum + 1) ~/ 3, inputs.first.amountCents);
}
