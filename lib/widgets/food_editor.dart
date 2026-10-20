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

  Future<void> _save() async {
    final name = _name.text.trim();
    final store = _store.text.trim();
    final price = parseMoneyToCents(_price.text);
    if (name.isEmpty || store.isEmpty || price == null) {
      setState(() => _error = 'Add an item, store, and valid price.');
      return;
    }
    try {
      await widget.controller.saveFoodItem(
        id: widget.item?.id,
        name: name,
        store: store,
        priceCents: price,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not save this item.');
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item == null ? 'Add saved item' : 'Edit saved item'),
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
              labelText: 'Last price',
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
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save item')),
    ],
  );
}
