import 'package:flutter/material.dart';
import 'package:grocery_app/database/database_helper.dart';
import 'package:grocery_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocery_app/utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  User? _currentUser;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;

    if (isLoggedIn) {
      final userId = prefs.getInt(AppConstants.userIdKey);
      if (userId != null) {
        _currentUser = await _dbHelper.getUserById(userId);
        _isLoggedIn = _currentUser != null;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String email, String password, {String? name}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = User(email: email, password: password, name: name);

      final userId = await _dbHelper.insertUser(user);

      if (userId > 0) {
        _currentUser = user.copyWith(id: userId);
        await _saveUserSession(userId, email);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _dbHelper.getUser(email, password);

      if (user != null) {
        _currentUser = user;
        await _saveUserSession(user.id!, email);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _currentUser = null;
    _isLoggedIn = false;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveUserSession(int userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.userIdKey, userId);
    await prefs.setString(AppConstants.userEmailKey, email);
    await prefs.setBool(AppConstants.isLoggedInKey, true);
  }

  Future<bool> updateProfile(String name, String? profileImage) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          name: name,
          profileImage: profileImage,
        );

        final result = await _dbHelper.updateUserProfile(updatedUser);

        if (result > 0) {
          _currentUser = updatedUser;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser != null) {
        // Verify current password
        final user = await _dbHelper.getUser(
          _currentUser!.email,
          currentPassword,
        );

        if (user != null) {
          final result = await _dbHelper.updateUserPassword(
            _currentUser!.id!,
            newPassword,
          );

          if (result > 0) {
            _isLoading = false;
            notifyListeners();
            return true;
          }
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
