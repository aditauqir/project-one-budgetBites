import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import 'app_widgets.dart';

Future<void> showFoodEditor(
  BuildContext context,
  AppController controller, {
  FoodItem? item,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => FoodEditorDialog(controller: controller, item: item),
  );
}

class FoodEditorDialog extends StatefulWidget {
  const FoodEditorDialog({super.key, required this.controller, this.item});

  final AppController controller;
  final FoodItem? item;

  @override
  State<FoodEditorDialog> createState() => _FoodEditorDialogState();
}

class _FoodEditorDialogState extends State<FoodEditorDialog> {
  late final TextEditingController _name;
  late final TextEditingController _store;
  late final TextEditingController _price;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _store = TextEditingController(text: item?.store ?? '');
    final cents = item?.lastPriceCents ?? 0;
    _price = TextEditingController(
      text: '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _store.dispose();
    _price.dispose();
    super.dispose();
  }

  // validate the meal, then keep Save locked until its done.
  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    final store = _store.text.trim();
    final price = parseMoneyToCents(_price.text);
    if (name.isEmpty || store.isEmpty || price == null) {
      setState(() => _error = 'Add an item, store, and valid price.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controller.saveFoodItem(
        id: widget.item?.id,
        name: name,
        store: store,
        priceCents: price,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Couldn’t save this meal. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item == null ? 'Add meal' : 'Edit meal'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Item name'),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: _store,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Store'),
          ),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Estimated price',
              prefixText: r'$ ',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Category: ${inferCategory(_name.text)} (automatic)',
              style: const TextStyle(color: appMuted),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: appError)),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving...' : 'Save meal'),
      ),
    ],
  );
}

/// Restriction policy for meal deletes, shared by every entry point so Home,
/// Log, and Settings cannot disagree. A meal with receipts is blocked until
/// the user clears those receipts; nothing is ever deleted implicitly.
Future<bool> confirmDeleteMeal(
  BuildContext context,
  AppController controller,
  FoodItem item,
) async {
  final linked = controller.linkedPurchaseCount(item.id ?? -1);
  if (linked > 0) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meal still has receipts'),
        content: Text(
          '“${item.name}” has $linked saved purchase${linked == 1 ? '' : 's'}. '
          'Correct or delete those receipts in History first, then delete the '
          'meal. Your spending history is never removed for you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
    return false;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete “${item.name}”?'),
      content: const Text('This removes the saved meal only. It has no receipts.'),
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
  if (confirmed != true) return false;
  try {
    await controller.deleteFoodItem(item);
    return true;
  } on MealInUseException catch (error) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not delete: ${error.purchaseCount} receipt'
          '${error.purchaseCount == 1 ? '' : 's'} still use this meal.',
        ),
      ),
    );
    return false;
  }
}
