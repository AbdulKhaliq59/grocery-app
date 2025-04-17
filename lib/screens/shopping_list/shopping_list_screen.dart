import 'package:flutter/material.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/providers/shopping_list_provider.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:grocery_app/widgets/shopping_list_item_card.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load shopping list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        shoppingListProvider.loadShoppingList(authProvider.currentUser!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ShoppingListProvider>(
      builder: (context, authProvider, shoppingListProvider, _) {
        if (authProvider.currentUser == null) {
          return const Center(
            child: Text('Please log in to view your shopping list'),
          );
        }

        if (shoppingListProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (shoppingListProvider.shoppingList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/empty_list.json',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your shopping list is empty',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add items to your list to see them here',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textColor,
                  tabs: const [
                    Tab(text: 'To Buy'),
                    Tab(text: 'Purchased'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Unpurchased items
                    shoppingListProvider.unpurchasedItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: AppTheme.subtitleColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No items to buy',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: shoppingListProvider.unpurchasedItems.length,
                            itemBuilder: (context, index) {
                              final item = shoppingListProvider.unpurchasedItems[index];
                              return Dismissible(
                                key: Key(item.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  shoppingListProvider.removeFromShoppingList(
                                    authProvider.currentUser!.id!,
                                    item.id!,
                                  );
                                },
                                child: ShoppingListItemCard(
                                  item: item,
                                  onToggle: (value) {
                                    shoppingListProvider.togglePurchaseStatus(
                                      authProvider.currentUser!.id!,
                                      item.id!,
                                      value,
                                    );
                                  },
                                  onRemove: () {
                                    shoppingListProvider.removeFromShoppingList(
                                      authProvider.currentUser!.id!,
                                      item.id!,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                    
                    // Purchased items
                    shoppingListProvider.purchasedItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 64,
                                  color: AppTheme.subtitleColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No purchased items',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: shoppingListProvider.purchasedItems.length,
                            itemBuilder: (context, index) {
                              final item = shoppingListProvider.purchasedItems[index];
                              return Dismissible(
                                key: Key(item.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  shoppingListProvider.removeFromShoppingList(
                                    authProvider.currentUser!.id!,
                                    item.id!,
                                  );
                                },
                                child: ShoppingListItemCard(
                                  item: item,
                                  onToggle: (value) {
                                    shoppingListProvider.togglePurchaseStatus(
                                      authProvider.currentUser!.id!,
                                      item.id!,
                                      value,
                                    );
                                  },
                                  onRemove: () {
                                    shoppingListProvider.removeFromShoppingList(
                                      authProvider.currentUser!.id!,
                                      item.id!,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
