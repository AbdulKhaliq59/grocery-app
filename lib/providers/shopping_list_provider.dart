import 'package:flutter/material.dart';
import 'package:grocery_app/database/database_helper.dart';
import 'package:grocery_app/models/shopping_list_model.dart';
import 'package:grocery_app/models/product_model.dart';

class ShoppingListProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<ShoppingListItem> _shoppingList = [];
  bool _isLoading = false;

  List<ShoppingListItem> get shoppingList => _shoppingList;
  bool get isLoading => _isLoading;

  List<ShoppingListItem> get purchasedItems {
    return _shoppingList.where((item) => item.isPurchased).toList();
  }

  List<ShoppingListItem> get unpurchasedItems {
    return _shoppingList.where((item) => !item.isPurchased).toList();
  }

  Future<void> loadShoppingList(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _shoppingList = await _dbHelper.getShoppingList(userId);
    } catch (e) {
      debugPrint('Error loading shopping list: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToShoppingList(int userId, Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final item = ShoppingListItem(
        userId: userId,
        productId: product.id!,
        isPurchased: false,
        product: product,
      );

      await _dbHelper.addToShoppingList(item);
      await loadShoppingList(userId);
    } catch (e) {
      debugPrint('Error adding to shopping list: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> togglePurchaseStatus(int userId, int itemId, bool isPurchased) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updateShoppingListItemStatus(itemId, isPurchased);
      await loadShoppingList(userId);
    } catch (e) {
      debugPrint('Error updating purchase status: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeFromShoppingList(int userId, int itemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.removeFromShoppingList(itemId);
      await loadShoppingList(userId);
    } catch (e) {
      debugPrint('Error removing from shopping list: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
