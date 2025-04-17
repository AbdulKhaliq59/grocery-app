class AppConstants {
  // Database
  static const String dbName = 'grocery_app.db';
  static const int dbVersion = 1;
  
  // Tables
  static const String userTable = 'users';
  static const String productTable = 'products';
  static const String cartTable = 'cart_items';
  static const String shoppingListTable = 'shopping_list';
  
  // Shared Preferences Keys
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}
