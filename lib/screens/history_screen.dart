import 'package:flutter/material.dart';

import '../widgets/page_help.dart';

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
  // this choice filters both the receipts and their total.
  String _period = 'This week';
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final today = dateOnly(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final now = DateTime.now();
    // start at midnight for today, Monday for this week, or first of month.
    final start = switch (_period) {
      'Today' => today,
      'This week' => weekStart,
      'This month' => DateTime(now.year, now.month),
      _ => DateTime(2020),
    };
    // planned meals and future dates should never count as bought food.
    final history = controller.confirmedPurchases
        .where(
          (entry) =>
              !entry.purchasedAt.isBefore(start) &&
              !entry.purchasedAt.isAfter(now) &&
              (_category == 'All' || entry.category == _category),
        )
        .toList();
    // add the same rows we show, so the number matches the list.
    // hey willow, if totals move into the data layer, use these same period and category filters.
    final periodTotal = history.fold(
      0,
      (sum, entry) => sum + entry.amountCents,
    );
    final gap = (MediaQuery.sizeOf(context).width * .05).clamp(16.0, 28.0);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        const PageHeading(
          title: 'History',
          help: 'See what you bought here. Pick a time to check the total. Tap a purchase to fix the price or date. Use its menu if you want to delete it.',
        ),
        const SizedBox(height: 14),
        // tap a period, then rebuild the total and the list below.
        Wrap(
          spacing: gap / 2,
          runSpacing: gap / 2,
          children: [
            for (final period in [
              'Today',
              'This week',
              'This month',
              'All time',
            ])
              ChoiceChip(
                label: Text(period),
                selected: _period == period,
                onSelected: (_) => setState(() => _period = period),
              ),
          ],
        ),
        SizedBox(height: gap),
        Text(
          formatMoney(periodTotal),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          '${history.length} purchase${history.length == 1 ? '' : 's'} · $_period${_category == 'All' ? '' : ' · $_category'}',
        ),
        SizedBox(height: gap),
        // the chart stays on this week. the period above controls the receipt list.
        Text(
          'Daily spending this week',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(
          height: gap * 8,
          child: _WeekChart(controller: controller),
        ),
        SizedBox(height: gap),
        TextButton.icon(
          onPressed: () => showPurchaseEditor(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('Add purchase'),
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
          const EmptyMessage(
            title: 'No purchases here yet',
            detail: 'Try another period or add a purchase.',
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

  // ask first, then remove this receipt and refresh the totals.
  Future<void> _delete(BuildContext context, PurchaseEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this purchase?'),
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
    if (confirmed != true || _deleting || !mounted) return;
    _deleting = true;
    try {
      await widget.controller.deletePurchase(entry);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t delete this purchase. Please try again.'),
          ),
        );
      }
    } finally {
      _deleting = false;
    }
  }
}

// tap or long press to fix a receipt. the menu has edit and delete too.
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
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text('${entry.itemName} · ${formatMoney(entry.amountCents)}'),
    subtitle: Text(
      '${entry.store} · ${shortDate(entry.purchasedAt)} · ${TimeOfDay.fromDateTime(entry.purchasedAt).format(context)}${entry.note.isEmpty ? '' : '\n${entry.note}'}',
    ),
    onTap: onEdit,
    onLongPress: onEdit,
    trailing: PopupMenuButton<String>(
      tooltip: 'Purchase options',
      onSelected: (value) => value == 'delete' ? onDelete() : onEdit(),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ),
  );
}

// this chart still shows each day of the current week. filters above control the list total.

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
