import 'package:flutter/material.dart';
import 'package:grocery_app/database/database_helper.dart';
import 'package:grocery_app/models/cart_item_model.dart';
import 'package:grocery_app/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  double get totalPrice {
    return _cartItems.fold(0, (total, item) {
      return total + (item.product?.price ?? 0) * item.quantity;
    });
  }

  int get itemCount {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  Future<void> loadCartItems(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await _dbHelper.getCartItems(userId);
    } catch (e) {
      debugPrint('Error loading cart items: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(int userId, Product product, {int quantity = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cartItem = CartItem(
        userId: userId,
        productId: product.id!,
        quantity: quantity,
        product: product,
      );

      await _dbHelper.addToCart(cartItem);
      await loadCartItems(userId);
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateQuantity(int userId, int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(userId, cartItemId);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updateCartItemQuantity(cartItemId, quantity);
      await loadCartItems(userId);
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeFromCart(int userId, int cartItemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.removeFromCart(cartItemId);
      await loadCartItems(userId);
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearCart(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.clearCart(userId);
      _cartItems = [];
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
