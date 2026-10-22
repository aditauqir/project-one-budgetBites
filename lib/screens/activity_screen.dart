import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import '../widgets/app_widgets.dart';
import '../widgets/purchase_editor.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final spent = controller.spentTodayCents;
    final allowance = controller.settings.dailyBudgetCents;
    final remaining = allowance - spent;
    final fraction = allowance <= 0 ? 0.0 : (spent / allowance).clamp(0.0, 1.0);
    final plans = controller.todaysChecklist;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Text(
          'Your day plan',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: appHeadingWeight, color: appInk),
        ),
        const SizedBox(height: 3),
        Text(
          '${weekdayShort(today)}, ${shortDate(today)}',
          style: const TextStyle(color: appMuted),
        ),
        const SizedBox(height: 14),
        AppCard(
          borderColor: appBorder,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY BUDGET LEFT',
                      style: TextStyle(
                        color: appMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMoney(remaining),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: appAmountWeight,
                        color: remaining < 0 ? appError : appIconColor,
                      ),
                    ),
                    Text(
                      'of ${formatMoney(allowance)} planned for today',
                      style: const TextStyle(color: appMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 9,
                        backgroundColor: appBorder,
                        color: spent > allowance
                            ? appError
                            : spent >= allowance * .8
                            ? appWarning
                            : appPrimary,
                      ),
                    ),
                    Text(
                      '${(fraction * 100).round()}%',
                      style: const TextStyle(
                        fontWeight: appEmphasisWeight,
                        color: appInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Adjust today\'s allowance',
                  style: TextStyle(
                    fontWeight: appEmphasisWeight,
                    color: appInk,
                  ),
                ),
              ),
              IconButton(
                onPressed: allowance >= 100
                    ? () => _changeAllowance(context, allowance - 100)
                    : null,
                icon: const Icon(AppIcons.removeCircle),
                tooltip: 'Reduce by one dollar',
              ),
              Text(
                formatMoney(allowance),
                style: const TextStyle(fontWeight: appEmphasisWeight),
              ),
              IconButton(
                onPressed: () => _changeAllowance(context, allowance + 100),
                icon: const Icon(AppIcons.addCircle),
                tooltip: 'Add one dollar',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Suggested amount',
                      style: TextStyle(
                        fontWeight: appEmphasisWeight,
                        color: appInk,
                      ),
                    ),
                  ),
                  Text(
                    formatMoney(controller.suggestedDailyBudgetCents),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: appAmountWeight,
                      color: appIconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'It uses your confirmed weekly spending and days left in the week. You can change the allowance above.',
                style: const TextStyle(color: appMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SectionHeading(
          'Today\'s checklist',
          trailing: FilledButton.tonalIcon(
            onPressed: () =>
                showPurchaseEditor(context, controller, plannedOnly: true),
            icon: const Icon(AppIcons.add, size: 18),
            label: const Text('Add'),
          ),
        ),
        const SizedBox(height: 8),
        if (plans.isEmpty)
          AppCard(
            child: EmptyMessage(
              title: 'Nothing planned yet',
              detail: 'Add a meal or drink to keep the day plan in one place.',
              icon: AppIcons.checklist,
            ),
          )
        else
          ...plans.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: entry.isConfirmed,
                      onChanged: (_) => entry.isConfirmed
                          ? _unconfirm(context, entry)
                          : showPurchaseEditor(
                              context,
                              controller,
                              purchase: entry,
                              confirmPurchase: true,
                            ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => showPurchaseEditor(
                          context,
                          controller,
                          purchase: entry,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.itemName,
                              style: TextStyle(
                                fontWeight: appEmphasisWeight,
                                decoration: entry.isConfirmed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Text(
                              '${entry.store} · ${entry.servings} serving${entry.servings == 1 ? '' : 's'} · ${TimeOfDay.fromDateTime(entry.purchasedAt).format(context)}',
                              style: const TextStyle(
                                color: appMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      formatMoney(entry.amountCents),
                      style: const TextStyle(fontWeight: appEmphasisWeight),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => value == 'delete'
                          ? _delete(context, entry)
                          : showPurchaseEditor(
                              context,
                              controller,
                              purchase: entry,
                            ),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'Only confirmed items count as spending. Tap an unchecked circle to confirm an item; changing it back asks first.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: appMuted),
        ),
      ],
    );
  }

  Future<void> _changeAllowance(BuildContext context, int amount) async {
    await controller.saveSettings(
      controller.settings.copyWith(dailyBudgetCents: amount),
    );
  }

  Future<void> _unconfirm(BuildContext context, PurchaseEntry entry) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move back to planned?'),
        content: const Text(
          'This removes the purchase from confirmed spending totals. The checklist item stays saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep confirmed'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Move to planned'),
          ),
        ],
      ),
    );
    if (accepted == true) {
      await controller.savePurchase(entry.copyWith(isConfirmed: false));
    }
  }

  Future<void> _delete(BuildContext context, PurchaseEntry entry) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this checklist item?'),
        content: const Text(
          'This removes the saved plan or purchase. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (accepted == true) await controller.deletePurchase(entry);
  }
}
