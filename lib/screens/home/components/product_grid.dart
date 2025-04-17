import 'package:flutter/material.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/providers/product_provider.dart';
import 'package:grocery_app/screens/product/product_detail_screen.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:grocery_app/widgets/product_card.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget {
  final String searchQuery;
  
  const ProductGrid({
    Key? key,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        if (productProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        List<Product> filteredProducts = productProvider.products;
        
        if (searchQuery.isNotEmpty) {
          filteredProducts = filteredProducts
              .where((product) => product.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
        }
        
        if (filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppTheme.subtitleColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            
            return Hero(
              tag: 'product-${product.id}',
              child: ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(product: product),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                onAddToCart: () {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);
                  
                  if (authProvider.currentUser != null) {
                    cartProvider.addToCart(authProvider.currentUser!.id!, product);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        backgroundColor: AppTheme.primaryColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
