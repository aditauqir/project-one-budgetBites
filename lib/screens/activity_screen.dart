import 'package:flutter/material.dart';

import '../widgets/page_help.dart';

import '../widgets/app_widgets.dart';
import '../app_controller.dart';
import '../models.dart';
import '../widgets/purchase_editor.dart';
import 'meal_detail_screen.dart';

// pending meals go first, bought meals are separate so its clear what counts.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) {
    final gap = (MediaQuery.sizeOf(context).width * .05).clamp(16.0, 28.0);
    final theme = Theme.of(context);
    // include older plans too, so an unfinished meal does not disappear tomorrow.
    final plans = controller.plannedPurchases;
    final today = controller.confirmedPurchases.where(
      (p) => isSameDay(p.purchasedAt, DateTime.now()),
    );
    return ListView(
      padding: EdgeInsets.all(gap),
      children: [
        const PageHeading(
          title: 'Plans',
          help: 'These meals are still planned. Tap Log purchase when you buy one, then enter what you paid. Reset removes a plan. Your old purchases stay in History.',
        ),
        Text(
          '${formatMoney(controller.remainingTodayCents)} left today',
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: gap),

        SizedBox(height: gap),
        TextButton.icon(
          onPressed: () => showPurchaseEditor(
            context,
            controller,
            plannedOnly: true,
            saveToItems: true,
          ),
          icon: const Icon(Icons.add),
          label: const Text('Plan a meal'),
        ),
        // each plan can be finished, edited, or reset without touching old purchases.
        if (plans.isEmpty)
          const Text('Nothing planned yet.')
        else
          ...plans.map(
            (plan) => Padding(
              padding: EdgeInsets.symmetric(vertical: gap / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.itemName, style: theme.textTheme.titleLarge),
                  Text('${plan.store} · ${shortDate(plan.purchasedAt)}'),
                  Text('Planned ${formatMoney(plan.amountCents)}'),
                  Wrap(
                    spacing: gap / 2,
                    children: [
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
                        onPressed: () => showPurchaseEditor(
                          context,
                          controller,
                          purchase: plan,
                        ),
                        child: const Text('Edit plan'),
                      ),
                      TextButton(
                        onPressed: () =>
                            cancelMealPlan(context, controller, plan),
                        child: const Text('Reset plan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: gap),
        // these already count in the balance. tap to correct the receipt.
        Text('Bought today', style: theme.textTheme.titleLarge),
        if (today.isEmpty)
          const Text('No purchases today.')
        else
          ...today.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(entry.itemName),
              subtitle: Text(entry.store),
              trailing: Text(formatMoney(entry.amountCents)),
              onTap: () =>
                  showPurchaseEditor(context, controller, purchase: entry),
            ),
          ),
      ],
    );
  }
}
