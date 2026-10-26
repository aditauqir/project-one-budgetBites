import 'package:flutter/material.dart';

import '../widgets/page_help.dart';

import 'package:url_launcher/url_launcher.dart';

import '../app_controller.dart';
import '../data/azalea_menu.dart';
import '../data/blossom_tree.dart';
import '../data/brickstone_menu.dart';
import '../models.dart';
import '../widgets/app_widgets.dart';
import '../widgets/food_editor.dart';
import '../widgets/purchase_editor.dart';
import 'meal_detail_screen.dart';

enum _LogPath { existing, newItem, menu }

class LogScreen extends StatefulWidget {
  const LogScreen({
    super.key,
    required this.controller,
    this.initialStore,
    this.onStoreConsumed,
  });
  final AppController controller;
  final String? initialStore;
  final VoidCallback? onStoreConsumed;

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  _LogPath _path = _LogPath.existing;
  String? _store;

  @override
  void initState() {
    super.initState();
    if (widget.initialStore != null) {
      _path = _LogPath.menu;
      _store = widget.initialStore;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onStoreConsumed?.call(),
      );
    }
  }

  @override
  void didUpdateWidget(covariant LogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStore != widget.initialStore &&
        widget.initialStore != null) {
      _path = _LogPath.menu;
      _store = widget.initialStore;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onStoreConsumed?.call(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.settings;
    final favorites = settings.favoritePlaces;
    final storeOptions = <String>{
      ...favorites,
      ...widget.controller.foodItems.map((item) => item.store),
      'Other',
    }.where((value) => value.trim().isNotEmpty).toList();
    _store ??= favorites.isNotEmpty ? favorites.first : 'Other';
    final restaurantMenu = _restaurantMenu(_store!);
    final restaurantSections = _restaurantSections(_store!);
    final restaurantName = _restaurantName(_store!);
    final restaurantMenuUrl = _restaurantMenuUrl(_store!);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        const PageHeading(
          title: 'Meals',
          help: 'Pick a saved meal, add a new one, or browse a place menu. Open a meal to plan it. If you already bought it, log what you paid.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PathButton(
                icon: AppIcons.history,
                label: 'Existing',
                selected: _path == _LogPath.existing,
                onTap: () => setState(() => _path = _LogPath.existing),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PathButton(
                icon: AppIcons.editNote,
                label: 'New item',
                selected: _path == _LogPath.newItem,
                onTap: () => setState(() => _path = _LogPath.newItem),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PathButton(
                icon: AppIcons.restaurant,
                label: 'Menu',
                selected: _path == _LogPath.menu,
                onTap: () => setState(() => _path = _LogPath.menu),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_path == _LogPath.existing) ...[
          SectionHeading(
            'Saved meals',
            trailing: IconButton(
              onPressed: () => showFoodEditor(context, widget.controller),
              icon: const Icon(AppIcons.add),
              tooltip: 'Add saved item',
            ),
          ),
          const SizedBox(height: 8),
          if (widget.controller.foodItems.isEmpty)
            AppCard(
              child: EmptyMessage(
                title: 'No saved items yet',
                detail: 'Use New item to log one and save it for next time.',
              ),
            )
          else
            ...widget.controller.foodItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CatalogItem(
                  item: item,
                  onTap: () =>
                      showMealDetails(context, widget.controller, item),
                  showPlus: false,
                  onDelete: () => _deleteFoodItem(context, item),
                ),
              ),
            ),
        ] else if (_path == _LogPath.newItem) ...[
          AppCard(
            borderColor: appBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(AppIcons.note, color: appIconColor, size: 28),
                const SizedBox(height: 8),
                const Text(
                  'New meal',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: appEmphasisWeight,
                    color: appInk,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter what you paid, the item, store and an optional note. Category is suggested from the item name.',
                  style: TextStyle(color: appMuted),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => showPurchaseEditor(
                      context,
                      widget.controller,
                    ),
                    icon: const Icon(AppIcons.add),
                    label: const Text('Enter new purchase'),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          SectionHeading('Places'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: storeOptions
                .map(
                  (store) => ChoiceChip(
                    label: Text(store),
                    selected: _store == store,
                    onSelected: (_) => setState(() => _store = store),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          if (_isAzaleaStore(_store!)) ...[
            SectionHeading(
              'Catering menu · ${azaleaCateringMenu.length} items',
            ),
            const SizedBox(height: 6),
            const Text(
              'Prices and serving sizes may vary. Check the final price before buying.',
              style: TextStyle(color: appMuted, fontSize: 12),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openExternalLink(
                  context,
                  Uri.parse(azaleaCateringMenuUrl),
                ),
                icon: const Icon(AppIcons.store, size: 17),
                label: const Text('Open current Otter menu'),
              ),
            ),
            for (final section in azaleaCateringSections) ...[
              SectionHeading(section),
              const SizedBox(height: 8),
              ...azaleaCateringMenu
                  .where((item) => item.section == section)
                  .map((item) {
                    final remaining = widget.controller.remainingTodayCents;
                    final budgetPrice = item.minimumOrderEstimateCents;
                    final color = _budgetColor(
                      item.priceMaxCents ?? budgetPrice,
                      remaining,
                    );
                    final foodItem = FoodItem(
                      name: item.name,
                      store: 'Azalea Fresh Market',
                      category: inferCategory(item.name),
                      lastPriceCents: budgetPrice,
                      createdAt: DateTime.now(),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _MenuListingCard(
                        item: item,
                        priceColor: color,
                        budgetLabel: _menuBudgetLabel(
                          item,
                          budgetPrice,
                          remaining,
                        ),
                        displayPrice: _menuPriceLabel(item, budgetPrice),
                        // show details first so this does not count as spending by accident.
                        onAdd: () => showMealDetails(
                          context,
                          widget.controller,
                          foodItem,
                          servings: item.minimumQuantity,
                          note: item.description.isEmpty
                              ? 'Catering order. Check the final total.'
                              : item.description,
                        ),
                      ),
                    );
                  }),
            ],
          ] else if (restaurantMenu.isNotEmpty) ...[
            SectionHeading(
              '$restaurantName menu · ${restaurantMenu.length} items',
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    _openExternalLink(context, Uri.parse(restaurantMenuUrl)),
                icon: const Icon(AppIcons.store, size: 17),
                label: Text('Open menu for $restaurantName'),
              ),
            ),
            for (final section in restaurantSections) ...[
              SectionHeading(section),
              const SizedBox(height: 8),
              ...restaurantMenu.where((item) => item.section == section).map((
                item,
              ) {
                final remaining = widget.controller.remainingTodayCents;
                final budgetPrice = item.minimumOrderEstimateCents;
                final color = _budgetColor(
                  item.priceMaxCents ?? budgetPrice,
                  remaining,
                );
                final foodItem = FoodItem(
                  name: item.name,
                  store: restaurantName,
                  category: inferCategory(item.name),
                  lastPriceCents: budgetPrice,
                  createdAt: DateTime.now(),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MenuListingCard(
                    item: item,
                    priceColor: color,
                    budgetLabel: _budgetLabel(budgetPrice, remaining),
                    displayPrice: _menuPriceLabel(item, budgetPrice),
                    // show details first so this does not count as spending by accident.
                    onAdd: () => showMealDetails(
                      context,
                      widget.controller,
                      foodItem,
                      note: 'Check the final price before buying.',
                    ),
                  ),
                );
              }),
            ],
          ] else ...[
            SectionHeading(
              'Saved menu · $_store',
              trailing: IconButton(
                onPressed: () => showFoodEditor(context, widget.controller),
                icon: const Icon(AppIcons.add),
                tooltip: 'Add item to saved menu',
              ),
            ),
            const SizedBox(height: 6),
            ..._menuItems(widget.controller.foodItems, _store!).map((item) {
              final remaining = widget.controller.remainingTodayCents;
              final color = _budgetColor(item.lastPriceCents, remaining);
              final label = _budgetLabel(item.lastPriceCents, remaining);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CatalogItem(
                  item: item,
                  color: color,
                  budgetLabel: label,
                  showPlus: true,
                  onTap: () =>
                      showMealDetails(context, widget.controller, item),
                  onDelete: () => _deleteFoodItem(context, item),
                ),
              );
            }),
            if (_menuItems(widget.controller.foodItems, _store!).isEmpty)
              AppCard(
                child: EmptyMessage(
                  title: 'No saved menu items here yet',
                  detail:
                      'Add a saved item and choose this place in its details.',
                  icon: AppIcons.restaurant,
                ),
              ),
          ],
        ],
      ],
    );
  }

  List<FoodItem> _menuItems(List<FoodItem> items, String store) => items
      .where((item) => item.store.toLowerCase() == store.toLowerCase())
      .toList();

  List<MenuListing> _restaurantMenu(String store) {
    if (_isBlossomTreeStore(store)) return blossomTreeMenu;
    if (_isBrickstoneStore(store)) return brickstoneCafeMenu;
    return const [];
  }

  List<String> _restaurantSections(String store) {
    if (_isBlossomTreeStore(store)) return blossomTreeSections;
    if (_isBrickstoneStore(store)) return brickstoneCafeSections;
    return const [];
  }

  String _restaurantName(String store) {
    if (_isBlossomTreeStore(store)) return 'Blossom Tree';
    if (_isBrickstoneStore(store)) return 'BrickStone Cafe & Restaurant';
    return store;
  }

  String _restaurantMenuUrl(String store) {
    if (_isBlossomTreeStore(store)) return blossomTreeMenuUrl;
    if (_isBrickstoneStore(store)) return brickstoneCafeMenuUrl;
    return '';
  }

  Color _budgetColor(int price, int remaining) {
    if (remaining <= 0 || price >= remaining) return appError;
    if (price >= remaining * .8) return appWarning;
    return appSuccess;
  }

  String _budgetLabel(int price, int remaining) {
    if (remaining <= 0 || price >= remaining) {
      return 'At or over daily budget left';
    }
    if (price >= remaining * .8) return 'Close to daily budget left';
    return 'Within today\'s budget left';
  }

  String _menuBudgetLabel(MenuListing item, int budgetPrice, int remaining) {
    if (item.minimumQuantity > 1) {
      if (remaining <= 0 || budgetPrice >= remaining) {
        return 'Minimum order is at or over today\'s budget';
      }
      if (budgetPrice >= remaining * .8) {
        return 'Minimum order is close to today\'s budget';
      }
      return 'Minimum order fits today\'s budget';
    }
    return _budgetLabel(budgetPrice, remaining);
  }

  String _menuPriceLabel(MenuListing item, int budgetPrice) {
    if (item.priceMaxCents != null) {
      return '${formatMoney(item.priceCents)}–${formatMoney(item.priceMaxCents!)}';
    }
    if (item.minimumQuantity > 1) {
      return '${formatMoney(budgetPrice)} min';
    }
    final unit = switch (item.priceUnit) {
      'per person' => ' / person',
      'package' => ' package',
      'each' => ' each',
      'item' => '',
      _ => ' listed',
    };
    return '${formatMoney(item.priceCents)}$unit';
  }

  Future<void> _deleteFoodItem(BuildContext context, FoodItem item) async {
    await confirmDeleteMeal(context, widget.controller, item);
  }
}

class _PathButton extends StatelessWidget {
  const _PathButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: selected ? appPrimarySoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? appPrimary : appBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: selected ? appIconColor : appMuted),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? appIconColor : appInk,
            ),
          ),
        ],
      ),
    ),
  );
}

bool _isAzaleaStore(String store) =>
    store.toLowerCase().contains('azalea') ||
    store.toLowerCase() == 'supermarket';

bool _isBlossomTreeStore(String store) =>
    store.toLowerCase().contains('blossom');

bool _isBrickstoneStore(String store) =>
    store.toLowerCase().contains('brickstone');

Future<void> _openExternalLink(BuildContext context, Uri uri) async {
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the menu website.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the menu website.')),
      );
    }
  }
}

class _CatalogItem extends StatelessWidget {
  const _CatalogItem({
    required this.item,
    required this.onTap,
    required this.showPlus,
    this.color,
    this.budgetLabel,
    this.onDelete,
  });
  final FoodItem item;
  final VoidCallback onTap;
  final bool showPlus;
  final Color? color;
  final String? budgetLabel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        Icon(
          item.category == 'Drinks'
              ? AppIcons.coffee
              : item.category == 'Food'
              ? AppIcons.food
              : AppIcons.tag,
          color: color ?? appIconColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: onTap,
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
                  '${item.store} · ${item.category}',
                  style: const TextStyle(color: appMuted, fontSize: 12),
                ),
                if (budgetLabel != null)
                  Text(
                    budgetLabel!,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Text(
          formatMoney(item.lastPriceCents),
          style: const TextStyle(fontWeight: appEmphasisWeight),
        ),
        if (showPlus)
          IconButton(
            onPressed: onTap,
            icon: Icon(AppIcons.addCircle, color: color),
            tooltip: 'Log this item',
          ),
        if (onDelete != null)
          PopupMenuButton<String>(
            tooltip: 'Saved item options',
            onSelected: (value) {
              if (value == 'delete') onDelete!();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete saved item')),
            ],
          ),
      ],
    ),
  );
}

class _MenuListingCard extends StatelessWidget {
  const _MenuListingCard({
    required this.item,
    required this.priceColor,
    required this.budgetLabel,
    required this.displayPrice,
    required this.onAdd,
  });

  final MenuListing item;
  final Color priceColor;
  final String budgetLabel;
  final String displayPrice;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          item.section == 'Beverages' ? AppIcons.coffee : AppIcons.food,
          size: 21,
          color: priceColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: appInk,
                ),
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(color: appMuted, fontSize: 12),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                budgetLabel,
                style: TextStyle(
                  color: priceColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              displayPrice,
              style: TextStyle(
                color: priceColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            IconButton(
              onPressed: onAdd,
              tooltip: 'View meal',
              visualDensity: VisualDensity.compact,
              icon: Icon(AppIcons.addCircle, color: priceColor),
            ),
          ],
        ),
      ],
    ),
  );
}
