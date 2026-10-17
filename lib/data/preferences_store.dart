import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class PreferencesStore {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<AppSettings> load() async {
    final savedPlaces = await _preferences.getStringList('places.favorites');
    final normalizedPlaces = savedPlaces
        ?.map(
          (place) => place.toLowerCase() == 'supermarket'
              ? 'Azalea Fresh Market'
              : place,
        )
        .toSet()
        .toList();
    final oldDefaultNames = normalizedPlaces
        ?.map((place) => place.toLowerCase())
        .toSet();
    final isPreviousDefault =
        oldDefaultNames != null &&
        (oldDefaultNames.length == 2 &&
                oldDefaultNames.contains('saxbys') &&
                oldDefaultNames.contains('azalea fresh market') ||
            oldDefaultNames.length == 3 &&
                oldDefaultNames.containsAll({
                  'saxbys',
                  'azalea fresh market',
                  'blossom tree',
                }));
    final favoritePlaces = savedPlaces == null || isPreviousDefault
        ? const [
            'Saxbys',
            'Azalea Fresh Market',
            'Blossom Tree',
            'BrickStone Cafe & Restaurant',
          ]
        : normalizedPlaces!;
    return AppSettings(
      name: await _preferences.getString('profile.name') ?? 'Adi',
      university:
          await _preferences.getString('profile.university') ??
          'Georgia State University',
      weeklyBudgetCents:
          await _preferences.getInt('budget.weeklyCents') ?? 10000,
      dailyBudgetCents: await _preferences.getInt('budget.dailyCents') ?? 2000,
      calorieGoal: await _preferences.getInt('nutrition.calories'),
      carbGoalGrams: await _preferences.getInt('nutrition.carbs'),
      proteinGoalGrams: await _preferences.getInt('nutrition.protein'),
      fatGoalGrams: await _preferences.getInt('nutrition.fat'),
      favoritePlaces: favoritePlaces,
      location:
          await _preferences.getString('profile.location') ??
          'Downtown Atlanta campus',
      notificationsEnabled:
          await _preferences.getBool('notifications.enabled') ?? false,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _preferences.setString('profile.name', settings.name);
    await _preferences.setString('profile.university', settings.university);
    await _preferences.setInt('budget.weeklyCents', settings.weeklyBudgetCents);
    await _preferences.setInt('budget.dailyCents', settings.dailyBudgetCents);
    await _saveOptionalInt('nutrition.calories', settings.calorieGoal);
    await _saveOptionalInt('nutrition.carbs', settings.carbGoalGrams);
    await _saveOptionalInt('nutrition.protein', settings.proteinGoalGrams);
    await _saveOptionalInt('nutrition.fat', settings.fatGoalGrams);
    await _preferences.setStringList(
      'places.favorites',
      settings.favoritePlaces,
    );
    await _preferences.setString('profile.location', settings.location);
    await _preferences.setBool(
      'notifications.enabled',
      settings.notificationsEnabled,
    );
  }

  Future<void> _saveOptionalInt(String key, int? value) async {
    if (value == null) {
      await _preferences.remove(key);
    } else {
      await _preferences.setInt(key, value);
    }
  }
}
