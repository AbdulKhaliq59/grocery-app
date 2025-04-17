// Import Product model
import 'product_model.dart';

class ShoppingListItem {
  final int? id;
  final int userId;
  final int productId;
  final bool isPurchased;
  final Product? product;

  ShoppingListItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.isPurchased,
    this.product,
  });

  factory ShoppingListItem.fromMap(
    Map<String, dynamic> map, {
    Product? product,
  }) {
    return ShoppingListItem(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      isPurchased: map['is_purchased'] == 1,
      product: product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'is_purchased': isPurchased ? 1 : 0,
    };
  }

  ShoppingListItem copyWith({
    int? id,
    int? userId,
    int? productId,
    bool? isPurchased,
    Product? product,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      isPurchased: isPurchased ?? this.isPurchased,
      product: product ?? this.product,
    );
  }
}
