import 'package:flutter/material.dart';
// import 'package:grocery_app/models/cart_item_model.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:grocery_app/widgets/cart_item_card.dart';
import 'package:grocery_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, CartProvider>(
      builder: (context, authProvider, cartProvider, _) {
        if (authProvider.currentUser == null) {
          return const Center(child: Text('Please log in to view your cart'));
        }

        if (cartProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartProvider.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/empty_cart.json',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add items to your cart to see them here',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartProvider.cartItems[index];
                  return Dismissible(
                    key: Key(cartItem.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      cartProvider.removeFromCart(
                        authProvider.currentUser!.id!,
                        cartItem.id!,
                      );
                    },
                    child: CartItemCard(
                      cartItem: cartItem,
                      onIncrement: () {
                        cartProvider.updateQuantity(
                          authProvider.currentUser!.id!,
                          cartItem.id!,
                          cartItem.quantity + 1,
                        );
                      },
                      onDecrement: () {
                        if (cartItem.quantity > 1) {
                          cartProvider.updateQuantity(
                            authProvider.currentUser!.id!,
                            cartItem.id!,
                            cartItem.quantity - 1,
                          );
                        } else {
                          cartProvider.removeFromCart(
                            authProvider.currentUser!.id!,
                            cartItem.id!,
                          );
                        }
                      },
                      onRemove: () {
                        cartProvider.removeFromCart(
                          authProvider.currentUser!.id!,
                          cartItem.id!,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                      Text(
                        '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Checkout',
                    onPressed: () {
                      // Implement checkout functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Checkout functionality coming soon!'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
