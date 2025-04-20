import 'package:flutter/material.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/screens/admin/admin_dashboard_screen.dart';
import 'package:grocery_app/screens/auth/login_screen.dart';
import 'package:grocery_app/screens/profile/edit_profile_screen.dart';
import 'package:grocery_app/screens/profile/settings_screen.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:grocery_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.currentUser == null) {
          return const Center(
            child: Text('Please log in to view your profile'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                backgroundImage:
                    authProvider.currentUser!.profileImage != null
                        ? FileImage(
                          File(authProvider.currentUser!.profileImage!),
                        )
                        : null,
                child:
                    authProvider.currentUser!.profileImage == null
                        ? Text(
                          authProvider.currentUser!.name
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              authProvider.currentUser!.email
                                  .substring(0, 1)
                                  .toUpperCase(),
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(color: AppTheme.primaryColor),
                        )
                        : null,
              ),
              const SizedBox(height: 16),
              Text(
                authProvider.currentUser!.name ?? 'User',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                authProvider.currentUser!.email,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.subtitleColor),
              ),
              if (authProvider.currentUser!.isAdmin)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Admin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              _buildProfileItem(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              if (authProvider.currentUser!.isAdmin)
                _buildProfileItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Dashboard',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                ),
              _buildProfileItem(
                context,
                icon: Icons.shopping_bag_outlined,
                title: 'Order History',
                onTap: () {
                  // Implement order history functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order history functionality coming soon!'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
              _buildProfileItem(
                context,
                icon: Icons.location_on_outlined,
                title: 'Delivery Address',
                onTap: () {
                  // Implement delivery address functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delivery address functionality coming soon!',
                      ),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
              _buildProfileItem(
                context,
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                onTap: () {
                  // Implement payment methods functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Payment methods functionality coming soon!',
                      ),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
              _buildProfileItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              _buildProfileItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  // Implement help & support functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Help & support functionality coming soon!',
                      ),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Log Out',
                backgroundColor: Colors.white,
                textColor: AppTheme.errorColor,
                borderColor: AppTheme.errorColor,
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const LoginScreen(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 800),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.subtitleColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
