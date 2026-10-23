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
  late final TextEditingController _calories;
  late final TextEditingController _carbs;
  late final TextEditingController _protein;
  late final TextEditingController _fat;
  late final TextEditingController _location;
  late final TextEditingController _place;
  late List<String> _favorites;
  late bool _notifications;
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
    _calories = TextEditingController(
      text: settings.calorieGoal?.toString() ?? '',
    );
    _carbs = TextEditingController(
      text: settings.carbGoalGrams?.toString() ?? '',
    );
    _protein = TextEditingController(
      text: settings.proteinGoalGrams?.toString() ?? '',
    );
    _fat = TextEditingController(text: settings.fatGoalGrams?.toString() ?? '');
    _location = TextEditingController(text: settings.location);
    _place = TextEditingController();
    _favorites = List.of(settings.favoritePlaces);
    _notifications = settings.notificationsEnabled;
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
      _calories,
      _carbs,
      _protein,
      _fat,
      _location,
      _place,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Text(
          'Make it yours',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: appInk, fontWeight: appHeadingWeight),
        ),
        const SizedBox(height: 4),
        const Text(
          'Saved on this device for your next visit.',
          style: TextStyle(color: appMuted),
        ),
        const SizedBox(height: 18),
        const SectionHeading('Profile and campus'),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            children: [
              _textField(_name, 'Your name'),
              const SizedBox(height: 10),
              _textField(_university, 'University'),
              const SizedBox(height: 10),
              _textField(
                _location,
                'Your location',
                hint: 'Type a campus or neighborhood',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeading('Budget'),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            children: [
              _textField(_weekly, 'Weekly food and drink budget', money: true),
              const SizedBox(height: 10),
              _textField(_daily, 'Daily budget', money: true),
              const SizedBox(height: 8),
              const Text(
                'The daily suggestion uses confirmed spending and the days remaining in the current week.',
                style: TextStyle(color: appMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeading('Nutrition goals (optional)'),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textField(_calories, 'Calories per day', integer: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _textField(_carbs, 'Carbs · g', integer: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _textField(_protein, 'Protein · g', integer: true),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _textField(_fat, 'Fat · g', integer: true),
              const SizedBox(height: 8),
              const Text(
                'Nutrition progress stays uncounted until the item has nutrition data. Budget Bites does not guess it from the name or price.',
                style: TextStyle(color: appMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeading('Favorite places'),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_favorites.isEmpty)
                const Text(
                  'No places saved yet.',
                  style: TextStyle(color: appMuted),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _favorites
                    .map(
                      (place) => InputChip(
                        label: Text(place),
                        onDeleted: () =>
                            setState(() => _favorites.remove(place)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _place,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Add a place',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _addPlace,
                    icon: const Icon(AppIcons.add),
                    tooltip: 'Add favorite place',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionHeading('Notifications'),
        const SizedBox(height: 8),
        AppCard(
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Enable reminders',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Saves your preference. Reminder scheduling is not connected in this first build.',
              style: TextStyle(color: appMuted, fontSize: 12),
            ),
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
        ),
        const SizedBox(height: 18),
        SectionHeading(
          'Items',
          trailing: FilledButton.tonalIcon(
            onPressed: () => showFoodEditor(context, widget.controller),
            icon: const Icon(AppIcons.add, size: 18),
            label: const Text('Add item'),
          ),
        ),
        const SizedBox(height: 8),
        if (widget.controller.foodItems.isEmpty)
          AppCard(
            child: EmptyMessage(
              title: 'No saved items',
              detail: 'Saved items can be reused from Existing or Menu in Log.',
            ),
          )
        else
          ...widget.controller.foodItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.bookmark, color: appIconColor),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: appEmphasisWeight,
                              color: appInk,
                            ),
                          ),
                          Text(
                            '${item.store} · ${item.category} · ${formatMoney(item.lastPriceCents)}',
                            style: const TextStyle(
                              color: appMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => showFoodEditor(
                        context,
                        widget.controller,
                        item: item,
                      ),
                      icon: const Icon(AppIcons.edit),
                      tooltip: 'Edit item',
                    ),
                    IconButton(
                      onPressed: () => _deleteItem(context, item),
                      icon: const Icon(AppIcons.delete),
                      tooltip: 'Delete item',
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(
            _message!,
            style: TextStyle(
              color: _message!.startsWith('Saved') ? appSuccess : appError,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(AppIcons.save),
            label: Text(_saving ? 'Saving...' : 'Save settings'),
          ),
        ),
      ],
    ),
  );

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
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final settings = AppSettings(
        name: _name.text.trim(),
        university: _university.text.trim(),
        weeklyBudgetCents: parseMoneyToCents(_weekly.text)!,
        dailyBudgetCents: parseMoneyToCents(_daily.text)!,
        calorieGoal: _optionalInt(_calories.text),
        carbGoalGrams: _optionalInt(_carbs.text),
        proteinGoalGrams: _optionalInt(_protein.text),
        fatGoalGrams: _optionalInt(_fat.text),
        favoritePlaces: _favorites,
        location: _location.text.trim(),
        notificationsEnabled: _notifications,
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

  int? _optionalInt(String value) =>
      value.trim().isEmpty ? null : int.parse(value.trim());

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
