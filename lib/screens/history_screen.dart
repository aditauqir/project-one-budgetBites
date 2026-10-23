import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import '../widgets/app_widgets.dart';
import '../widgets/purchase_editor.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final today = dateOnly(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekPurchases = controller.confirmedPurchases
        .where((entry) => !entry.purchasedAt.isBefore(weekStart))
        .toList();
    final history = controller.confirmedPurchases
        .where((entry) => _category == 'All' || entry.category == _category)
        .toList();
    final weekTotal = weekPurchases.fold(
      0,
      (sum, entry) => sum + entry.amountCents,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Text(
          'Your spending story',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: appInk, fontWeight: appHeadingWeight),
        ),
        const SizedBox(height: 4),
        const Text(
          'Confirmed purchases only',
          style: TextStyle(color: appMuted),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily spending this week',
                style: TextStyle(fontWeight: appEmphasisWeight, color: appInk),
              ),
              const SizedBox(height: 14),
              SizedBox(height: 178, child: _WeekChart(controller: controller)),
              const Divider(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text('This week', style: TextStyle(color: appMuted)),
                  ),
                  Text(
                    formatMoney(weekTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: appAmountWeight,
                      color: appInk,
                    ),
                  ),
                ],
              ),
              Text(
                '${weekPurchases.length} confirmed purchases',
                style: const TextStyle(color: appMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionHeading(
          'Purchases',
          trailing: DropdownButton<String>(
            value: _category,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Food', child: Text('Food')),
              DropdownMenuItem(value: 'Drinks', child: Text('Drinks')),
              DropdownMenuItem(value: 'Misc', child: Text('Misc')),
            ],
            onChanged: (value) => setState(() => _category = value ?? 'All'),
          ),
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          AppCard(
            child: EmptyMessage(
              title: 'No confirmed purchases yet',
              detail:
                  'Items you confirm from the Log or Activity page show here.',
              icon: AppIcons.receipt,
            ),
          )
        else
          ...history.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PurchaseRow(
                entry: entry,
                onEdit: () =>
                    showPurchaseEditor(context, controller, purchase: entry),
                onDelete: () => _delete(context, entry),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, PurchaseEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this purchase?'),
        content: const Text(
          'The purchase will be removed from your history and spending totals.',
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
    if (confirmed == true) await widget.controller.deletePurchase(entry);
  }
}

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });
  final PurchaseEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: appPrimarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            entry.category == 'Drinks' ? AppIcons.coffee : AppIcons.restaurant,
            color: appIconColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.itemName,
                style: const TextStyle(
                  fontWeight: appEmphasisWeight,
                  color: appInk,
                ),
              ),
              Text(
                '${entry.store} · ${entry.servings} serving${entry.servings == 1 ? '' : 's'} · ${shortDate(entry.purchasedAt)} · ${TimeOfDay.fromDateTime(entry.purchasedAt).format(context)}',
                style: const TextStyle(color: appMuted, fontSize: 12),
              ),
              if (entry.note.isNotEmpty)
                Text(
                  entry.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: appMuted, fontSize: 12),
                ),
            ],
          ),
        ),
        Text(
          formatMoney(entry.amountCents),
          style: const TextStyle(fontWeight: appEmphasisWeight),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => value == 'delete' ? onDelete() : onEdit(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ],
    ),
  );
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final now = dateOnly(DateTime.now());
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (index) => monday.add(Duration(days: index)));
    final values = days.map(controller.spentOnDay).toList();
    final maxValue = values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final amount = values[index];
        final fraction = maxValue == 0 ? 0.0 : amount / maxValue;
        final isToday = isSameDay(days[index], now);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatMoney(amount),
                  maxLines: 1,
                  style: const TextStyle(fontSize: 9, color: appMuted),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: amount == 0 ? .025 : .18 + fraction * .82,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday ? appIconColor : appPrimary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  weekdayShort(days[index]),
                  style: TextStyle(
                    fontSize: 10,
                    color: isToday ? appIconColor : appMuted,
                    fontWeight: isToday ? appEmphasisWeight : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
