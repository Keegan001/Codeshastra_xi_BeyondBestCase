import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/core/constants.dart';
import 'package:safar/widgets/custom_button.dart';
import 'package:safar/services/storage_service.dart';
import 'package:safar/features/settings/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  String _selectedUnit = 'Metric';
  bool _offlineModeEnabled = true;
  
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Japanese', 'Chinese'];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];
  final List<String> _units = ['Metric', 'Imperial'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // In a real app, this would load settings from shared preferences
    // For now, just use default values
    Future.delayed(Duration.zero, () {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        _isDarkMode = themeProvider.isDarkMode;
      });
    });
  }

  Future<void> _saveSettings() async {
    // In a real app, this would save settings to shared preferences
    // For now, just simulate saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show app info
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationLegalese: '© 2023 Safar Travel App',
                children: [
                  const SizedBox(height: 16),
                  const Text(AppConstants.appDescription),
                ],
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                title: 'Dark Mode',
                subtitle: 'Use dark theme for the app',
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                    themeProvider.toggleTheme();
                  });
                },
                icon: Icons.dark_mode,
              ),
              _buildDropdownTile(
                title: 'Language',
                value: _selectedLanguage,
                options: _languages,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  }
                },
                icon: Icons.language,
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                title: 'Enable Notifications',
                subtitle: 'Receive trip reminders and updates',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                icon: Icons.notifications,
              ),
              if (_notificationsEnabled) ...[
                _buildCheckboxTile(
                  title: 'Trip Reminders',
                  subtitle: 'Upcoming trips and activities',
                  value: true,
                  onChanged: (value) {},
                ),
                _buildCheckboxTile(
                  title: 'Travel Alerts',
                  subtitle: 'Weather, cancellations, and delays',
                  value: true,
                  onChanged: (value) {},
                ),
                _buildCheckboxTile(
                  title: 'App Updates',
                  subtitle: 'New features and improvements',
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ],
          ),
          _buildSection(
            title: 'Privacy & Location',
            children: [
              _buildSwitchTile(
                title: 'Enable Location Services',
                subtitle: 'Allow app to access your location',
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                icon: Icons.location_on,
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                title: const Text('Clear App Data'),
                subtitle: const Text('Delete all local data including saved itineraries'),
                onTap: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear App Data'),
                      content: const Text(
                        'Are you sure you want to clear all app data? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Clear app data
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('App data cleared'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Regional Settings',
            children: [
              _buildDropdownTile(
                title: 'Currency',
                value: _selectedCurrency,
                options: _currencies,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                  }
                },
                icon: Icons.attach_money,
              ),
              _buildDropdownTile(
                title: 'Unit System',
                value: _selectedUnit,
                options: _units,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedUnit = value;
                    });
                  }
                },
                icon: Icons.straighten,
              ),
            ],
          ),
          _buildSection(
            title: 'Data & Sync',
            children: [
              _buildSwitchTile(
                title: 'Offline Mode',
                subtitle: 'Access your itineraries without internet',
                value: _offlineModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _offlineModeEnabled = value;
                  });
                },
                icon: Icons.offline_bolt,
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync Now'),
                subtitle: const Text('Last synced: Today, 3:42 PM'),
                onTap: () {
                  // Simulate sync
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Syncing data...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  
                  Future.delayed(const Duration(seconds: 1), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data synced successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Support',
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () {
                  // Open help page
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Send Feedback'),
                onTap: () {
                  // Open feedback form
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                onTap: () {
                  // Open privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                onTap: () {
                  // Open terms of service
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              text: 'Save Settings',
              onPressed: _saveSettings,
              variant: ButtonVariant.primary,
              isFullWidth: true,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Safar v${AppConstants.appVersion}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Text(
            title,
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppTheme.dividerColor,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      dense: true,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        underline: const SizedBox.shrink(),
      ),
    );
  }
} 