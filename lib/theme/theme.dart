import 'package:flutter/material.dart';

// Définition des couleurs
const Color _primaryLight = Color(0xFFFFFFFF);
const Color _primaryDark = Color(0xFF1E1E1E);

const Color _secondaryLight = Color(0xFFFAFAFA);
const Color _secondaryDark = Color(0xFF2D2D2D);

const Color _accentLight = Color(0xFF2D5D42);
const Color _accentDark = Color(0xFF2D5D42);

const Color _textPrimaryLight = Color(0xFF333333);
const Color _textPrimaryDark = Color(0xFFFFFFFF);

const Color _textSecondaryLight = Color.fromARGB(255, 0, 1, 1);
const Color _textSecondaryDark = Color(0xFFFFFFFF);

// Définition des thèmes
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: _primaryLight,
    secondary: _accentLight,
    onPrimary: _textPrimaryLight,
    onSecondary: Colors.white,
    surface: _primaryLight,
    onSurface: _primaryDark,
    onSurfaceVariant: _textSecondaryLight,
  ),
  scaffoldBackgroundColor: _secondaryLight,

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _primaryDark, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(cursorColor: _primaryDark),

  tabBarTheme: TabBarTheme(
    labelColor: Colors.black, // Couleur texte onglet sélectionné (light)
    unselectedLabelColor:
        Colors.grey[600], // Couleur texte onglet non sélectionné (light)
    indicator: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.green, // Couleur indicateur (light)
          width: 2,
        ),
      ),
    ),
  ),

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: _primaryLight,
    foregroundColor: Colors.black,
    elevation: 0,
    iconTheme: IconThemeData(color: _textPrimaryLight),
    titleTextStyle: TextStyle(
      color: _textPrimaryLight,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  // Bottom Navigation Bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: _primaryLight,
    selectedItemColor: _accentLight,
    unselectedItemColor: _textSecondaryLight,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  // TextTheme pour le mode clair
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: _textPrimaryLight),
    bodyMedium: TextStyle(color: _textSecondaryLight),
    displayLarge: TextStyle(color: _textPrimaryLight),
    displayMedium: TextStyle(color: _textSecondaryLight),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: _secondaryDark,
    secondary: _accentDark,
    onPrimary: _textPrimaryDark,
    onSecondary: Colors.white,
    surface: _secondaryDark,
    onSurface: _textPrimaryDark,
    onSurfaceVariant: _textSecondaryDark,
  ),
  scaffoldBackgroundColor: _primaryDark,

  tabBarTheme: TabBarTheme(
    labelColor: Colors.white, // Couleur texte onglet sélectionné (light)
    unselectedLabelColor:
        Colors.grey[600], // Couleur texte onglet non sélectionné (light)
    indicator: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(0xFF2D5D42), // Couleur indicateur (light)
          width: 2,
        ),
      ),
    ),
  ),

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: _secondaryDark,
    elevation: 0,
    iconTheme: IconThemeData(color: _textPrimaryDark),
    titleTextStyle: TextStyle(
      color: _textPrimaryDark,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),

  // Bottom Navigation Bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: _secondaryDark,
    selectedItemColor: _accentDark,
    unselectedItemColor: _textSecondaryDark,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _primaryLight, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(cursorColor: _primaryLight),

  // TextTheme pour le mode sombre
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: _textPrimaryDark),
    bodyMedium: TextStyle(color: _textSecondaryDark),
    displayLarge: TextStyle(color: _textPrimaryDark),
    displayMedium: TextStyle(color: _textSecondaryDark),
  ),
);
