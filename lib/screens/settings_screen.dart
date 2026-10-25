import 'package:flutter/material.dart';

import '../widgets/page_help.dart';

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
          const PageHeading(
            title: 'Settings',
            help: 'Change your name, campus and budget here. Type an amount or move the slider. Daily goes in 25 cent steps. Weekly money left sets the daily limit. Tap Save settings when youre done.',
          ),
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
          _budgetControl('Weekly', _weekly, 50000, gap),
          SizedBox(height: gap),
          _budgetControl('Daily', _daily, _dailyLimitCents, gap),
          Text(
            'Daily limit: ${formatMoney(_dailyLimitCents)} from your remaining weekly budget and days left this week.',
            style: theme.textTheme.bodySmall,
          ),
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

  /*
   * we split whats left this week across the days left, today counts too.
   * all this is cents. weekly minus spent, dont go below zero.
   * divide by days left then round down to 25 cents so slider steps fit.
   * user can pick less. this is our budget rule, not the Lunch Lens helper.
   */
  int get _dailyLimitCents {
    final weekly = parseMoneyToCents(_weekly.text) ?? 0;
    final remaining = (weekly - widget.controller.spentThisWeekCents).clamp(
      0,
      weekly,
    );
    final daysLeft = 8 - DateTime.now().weekday;
    return (remaining ~/ daysLeft ~/ 25) * 25;
  }

  Widget _budgetControl(
    String label,
    TextEditingController field,
    int limit,
    double gap,
  ) {
    final isDaily = label == 'Daily';
    final step = isDaily ? 25 : 100;
    final storedCents = parseMoneyToCents(field.text) ?? 0;
    final maxCents = isDaily
        ? limit
        : (storedCents > limit ? storedCents : limit);
    final cents = isDaily
        ? (storedCents.clamp(0, maxCents) ~/ 25) * 25
        : storedCents;
    void update(int value) => setState(() {
      field.text = _moneyInput(isDaily ? value.clamp(0, maxCents) : value);
      if (!isDaily) {
        final daily = parseMoneyToCents(_daily.text) ?? 0;
        _daily.text = _moneyInput(
          (daily.clamp(0, _dailyLimitCents) ~/ 25) * 25,
        );
      }
    });
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: gap / 2),
        Row(
          children: [
            IconButton.outlined(
              onPressed: cents >= step ? () => update(cents - step) : null,
              tooltip:
                  'Reduce $label budget by ${isDaily ? '25 cents' : 'one dollar'}',
              icon: const Icon(AppIcons.removeCircle),
            ),
            Expanded(
              child: TextFormField(
                controller: field,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: Theme.of(context).textTheme.headlineMedium,
                decoration: const InputDecoration(
                  prefixText: r'$ ',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
                validator: (raw) {
                  final value = parseMoneyToCents(raw ?? '');
                  if (value == null) return 'Enter a valid amount.';
                  if (isDaily && value > maxCents) {
                    return 'Max ${formatMoney(maxCents)}';
                  }
                  if (isDaily && value % 25 != 0) return 'Use 0.25 steps.';
                  return null;
                },
              ),
            ),
            IconButton.outlined(
              onPressed: isDaily && cents >= maxCents
                  ? null
                  : () => update(cents + step),
              tooltip:
                  'Increase $label budget by ${isDaily ? '25 cents' : 'one dollar'}',
              icon: const Icon(AppIcons.addCircle),
            ),
          ],
        ),
        // can type it too, daily still needs to fit the week and 25 cent steps.
        // circle sticks out a bit so its easier to grab.
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: gap,
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: gap * .65,
              elevation: 2,
              pressedElevation: 4,
            ),
            activeTrackColor: appPrimary,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: appPrimary,
          ),
          child: Slider(
            value: cents.toDouble(),
            min: 0,
            max: maxCents.toDouble(),
            divisions: isDaily && maxCents > 0 ? maxCents ~/ 25 : null,
            label: formatMoney(cents),
            semanticFormatterCallback: (value) =>
                '$label budget ${formatMoney(value.round())}',
            onChanged: maxCents == 0
                ? null
                : (value) => update(
                    isDaily ? (value / 25).round() * 25 : value.round(),
                  ),
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
    // typed budget or slider, both save the same cents here.
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
        dailyBudgetCents:
            (parseMoneyToCents(_daily.text)!.clamp(0, _dailyLimitCents) ~/ 25) *
            25,
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
    await confirmDeleteMeal(context, widget.controller, item);
  }
}
