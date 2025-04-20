import 'package:flutter/material.dart';
import 'package:grocery_app/database/database_helper.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/models/user_model.dart';

class AdminProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _dbHelper.getAllUsers();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUserRole(int userId, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _dbHelper.updateUserRole(userId, role);
      await loadUsers();
      _isLoading = false;
      notifyListeners();
      return result > 0;
    } catch (e) {
      debugPrint('Error updating user role: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _dbHelper.insertProduct(product);
      _isLoading = false;
      notifyListeners();
      return result > 0;
    } catch (e) {
      debugPrint('Error adding product: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _dbHelper.updateProduct(product);
      _isLoading = false;
      notifyListeners();
      return result > 0;
    } catch (e) {
      debugPrint('Error updating product: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _dbHelper.deleteProduct(productId);
      _isLoading = false;
      notifyListeners();
      return result > 0;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
