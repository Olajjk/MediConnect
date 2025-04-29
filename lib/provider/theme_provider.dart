import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData themeData = lightMode;
  AdaptiveThemeMode themeMode = AdaptiveThemeMode.light;
  Color get tabLabelColor =>
      themeMode == AdaptiveThemeMode.dark ? Colors.white : Colors.black;

  Color get tabUnselectedLabelColor =>
      themeMode == AdaptiveThemeMode.dark
          ? Colors.grey[400]!
          : Colors.grey[600]!;

  Color get tabIndicatorColor =>
      themeMode == AdaptiveThemeMode.dark ? Colors.amber : Colors.green;

  void toggleTheme(BuildContext context) {
    final adaptiveTheme = AdaptiveTheme.of(context);

    if (adaptiveTheme.mode.isDark) {
      adaptiveTheme.setLight();
      themeData = lightMode;
      themeMode = AdaptiveThemeMode.light;
    } else {
      adaptiveTheme.setDark();
      themeData = darkMode;
      themeMode = AdaptiveThemeMode.dark;
    }
    notifyListeners();
  }
}
