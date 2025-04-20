import 'package:flutter/material.dart';
import 'package:grocery_app/providers/admin_provider.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/screens/admin/manage_products_screen.dart';
import 'package:grocery_app/screens/admin/manage_users_screen.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.currentUser == null ||
              !authProvider.currentUser!.isAdmin) {
            return const Center(
              child: Text('You do not have permission to access this page'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your store from here',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.subtitleColor,
                  ),
                ),
                const SizedBox(height: 32),
                _buildAdminCard(
                  context,
                  title: 'Manage Products',
                  subtitle: 'Add, edit, or remove products',
                  icon: Icons.inventory,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ManageProductsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildAdminCard(
                  context,
                  title: 'Manage Users',
                  subtitle: 'View and manage user roles',
                  icon: Icons.people,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ManageUsersScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildAdminCard(
                  context,
                  title: 'View Orders',
                  subtitle: 'Manage customer orders',
                  icon: Icons.shopping_bag,
                  onTap: () {
                    // Navigate to orders screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Orders management coming soon!'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildAdminCard(
                  context,
                  title: 'Analytics',
                  subtitle: 'View sales and user analytics',
                  icon: Icons.bar_chart,
                  onTap: () {
                    // Navigate to analytics screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Analytics coming soon!'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.subtitleColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
