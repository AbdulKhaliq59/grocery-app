import 'package:flutter/material.dart';
import 'package:grocery_app/providers/settings_provider.dart';
import 'package:grocery_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle(context, 'Appearance'),
              _buildSettingItem(
                context,
                title: 'Dark Mode',
                subtitle: 'Enable dark theme for the app',
                trailing: Switch(
                  value: settingsProvider.isDarkMode,
                  onChanged: (value) {
                    settingsProvider.setDarkMode(value);
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              const Divider(),
              _buildSectionTitle(context, 'Notifications'),
              _buildSettingItem(
                context,
                title: 'Push Notifications',
                subtitle: 'Receive notifications about orders and promotions',
                trailing: Switch(
                  value: settingsProvider.useNotifications,
                  onChanged: (value) {
                    settingsProvider.setUseNotifications(value);
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              const Divider(),
              _buildSectionTitle(context, 'Regional'),
              _buildSettingItem(
                context,
                title: 'Currency',
                subtitle: 'Select your preferred currency',
                trailing: DropdownButton<String>(
                  value: settingsProvider.currency,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setCurrency(value);
                    }
                  },
                ),
              ),
              const Divider(),
              _buildSectionTitle(context, 'About'),
              _buildSettingItem(
                context,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () {
                  // Navigate to terms of service
                },
              ),
              _buildSettingItem(
                context,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
