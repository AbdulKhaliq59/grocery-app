import 'package:flutter/material.dart';
import 'package:grocery_app/database/database_helper.dart';
import 'package:grocery_app/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  List<Product> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  ProductProvider() {
    _loadCategories();
    _loadProducts();
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final categories = await _dbHelper.getCategories();
      _categories = ['All', ...categories];
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedCategory == 'All') {
        _products = await _dbHelper.getProducts();
      } else {
        _products = await _dbHelper.getProductsByCategory(_selectedCategory);
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _loadProducts();
    }
  }

  Future<Product?> getProductById(int id) async {
    return await _dbHelper.getProductById(id);
  }
}
