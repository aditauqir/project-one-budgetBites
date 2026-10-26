import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_controller.dart';
import 'meal_detail_screen.dart';
import '../widgets/food_editor.dart';
import '../data/azalea_menu.dart';
import '../data/blossom_tree.dart';
import '../data/brickstone_menu.dart';
import '../models.dart';
import '../widgets/app_widgets.dart';

const _homePrimary = appPrimary;
const _homeIconColor = appIconColor;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onOpenMenu,
    required this.onOpenLog,
    required this.onOpenSettings,
  });

  final AppController controller;
  final ValueChanged<String> onOpenMenu;
  final VoidCallback onOpenLog;
  final VoidCallback onOpenSettings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 'All' shows the whole catalog. Any other value is one cuisine in the
  // saved meals, so the list and the chips always agree.
  String _cuisine = 'All';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final onOpenMenu = widget.onOpenMenu;
    final onOpenLog = widget.onOpenLog;
    final onOpenSettings = widget.onOpenSettings;
    final cuisines = <String>{
      for (final meal in controller.foodItems) meal.category,
    }.toList()..sort();
    // Fall back to All if the chosen cuisine disappears (last meal deleted).
    final selectedCuisine = cuisines.contains(_cuisine) ? _cuisine : 'All';
    final cuisineCounts = <String, int>{};
    for (final meal in controller.foodItems) {
      cuisineCounts.update(meal.category, (count) => count + 1, ifAbsent: () => 1);
    }
    final visibleMeals = selectedCuisine == 'All'
        ? controller.foodItems
        : controller.foodItems
              .where((meal) => meal.category == selectedCuisine)
              .toList();
    // big amount is for today, weekly money stays under the bar.
    final spent = controller.spentTodayCents;
    final budget = controller.settings.dailyBudgetCents;
    final remaining = budget - spent;
    final ratio = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final places = controller.settings.favoritePlaces;
    final university =
        controller.settings.university.trim().toLowerCase() ==
            'georgia state university'
        ? 'GaState University'
        : controller.settings.university.trim();
    final location =
        controller.settings.location.toLowerCase().contains('atlanta')
        ? 'Atlanta Campus'
        : controller.settings.location.trim();
    final campusStyle = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(color: appMuted, fontSize: 14, fontWeight: FontWeight.w400);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Text(
                'Hello ${controller.settings.name}',
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: appInk,
                  letterSpacing: -1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    university,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: campusStyle,
                  ),
                  Text(
                    location,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: campusStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          _budgetDisplay(remaining),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: appAmountWeight,
            color: remaining < 0 ? appError : appInk,
            letterSpacing: -2,
          ),
        ),
        Text(
          'of ${_budgetDisplay(budget)} today',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: appInk, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 14,
            backgroundColor: appBorder,
            color: spent > budget
                ? appError
                : spent >= budget * .8
                ? appWarning
                : _homePrimary,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: (MediaQuery.sizeOf(context).width * .02).clamp(6.0, 12.0),
          ),
          child: Text(
            '${formatMoney(controller.remainingWeekCents)} / ${formatMoney(controller.settings.weeklyBudgetCents)} weekly budget left',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: appMuted),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: FilledButton.icon(
            onPressed: onOpenLog,
            icon: const Icon(AppIcons.add, size: 22, color: _homeIconColor),
            label: const Text('Log purchase'),
            style: FilledButton.styleFrom(
              backgroundColor: _homePrimary,
              foregroundColor: appInk,
              minimumSize: const Size(0, 56),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        SizedBox(
          height: (MediaQuery.sizeOf(context).width * .05).clamp(16.0, 28.0),
        ),
        // saved meals open their details, then the user can plan or log one.
        SectionHeading(
          'Your meals',
          trailing: TextButton.icon(
            onPressed: () => showFoodEditor(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Add meal'),
          ),
        ),
        if (controller.foodItems.isEmpty)
          const Text('Save a meal to plan it or log a purchase.')
        else ...[
          // Cuisine filter for the catalog. Counts come from the saved meals,
          // so an empty cuisine never appears as a dead chip.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text('All (${controller.foodItems.length})'),
                selected: selectedCuisine == 'All',
                onSelected: (_) => setState(() => _cuisine = 'All'),
              ),
              for (final cuisine in cuisines)
                ChoiceChip(
                  label: Text('$cuisine (${cuisineCounts[cuisine]})'),
                  selected: selectedCuisine == cuisine,
                  onSelected: (_) => setState(() => _cuisine = cuisine),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (visibleMeals.isEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'No meals in $selectedCuisine yet.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: appMuted),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _cuisine = 'All'),
                  child: const Text('Show all meals'),
                ),
              ],
            )
          else
            ...visibleMeals.map(
              (meal) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(meal.name),
                subtitle: Text(
                  '${meal.store} · ${meal.category} · Estimated ${formatMoney(meal.lastPriceCents)}',
                ),
                // Visible menu is the button alternative to long-press.
                trailing: PopupMenuButton<String>(
                  tooltip: 'Meal options',
                  onSelected: (value) {
                    if (value == 'edit') {
                      showFoodEditor(context, controller, item: meal);
                    } else {
                      confirmDeleteMeal(context, controller, meal);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit meal')),
                    PopupMenuItem(value: 'delete', child: Text('Delete meal')),
                  ],
                ),
                onTap: () => showMealDetails(context, controller, meal),
                onLongPress: () =>
                    showFoodEditor(context, controller, item: meal),
              ),
            ),
        ],
        const SizedBox(height: 34),
        Row(
          children: [
            Expanded(
              child: Text(
                'Today',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: appHeadingWeight, color: appInk),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/bowl-food.svg',
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(
                _homeIconColor,
                BlendMode.srcIn,
              ),
              semanticsLabel: 'Bowl of food',
            ),
          ],
        ),
        const SizedBox(height: 10),
        // weekly balance is already up top, keep this part about today.
        _DailyGlance(
          remaining: controller.remainingTodayCents,
          allowance: controller.settings.dailyBudgetCents,
          onAdjust: onOpenSettings,
        ),
        const SizedBox(height: 20),
        SectionHeading(
          'Places',
          fontWeight: appHeadingWeight,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/storefront.svg',
                width: 26,
                height: 26,
                colorFilter: const ColorFilter.mode(
                  _homeIconColor,
                  BlendMode.srcIn,
                ),
                semanticsLabel: 'Storefront',
              ),
              const SizedBox(width: 8),
              Text(
                '${places.length} places',
                style: const TextStyle(color: appMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (places.isEmpty)
          AppCard(
            child: EmptyMessage(
              title: 'No favorite places yet',
              detail: 'Add a place in Settings, then see its saved items here.',
            ),
          )
        else
          SizedBox(
            height: 292,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final place = places[index];
                final isSaxbys = place.toLowerCase().contains('saxbys');
                final isAzalea =
                    place.toLowerCase().contains('azalea') ||
                    place.toLowerCase() == 'supermarket';
                final isBlossomTree = place.toLowerCase().contains('blossom');
                final isBrickstone = place.toLowerCase().contains('brickstone');
                final displayPlace = isAzalea
                    ? 'Azalea Fresh Market'
                    : isBlossomTree
                    ? 'Blossom Tree'
                    : isBrickstone
                    ? 'BrickStone Cafe & Restaurant'
                    : place;
                final category = _placeCategory(place);
                final items = controller.foodItems
                    .where(
                      (item) =>
                          item.store.toLowerCase() == place.toLowerCase() ||
                          (isAzalea &&
                              item.store.toLowerCase() ==
                                  'azalea fresh market'),
                    )
                    .toList();
                return SizedBox(
                  width: 320,
                  child: AppCard(
                    padding: const EdgeInsets.all(10),
                    borderColor: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onOpenMenu(displayPlace),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 124,
                                  child: isSaxbys
                                      ? Semantics(
                                          image: true,
                                          label:
                                              'Saxbys cafe photo placeholder',
                                          child: Image.asset(
                                            'assets/images/saxbys-placeholder.png',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : isAzalea
                                      ? Semantics(
                                          image: true,
                                          label:
                                              'Azalea Fresh Market storefront',
                                          child: Image.asset(
                                            'assets/images/azalea-fresh-market.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : isBlossomTree
                                      ? Semantics(
                                          image: true,
                                          label: 'Blossom Tree Korean food',
                                          child: Image.asset(
                                            'assets/images/blossom-tree.png',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : isBrickstone
                                      ? Semantics(
                                          image: true,
                                          label: 'BrickStone Cafe storefront',
                                          child: Image.asset(
                                            'assets/images/brickstone-cafe.png',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          color: const Color(0xFFF4F2EF),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            _placeIcon(category),
                                            size: 42,
                                            color: _homeIconColor,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayPlace,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: appInk,
                                      ),
                                    ),
                                  ),
                                  if (isSaxbys ||
                                      isAzalea ||
                                      isBlossomTree) ...[
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(
                                      'assets/icons/clock.svg',
                                      width: 18,
                                      height: 18,
                                      colorFilter: const ColorFilter.mode(
                                        _homeIconColor,
                                        BlendMode.srcIn,
                                      ),
                                      semanticsLabel: 'Today’s venue hours',
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isSaxbys
                                          ? _saxbysHoursStatus(DateTime.now())
                                          : isAzalea
                                          ? _azaleaHoursStatus(DateTime.now())
                                          : _blossomTreeHoursStatus(
                                              DateTime.now(),
                                            ),
                                      style: const TextStyle(
                                        color: appMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAzalea
                                    ? 'Groceries · prepared food · catering'
                                    : isBlossomTree
                                    ? 'Korean bowls · tacos · rice dishes'
                                    : isBrickstone
                                    ? 'Pizza · pasta · sandwiches'
                                    : items.isEmpty
                                    ? 'View menu'
                                    : '${items.length} saved meals',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: appMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _PlaceCategoryBadge(category: category),
                            const Spacer(),
                            if (isAzalea || isBlossomTree || isBrickstone)
                              TextButton.icon(
                                onPressed: () => _openWebsite(
                                  context,
                                  Uri.parse(
                                    isAzalea
                                        ? azaleaWebsiteUrl
                                        : isBlossomTree
                                        ? blossomTreeMenuUrl
                                        : brickstoneCafeMenuUrl,
                                  ),
                                ),
                                icon: const Icon(AppIcons.store, size: 16),
                                label: const Text('Open menu'),
                                style: TextButton.styleFrom(
                                  foregroundColor: _homeIconColor,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                ),
                              )
                            else if (!isSaxbys)
                              Text(
                                items.isEmpty
                                    ? 'Saved menu'
                                    : '${items.length} saved',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: appMuted,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        if (isSaxbys ||
                            isAzalea ||
                            isBlossomTree ||
                            isBrickstone) ...[
                          const SizedBox(height: 2),
                          InkWell(
                            onTap: () => _openPlaceLocation(
                              context,
                              isAzalea
                                  ? azaleaAddress
                                  : isBlossomTree
                                  ? blossomTreeAddress
                                  : isBrickstone
                                  ? brickstoneCafeAddress
                                  : saxbyAddress,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  const Icon(
                                    AppIcons.mapPin,
                                    size: 17,
                                    color: _homeIconColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      isAzalea
                                          ? azaleaAddress
                                          : isBlossomTree
                                          ? blossomTreeAddress
                                          : isBrickstone
                                          ? brickstoneCafeAddress
                                          : saxbyAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: appMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _PlaceCategoryBadge extends StatelessWidget {
  const _PlaceCategoryBadge({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: appAccentSoft,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      category,
      style: const TextStyle(
        color: _homeIconColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

String _placeCategory(String place) {
  final name = place.toLowerCase();
  if (name.contains('market') ||
      name.contains('grocery') ||
      name.contains('supermarket')) {
    return 'Supermarket';
  }
  if (name.contains('cafe') ||
      name.contains('coffee') ||
      name.contains('saxbys')) {
    return 'Cafe';
  }
  return 'Restaurant';
}

IconData _placeIcon(String category) => switch (category) {
  'Cafe' => AppIcons.coffee,
  'Supermarket' => AppIcons.store,
  _ => AppIcons.restaurant,
};

String _saxbysHoursStatus(DateTime now) {
  late final int opensAt;
  late final int closesAt;
  if (now.weekday <= DateTime.thursday) {
    opensAt = 7 * 60;
    closesAt = 24 * 60;
  } else if (now.weekday == DateTime.friday ||
      now.weekday == DateTime.saturday) {
    opensAt = now.weekday == DateTime.friday ? 7 * 60 : 12 * 60;
    closesAt = 18 * 60;
  } else {
    opensAt = 12 * 60;
    closesAt = 23 * 60;
  }

  final minutesNow = now.hour * 60 + now.minute;
  if (minutesNow < opensAt) return 'Opens ${_formatClock(opensAt)}';
  if (minutesNow < closesAt) return 'Closes ${_formatClock(closesAt)}';
  return 'Closed today';
}

const saxbyAddress = '100 Decatur St SE, Atlanta, GA 30303';

String _azaleaHoursStatus(DateTime now) {
  final minutesNow = now.hour * 60 + now.minute;
  if (minutesNow < 7 * 60) return 'Opens 7 AM';
  if (minutesNow < 22 * 60) return 'Closes 10 PM';
  return 'Closed today';
}

String _blossomTreeHoursStatus(DateTime now) {
  if (now.weekday > DateTime.friday) return 'Closed today';
  const opensAt = 10 * 60 + 30;
  const closesAt = 20 * 60;
  final minutesNow = now.hour * 60 + now.minute;
  if (minutesNow < opensAt) return 'Opens 10:30 AM';
  if (minutesNow < closesAt) return 'Closes 8 PM';
  return 'Closed today';
}

String _formatClock(int minutesAfterMidnight) {
  final hour24 = (minutesAfterMidnight ~/ 60) % 24;
  final minute = minutesAfterMidnight % 60;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final period = hour24 < 12 ? 'AM' : 'PM';
  return minute == 0
      ? '$hour12 $period'
      : '$hour12:${minute.toString().padLeft(2, '0')} $period';
}

Future<void> _openPlaceLocation(BuildContext context, String address) async {
  final destination = switch (defaultTargetPlatform) {
    TargetPlatform.android => Uri(
      scheme: 'geo',
      path: '0,0',
      queryParameters: {'q': address},
    ),
    TargetPlatform.iOS => Uri.https('maps.apple.com', '/', {'q': address}),
    _ => Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': address,
    }),
  };

  try {
    final opened = await launchUrl(
      destination,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps on this device.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps on this device.')),
      );
    }
  }
}

Future<void> _openWebsite(BuildContext context, Uri uri) async {
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this website.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this website.')),
      );
    }
  }
}

class _DailyGlance extends StatelessWidget {
  const _DailyGlance({
    required this.remaining,
    required this.allowance,
    required this.onAdjust,
  });

  final int remaining;
  final int allowance;
  final VoidCallback onAdjust;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isOver = remaining < 0;
    final amount = formatMoney(remaining.abs());
    final amountColor = isOver ? appError : appInk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text.rich(
            TextSpan(
              children: [
                // just the amount and what it means, no long sentence.
                TextSpan(
                  text: amount,
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(text: isOver ? ' over today’s budget' : ' left today'),
              ],
            ),
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: colors.onSurface, height: 1.3),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            children: [
              Text(
                'Daily budget ${formatMoney(allowance)}',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              TextButton(
                onPressed: onAdjust,
                style: TextButton.styleFrom(
                  foregroundColor: _homeIconColor,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change budget',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: _homeIconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _budgetDisplay(int cents) {
  final value = formatMoney(cents);
  return cents % 100 == 0 ? value.substring(0, value.length - 3) : value;
}
