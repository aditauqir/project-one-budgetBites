import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import '../widgets/app_widgets.dart';
import '../widgets/food_editor.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _university;
  late final TextEditingController _weekly;
  late final TextEditingController _daily;
  late final TextEditingController _location;
  late final TextEditingController _place;
  late List<String> _favorites;
  late bool _compactItems;
  bool _saving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final settings = widget.controller.settings;
    _name = TextEditingController(text: settings.name);
    _university = TextEditingController(text: settings.university);
    _weekly = TextEditingController(
      text: _moneyInput(settings.weeklyBudgetCents),
    );
    _daily = TextEditingController(
      text: _moneyInput(settings.dailyBudgetCents),
    );
    _location = TextEditingController(text: settings.location);
    _place = TextEditingController();
    _favorites = List.of(settings.favoritePlaces);
    _compactItems = settings.compactSavedItems;
  }

  String _moneyInput(int cents) =>
      '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    for (final field in [
      _name,
      _university,
      _weekly,
      _daily,
      _location,
      _place,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  // just a plain list here, no boxes around each section.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gap = (MediaQuery.sizeOf(context).width * .05).clamp(16.0, 28.0);
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(gap),
        children: [
          Text('Settings', style: theme.textTheme.headlineLarge),
          SizedBox(height: gap),
          Text('Profile', style: theme.textTheme.headlineSmall),
          SizedBox(height: gap),
          _textField(_name, 'Name'),
          SizedBox(height: gap),
          _textField(_university, 'University'),
          SizedBox(height: gap),
          _textField(_location, 'Campus'),
          SizedBox(height: gap * 1.5),
          Text('Budget', style: theme.textTheme.headlineSmall),
          SizedBox(height: gap),
          _budgetControl('Daily', _daily, 10000, gap),
          SizedBox(height: gap),
          _budgetControl('Weekly', _weekly, 50000, gap),
          SizedBox(height: gap),
          Text('Display', style: theme.textTheme.headlineSmall),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Compact saved items'),
            subtitle: const Text('Use less space in the list below.'),
            value: _compactItems,
            onChanged: (value) => setState(() => _compactItems = value),
          ),
          SizedBox(height: gap),
          Text('Favorite places', style: theme.textTheme.headlineSmall),
          SizedBox(height: gap / 2),
          if (_favorites.isEmpty) const Text('No places saved yet.'),
          Wrap(
            spacing: gap / 2,
            children: _favorites
                .map(
                  (place) => InputChip(
                    label: Text(place),
                    onDeleted: () => setState(() => _favorites.remove(place)),
                  ),
                )
                .toList(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _place,
                  decoration: const InputDecoration(labelText: 'Add a place'),
                  onSubmitted: (_) => _addPlace(),
                ),
              ),
              IconButton(
                onPressed: _addPlace,
                icon: const Icon(AppIcons.add),
                tooltip: 'Add favorite place',
              ),
            ],
          ),
          SizedBox(height: gap),
          SectionHeading(
            'Saved items',
            trailing: TextButton.icon(
              onPressed: () => showFoodEditor(context, widget.controller),
              icon: const Icon(AppIcons.add),
              label: const Text('Add item'),
            ),
          ),
          if (widget.controller.foodItems.isEmpty)
            const Text('No saved items yet.')
          else
            ...widget.controller.foodItems.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: _compactItems,
                title: Text(item.name),
                subtitle: Text(
                  '${item.store} · ${formatMoney(item.lastPriceCents)}',
                ),
                onLongPress: () =>
                    showFoodEditor(context, widget.controller, item: item),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(AppIcons.edit),
                      tooltip: 'Edit item',
                      onPressed: () => showFoodEditor(
                        context,
                        widget.controller,
                        item: item,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(AppIcons.delete),
                      tooltip: 'Delete item',
                      onPressed: () => _deleteItem(context, item),
                    ),
                  ],
                ),
              ),
            ),
          if (_message != null) ...[
            SizedBox(height: gap),
            Semantics(
              liveRegion: true,
              child: Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('Saved') ? appSuccess : appError,
                ),
              ),
            ),
          ],
          SizedBox(height: gap),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(AppIcons.save),
            label: Text(_saving ? 'Saving...' : 'Save settings'),
          ),
        ],
      ),
    );
  }

  Widget _budgetControl(
    String label,
    TextEditingController field,
    int limit,
    double gap,
  ) {
    final cents = parseMoneyToCents(field.text) ?? 0;
    // keep big old budgets too, the slider should not cut them off.
    final maxCents = cents > limit ? cents : limit;
    void update(int value) => setState(() => field.text = _moneyInput(value));
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: gap / 2),
        Row(
          children: [
            IconButton.outlined(
              onPressed: cents >= 100 ? () => update(cents - 100) : null,
              tooltip: 'Reduce $label budget by one dollar',
              icon: const Icon(AppIcons.removeCircle),
            ),
            Expanded(
              child: Text(
                formatMoney(cents),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            IconButton.outlined(
              onPressed: () => update(cents + 100),
              tooltip: 'Increase $label budget by one dollar',
              icon: const Icon(AppIcons.addCircle),
            ),
          ],
        ),
        // yellow up to the circle, gray after it.
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: appPrimary,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: appPrimary,
          ),
          child: Slider(
            value: cents.toDouble(),
            min: 0,
            max: maxCents.toDouble(),
            label: formatMoney(cents),
            semanticFormatterCallback: (value) =>
                '$label budget ${formatMoney(value.round())}',
            onChanged: (value) => update(value.round()),
          ),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool money = false,
    bool integer = false,
    String? hint,
  }) => TextFormField(
    controller: controller,
    keyboardType: money || integer
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: money ? r'$ ' : null,
    ),
    style: TextStyle(
      fontSize: money || integer ? 18 : 15,
      fontWeight: money || integer ? appEmphasisWeight : FontWeight.normal,
    ),
    validator: (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty && (money || integer)) return '$label is required.';
      if (text.isEmpty && !money && !integer) return '$label is required.';
      if (money && parseMoneyToCents(text) == null) {
        return 'Enter a valid amount.';
      }
      if (integer &&
          text.isNotEmpty &&
          (int.tryParse(text) == null || int.parse(text) < 0)) {
        return 'Enter a whole number zero or higher.';
      }
      return null;
    },
  );

  void _addPlace() {
    final place = _place.text.trim();
    if (place.isEmpty) return;
    if (!_favorites.any(
      (saved) => saved.toLowerCase() == place.toLowerCase(),
    )) {
      setState(() => _favorites.add(place));
    }
    _place.clear();
  }

  Future<void> _save() async {
    // dont save twice while the first write is still going.
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final settings = widget.controller.settings.copyWith(
        name: _name.text.trim(),
        university: _university.text.trim(),
        weeklyBudgetCents: parseMoneyToCents(_weekly.text)!,
        dailyBudgetCents: parseMoneyToCents(_daily.text)!,
        favoritePlaces: _favorites,
        location: _location.text.trim(),
        compactSavedItems: _compactItems,
      );
      await widget.controller.saveSettings(settings);
      if (mounted) {
        setState(() {
          _saving = false;
          _message = 'Saved on this device.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _message = 'Could not save. Please try again.';
        });
      }
    }
  }

  Future<void> _deleteItem(BuildContext context, FoodItem item) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete saved item?'),
        content: const Text(
          'Past purchase records stay in history, but they will no longer link to this saved item.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep item'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (accepted == true) await widget.controller.deleteFoodItem(item);
  }
}
