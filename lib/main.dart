import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'screens/activity_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/app_widgets.dart';

void main() => runApp(const BudgetBitesApp());

class BudgetBitesApp extends StatefulWidget {
  const BudgetBitesApp({super.key});

  @override
  State<BudgetBitesApp> createState() => _BudgetBitesAppState();
}

class _BudgetBitesAppState extends State<BudgetBitesApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Budget Bites',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'AktivGrotesk',
      scaffoldBackgroundColor: appCanvas,
      colorScheme: ColorScheme.fromSeed(seedColor: appPrimary).copyWith(
        primary: appPrimary,
        onPrimary: appInk,
        primaryContainer: appPrimarySoft,
        onPrimaryContainer: appInk,
        secondary: appIconColor,
        onSecondary: Colors.white,
        secondaryContainer: appAccentSoft,
        onSecondaryContainer: appIconColor,
        tertiary: appIconColor,
        onTertiary: Colors.white,
        surface: Colors.white,
        onSurface: appInk,
        onSurfaceVariant: appMuted,
        outline: appBorder,
        error: appError,
        onError: Colors.white,
      ),
      iconTheme: const IconThemeData(color: appIconColor),
      primaryIconTheme: const IconThemeData(color: appIconColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: appCanvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: appIconColor),
        actionsIconTheme: IconThemeData(color: appIconColor),
        titleTextStyle: TextStyle(
          fontFamily: 'AktivGrotesk',
          color: appInk,
          fontSize: 21,
          fontWeight: appHeadingWeight,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: appPrimary,
          foregroundColor: appInk,
          disabledBackgroundColor: appBorder,
          disabledForegroundColor: appMuted,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appIconColor,
          side: const BorderSide(color: appIconColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appIconColor,
          disabledForegroundColor: appMuted,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: appIconColor,
          disabledForegroundColor: appMuted,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: appPrimarySoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? appIconColor
                : appMuted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? appIconColor
                : appMuted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w400,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: appPrimarySoft,
        checkmarkColor: appIconColor,
        side: const BorderSide(color: appBorder),
        labelStyle: const TextStyle(color: appInk),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? appPrimary : null,
        ),
        checkColor: const WidgetStatePropertyAll(appInk),
        side: const BorderSide(color: appBorder),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? appIconColor : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? appPrimary : null,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? appPrimary : appBorder,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: appPrimary,
        linearTrackColor: appBorder,
        circularTrackColor: appBorder,
      ),
      dividerTheme: const DividerThemeData(color: appBorder),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: appIconColor,
        selectionColor: appPrimarySoft,
        selectionHandleColor: appIconColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        iconColor: appIconColor,
        prefixIconColor: appIconColor,
        suffixIconColor: appIconColor,
        labelStyle: const TextStyle(color: appMuted),
        floatingLabelStyle: const TextStyle(color: appIconColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: appIconColor, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: appBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: appBorder),
        ),
      ),
    ),
    home: AppShell(controller: _controller),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  String? _menuStore;

  void _openMenu(String store) {
    setState(() {
      _selectedIndex = 2;
      _menuStore = store;
    });
  }

  void _openLog() {
    setState(() {
      _selectedIndex = 2;
      _menuStore = null;
    });
  }

  void _openActivity() {
    setState(() {
      _selectedIndex = 1;
      _menuStore = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            if (widget.controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.controller.loadError != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(AppIcons.cloudOff, size: 42),
                      const SizedBox(height: 12),
                      Text(
                        widget.controller.loadError!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: widget.controller.load,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }
            // rebuild the pages with fresh totals after a save or delete.
            final pages = [
              HomeScreen(
                controller: widget.controller,
                onOpenMenu: _openMenu,
                onOpenLog: _openLog,
                onOpenActivity: _openActivity,
              ),
              ActivityScreen(controller: widget.controller),
              LogScreen(
                controller: widget.controller,
                initialStore: _menuStore,
                onStoreConsumed: () => _menuStore = null,
              ),
              HistoryScreen(controller: widget.controller),
              SettingsScreen(controller: widget.controller),
            ];
            return IndexedStack(index: _selectedIndex, children: pages);
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(AppIcons.home),
            selectedIcon: Icon(AppIcons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.activity),
            selectedIcon: Icon(AppIcons.activity),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.addCircle),
            selectedIcon: Icon(AppIcons.addCircle),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.history),
            selectedIcon: Icon(AppIcons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.settings),
            selectedIcon: Icon(AppIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
