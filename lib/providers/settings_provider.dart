import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _useNotifications = true;
  String _currency = 'USD';
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  bool get useNotifications => _useNotifications;
  String get currency => _currency;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _useNotifications = prefs.getBool('useNotifications') ?? true;
      _currency = prefs.getString('currency') ?? 'USD';
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', value);
      _isDarkMode = value;
    } catch (e) {
      debugPrint('Error setting dark mode: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUseNotifications(bool value) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('useNotifications', value);
      _useNotifications = value;
    } catch (e) {
      debugPrint('Error setting notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', value);
      _currency = value;
    } catch (e) {
      debugPrint('Error setting currency: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
