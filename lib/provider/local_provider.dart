import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = Locale('fr');
  final Map<String, String> _translations = {};
  final GoogleTranslator translator = GoogleTranslator();
  Timer? _debounce;
  final Map<String, String> _translationCache = {};
  bool _isLoading = true;

  Locale get locale => _locale;
  Map<String, String> get translations => _translations;
  bool get isLoading => _isLoading;

  LocaleProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadSavedLanguage();
    await _loadCachedTranslations();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('langueCode');
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> _loadCachedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTranslations = prefs.getString(
      'cachedTranslations_${_locale.languageCode}',
    );
    if (cachedTranslations != null) {
      try {
        _translationCache.addAll(
          Map<String, String>.from(json.decode(cachedTranslations)),
        );
        _translations.addAll(_translationCache);
      } catch (e) {
        print("Erreur de décodage du cache: $e");
      }
    }
  }

  Future<void> _saveCachedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cachedTranslations_${_locale.languageCode}',
      json.encode(_translationCache),
    );
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode != newLocale.languageCode) {
      _locale = newLocale;
      _translations.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('langueCode', newLocale.languageCode);
      await _loadCachedTranslations();
      notifyListeners();
    }
  }

  void translate(String text) {
    if (text.isEmpty) return;

    if (_translations.containsKey(text)) return;

    _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () async {
      try {
        if (!_translations.containsKey(text)) {
          final translation = await translator.translate(
            text,
            to: _locale.languageCode,
          );

          _translationCache[text] = translation.text;
          _translations[text] = translation.text;
          await _saveCachedTranslations();
          notifyListeners();
        }
      } catch (e) {
        print("Erreur de traduction : $e");
        _translationCache[text] = text;
        _translations[text] = text;
      }
    });
  }

  String getTranslation(String text) {
    if (text.isEmpty) return text;

    if (_translations.containsKey(text)) {
      return _translations[text]!;
    }

    translate(text);
    return text;
  }

  String getLanguageName(String code) {
    switch (code) {
      case "fr":
        return "Français";
      case "en":
        return "English";
      case "es":
        return "Espagne";
      case "pt":
        return "Portugal";
      case "it":
        return "Italie";
      default:
        return "Français";
    }
  }
}
