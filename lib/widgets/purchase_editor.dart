import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import 'app_widgets.dart';

Future<void> showPurchaseEditor(
  BuildContext context,
  AppController controller, {
  FoodItem? foodItem,
  PurchaseEntry? purchase,
  bool plannedOnly = false,
  bool confirmPurchase = false,
  bool saveToItems = false,
  String? initialNote,
  int? initialServings,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: appCanvas,
    builder: (context) => PurchaseEditor(
      controller: controller,
      foodItem: foodItem,
      purchase: purchase,
      plannedOnly: plannedOnly,
      confirmPurchase: confirmPurchase,
      saveToItems: saveToItems,
      initialNote: initialNote,
      initialServings: initialServings,
    ),
  );
}

class PurchaseEditor extends StatefulWidget {
  const PurchaseEditor({
    super.key,
    required this.controller,
    this.foodItem,
    this.purchase,
    this.plannedOnly = false,
    this.confirmPurchase = false,
    this.saveToItems = false,
    this.initialNote,
    this.initialServings,
  });

  final AppController controller;
  final FoodItem? foodItem;
  final PurchaseEntry? purchase;
  final bool plannedOnly;
  final bool confirmPurchase;
  final bool saveToItems;
  final String? initialNote;
  final int? initialServings;

  @override
  State<PurchaseEditor> createState() => _PurchaseEditorState();
}

class _PurchaseEditorState extends State<PurchaseEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _servingsController;
  late final TextEditingController _noteController;
  late final TextEditingController _customStoreController;
  late DateTime _pickedAt;
  late String _store;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final purchase = widget.purchase;
    final foodItem = widget.foodItem;
    _nameController = TextEditingController(
      text: purchase?.itemName ?? foodItem?.name ?? '',
    );
    _priceController = TextEditingController(
      text: _moneyInput(purchase?.amountCents ?? foodItem?.lastPriceCents ?? 0),
    );
    _servingsController = TextEditingController(
      text: (purchase?.servings ?? widget.initialServings ?? 1).toString(),
    );
    _noteController = TextEditingController(
      text: purchase?.note ?? widget.initialNote ?? '',
    );
    _customStoreController = TextEditingController();
    _pickedAt = purchase?.purchasedAt ?? DateTime.now();
    if (widget.confirmPurchase && _pickedAt.isAfter(DateTime.now())) {
      _pickedAt = DateTime.now();
    }
    final favoritePlaces = widget.controller.settings.favoritePlaces;
    _store =
        purchase?.store ??
        foodItem?.store ??
        (favoritePlaces.isEmpty ? 'Other' : favoritePlaces.first);
  }

  String _moneyInput(int cents) =>
      '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _servingsController.dispose();
    _noteController.dispose();
    _customStoreController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickedAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _pickedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final price = parseMoneyToCents(_priceController.text);
    final servings = int.tryParse(_servingsController.text.trim());
    if (name.isEmpty) {
      setState(() => _error = 'Add the item name first.');
      return;
    }
    final store = _store == 'Other'
        ? _customStoreController.text.trim()
        : _store.trim();
    if (store.isEmpty) {
      setState(() => _error = 'Choose a store.');
      return;
    }
    if (price == null) {
      setState(() => _error = 'Enter a price like 5.50.');
      return;
    }
    if (servings == null || servings < 1) {
      setState(() => _error = 'Enter at least 1 serving.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final old = widget.purchase;
      await widget.controller.savePurchase(
        PurchaseEntry(
          id: old?.id,
          foodItemId: old?.foodItemId ?? widget.foodItem?.id,
          itemName: name,
          store: store,
          category: inferCategory(name),
          amountCents: price,
          servings: servings,
          purchasedAt: _pickedAt,
          note: _noteController.text.trim(),
          isConfirmed: widget.confirmPurchase
              ? true
              : widget.plannedOnly
              ? false
              : old?.isConfirmed ?? true,
        ),
        saveToItems: widget.saveToItems,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save this entry. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stores = <String>{
      ...widget.controller.settings.favoritePlaces,
      _store,
      'Other',
    }.where((store) => store.trim().isNotEmpty).toList();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isPlan =
        widget.plannedOnly ||
        (widget.purchase != null &&
            !widget.purchase!.isConfirmed &&
            !widget.confirmPurchase);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: appBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.purchase == null
                  ? (isPlan ? 'Plan an item' : 'Log a purchase')
                  : (widget.confirmPurchase
                        ? 'Confirm purchase'
                        : 'Edit entry'),
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: appInk, fontWeight: appHeadingWeight),
            ),
            const SizedBox(height: 16),
            Text('Total paid', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _priceController,
              autofocus: widget.foodItem == null && widget.purchase == null,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixText: r'$ ',
                hintText: '0.00',
              ),
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(fontWeight: appAmountWeight),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Item name',
                hintText: 'e.g. campus sandwich',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _servingsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Servings',
                hintText: '1',
              ),
            ),
            const SizedBox(height: 16),
            Text('Store', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: stores.map((store) {
                return ChoiceChip(
                  label: Text(store),
                  selected: _store == store,
                  onSelected: (_) => setState(() => _store = store),
                );
              }).toList(),
            ),
            if (_store == 'Other') ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customStoreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Store or place',
                  hintText: 'Type the restaurant or store name',
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(AppIcons.clock),
              label: Text(
                '${shortDate(_pickedAt)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_pickedAt))}',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Any details to remember',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${inferCategory(_nameController.text)} · suggested from the item name',
              style: const TextStyle(color: appMuted),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: appError)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: Icon(isPlan ? AppIcons.listPlus : AppIcons.save),
                label: Text(
                  _saving
                      ? 'Saving...'
                      : isPlan
                      ? 'Add to checklist'
                      : 'Save purchase',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
