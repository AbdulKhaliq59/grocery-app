// Import Product model
import 'product_model.dart';

class CartItem {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;
  final Product? product;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory CartItem.fromMap(Map<String, dynamic> map, {Product? product}) {
    return CartItem(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      product: product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    int? id,
    int? userId,
    int? productId,
    int? quantity,
    Product? product,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }
}
