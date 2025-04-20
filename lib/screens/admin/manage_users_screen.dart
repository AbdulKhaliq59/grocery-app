import 'package:flutter/material.dart';
import 'package:grocery_app/models/user_model.dart';
import 'package:grocery_app/providers/admin_provider.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();
    // Load users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminProvider.users.length,
            itemBuilder: (context, index) {
              final user = adminProvider.users[index];
              return _buildUserItem(context, user, adminProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserItem(
    BuildContext context,
    User user,
    AdminProvider adminProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              // ignore: deprecated_member_use
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: Text(
                user.name?.substring(0, 1).toUpperCase() ??
                    user.email.substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'No Name',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          user.isAdmin
                              // ignore: deprecated_member_use
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              // ignore: deprecated_member_use
                              : AppTheme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      user.isAdmin ? 'Admin' : 'User',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            user.isAdmin
                                ? AppTheme.primaryColor
                                : AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DropdownButton<String>(
              underline: const SizedBox(),
              icon: const Icon(Icons.more_vert),
              items: [
                DropdownMenuItem(
                  value: 'admin',
                  child: Text(user.isAdmin ? 'Remove Admin' : 'Make Admin'),
                ),
              ],
              onChanged: (value) async {
                if (value == 'admin') {
                  final newRole = user.isAdmin ? 'user' : 'admin';
                  final success = await adminProvider.updateUserRole(
                    user.id!,
                    newRole,
                  );

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'User role updated to ${newRole.toUpperCase()}',
                        ),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update user role'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
