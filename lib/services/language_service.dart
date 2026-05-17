import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal() {
    _loadSavedLanguage();
  }

  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langCode = prefs.getString(_languageKey);
    if (langCode != null) {
      _currentLocale = Locale(langCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }
}
