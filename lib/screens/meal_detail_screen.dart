import 'package:flutter/material.dart';

import '../widgets/page_help.dart';

import '../widgets/app_widgets.dart';
import '../app_controller.dart';
import '../models.dart';
import '../widgets/food_editor.dart';
import '../widgets/purchase_editor.dart';
import '../widgets/lunch_lens.dart';

// open one meal, instead of jumping straight into a payment form.
Future<void> showMealDetails(
  BuildContext context,
  AppController controller,
  FoodItem item, {
  String? note,
  int? servings,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) => MealDetailScreen(
      controller: controller,
      item: item,
      note: note,
      servings: servings,
    ),
  ),
);

// this page shows saved meal info and any plans still waiting to be bought.
class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({
    super.key,
    required this.controller,
    required this.item,
    this.note,
    this.servings,
  });
  final AppController controller;
  final FoodItem item;
  final String? note;
  final int? servings;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      // a menu meal might have been saved while this page was open. use its saved id now.
      final matches = controller.foodItems.where(
        (e) => item.id != null
            ? e.id == item.id
            : e.name.toLowerCase() == item.name.toLowerCase() &&
                  e.store.toLowerCase() == item.store.toLowerCase(),
      );
      final meal = matches.isEmpty ? item : matches.first;
      // only plans for this meal belong here. old receipts stay in History.
      final plans = controller.plannedPurchases
          .where((e) => meal.id != null && e.foodItemId == meal.id)
          .toList();
      final gap = (MediaQuery.sizeOf(context).width * .05).clamp(16.0, 28.0);
      final theme = Theme.of(context);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meal details'),
          actions: const [
            PageHelp(
              title: 'Meal details',
              message: 'Plan this meal before buying it, or log it now if you already paid. Lunch Lens uses your last three purchases to suggest a price. You can ignore it. Only Save purchase changes your spending.',
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(gap),
          children: [
            Text(meal.name, style: theme.textTheme.headlineMedium),
            Text(meal.store, style: theme.textTheme.titleMedium),
            SizedBox(height: gap),
            Text(
              'Estimated price ${formatMoney(meal.lastPriceCents)}',
              style: theme.textTheme.titleLarge,
            ),
            if (note != null && note!.isNotEmpty) Text(note!),
            SizedBox(height: gap),

            SizedBox(height: gap),
            // planning only saves an estimate. spending changes after Log purchase.
            FilledButton(
              onPressed: () => showPurchaseEditor(
                context,
                controller,
                foodItem: meal,
                plannedOnly: true,
                saveToItems: true,
                initialNote: note,
                initialServings: servings,
              ),
              child: const Text('Plan this meal'),
            ),
            // skip planning when the user already bought their food.
            OutlinedButton(
              onPressed: () => showPurchaseEditor(
                context,
                controller,
                foodItem: meal,
                saveToItems: true,
                initialNote: note,
                initialServings: servings,
              ),
              child: const Text('Already bought it? Log purchase'),
            ),
            if (meal.id != null)
              TextButton(
                onPressed: () =>
                    showFoodEditor(context, controller, item: meal),
                child: const Text('Edit meal'),
              ),
            SizedBox(height: gap),
            // finish edits the same planned row, it does not create a second receipt.
            if (plans.isNotEmpty) ...[
              Text('Your plans', style: theme.textTheme.titleLarge),
              ...plans.map(
                (plan) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: gap),
                    Text(
                      '${shortDate(plan.purchasedAt)} · Planned ${formatMoney(plan.amountCents)}',
                    ),
                    FilledButton(
                      onPressed: () => showPurchaseEditor(
                        context,
                        controller,
                        purchase: plan,
                        confirmPurchase: true,
                      ),
                      child: const Text('Log purchase / Finish'),
                    ),
                    TextButton(
                      onPressed: () =>
                          cancelMealPlan(context, controller, plan),
                      child: const Text('Reset plan'),
                    ),
                  ],
                ),
              ),
            ] else
              const Text(
                'No plans yet. Planning a meal won’t change your balance.',
              ),
            SizedBox(height: gap),
            LunchLens(
              controller: controller,
              mealId: meal.id,
              before: DateTime.now(),
            ),
          ],
        ),
      );
    },
  );
}

// reset only removes this pending plan. the data layer checks that too.
Future<void> cancelMealPlan(
  BuildContext context,
  AppController controller,
  PurchaseEntry plan,
) async {
  final reset = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset this plan?'),
      content: const Text('Your past purchases will stay in History.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Reset plan'),
        ),
      ],
    ),
  );
  if (reset != true || !context.mounted) return;
  try {
    await controller.cancelPlan(plan);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t reset this plan. Please try again.'),
        ),
      );
    }
  }
}
