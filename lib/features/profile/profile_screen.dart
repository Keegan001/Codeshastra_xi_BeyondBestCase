import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/user.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/widgets/custom_button.dart';
import 'package:safar/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import 'package:safar/features/auth/auth_provider.dart';
import 'package:safar/features/settings/theme_provider.dart';
import 'package:safar/features/settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Settings
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User user = authProvider.currentUser ?? User.dummy();
    final userItineraries = Itinerary.dummyList();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(user),
              
              // Stats
              _buildStatsSection(userItineraries),
              
              // Recent Itineraries
              _buildRecentItinerariesSection(userItineraries),
              
              // Settings
              _buildSettingsSection(),
              
              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: 'Log Out',
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Log Out'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              authProvider.logout(); // Logout user
                            },
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                  },
                  variant: ButtonVariant.outlined,
                  isFullWidth: true,
                ),
              ),
              
              // App info
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Safar v1.0.0',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Header with User Info
  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.cardColor,
      child: Column(
        children: [
          // Avatar and Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    backgroundImage: NetworkImage(user.profileImage ?? ''),
                    child: user.profileImage == null 
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  
                  // Edit Button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.cardColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User Name
          Text(
            user.name,
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            user.email,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Edit Profile Button
          CustomButton(
            text: 'Edit Profile',
            onPressed: () {
              // Navigation to edit profile - will be implemented in phase 2
            },
            variant: ButtonVariant.outlined,
            size: ButtonSize.small,
            iconData: Icons.person,
          ),
        ],
      ),
    );
  }

  // Stats Section with Itinerary Counts
  Widget _buildStatsSection(List<Itinerary> userItineraries) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              count: userItineraries.length.toString(),
              label: 'Itineraries',
              icon: Icons.map,
            ),
            _buildDivider(),
            _buildStatItem(
              count: '5',
              label: 'Countries',
              icon: Icons.public,
            ),
            _buildDivider(),
            _buildStatItem(
              count: '25',
              label: 'Days',
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  // Single Stat Item
  Widget _buildStatItem({
    required String count,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Vertical Divider
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppTheme.dividerColor,
    );
  }

  // Recent Itineraries Section
  Widget _buildRecentItinerariesSection(List<Itinerary> userItineraries) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Itineraries',
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (userItineraries.isEmpty)
            _buildEmptyState()
          else
            ...List.generate(
              userItineraries.length > 2 ? 2 : userItineraries.length,
              (index) => _buildItineraryItem(userItineraries[index]),
            ),
          
          const SizedBox(height: 16),
          if (userItineraries.isNotEmpty)
            CustomButton(
              text: 'View All',
              onPressed: () {
                // Navigate to itineraries screen
              },
              variant: ButtonVariant.outlined,
              isFullWidth: true,
            ),
        ],
      ),
    );
  }

  // Empty State for No Itineraries
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(
              Icons.map_outlined,
              size: 48,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No itineraries yet',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first itinerary to get started',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Create Itinerary',
              onPressed: () {
                // Navigate to create itinerary
              },
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  // Itinerary Item
  Widget _buildItineraryItem(Itinerary itinerary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        padding: EdgeInsets.zero,
        onTap: () {
          // Navigate to itinerary details
        },
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                _getImageForDestination(itinerary.destination),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itinerary.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          itinerary.destination,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppTheme.textSecondaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateRange(
                            itinerary.dateRange.start, 
                            itinerary.dateRange.end,
                          ),
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondaryColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Settings Section
  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: Column(
              children: [
                // Navigate to Settings
                ListTile(
                  leading: const Icon(
                    Icons.settings,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Settings'),
                  subtitle: const Text('App preferences and account settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to settings screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                
                // Dark Mode Toggle
                SwitchListTile(
                  secondary: Icon(
                    _darkModeEnabled ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Dark Mode'),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                      // Update theme
                      Provider.of<ThemeProvider>(context, listen: false).setDarkMode(value);
                    });
                  },
                ),
                const Divider(),
                
                // Notifications Toggle
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const Divider(),
                
                // Language Settings
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Language'),
                  subtitle: const Text('English'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Language settings - will be implemented in phase 2
                  },
                ),
                const Divider(),
                
                // Help & Support
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Help & Support - will be implemented in phase 2
                  },
                ),
                const Divider(),
                
                // Privacy Policy
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Privacy Policy - will be implemented in phase 2
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get image for a destination
  String _getImageForDestination(String destinationName) {
    if (destinationName.toLowerCase().contains('paris')) {
      return 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (destinationName.toLowerCase().contains('tokyo')) {
      return 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (destinationName.toLowerCase().contains('bali')) {
      return 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else {
      return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    }
  }
  
  // Helper method to format a date range
  String _formatDateRange(DateTime start, DateTime end) {
    // Simple date formatting
    final startMonth = _getShortMonthName(start.month);
    final endMonth = _getShortMonthName(end.month);
    
    if (start.year == end.year && start.month == end.month) {
      return '$startMonth ${start.day}-${end.day}';
    } else if (start.year == end.year) {
      return '$startMonth ${start.day} - $endMonth ${end.day}';
    } else {
      return '$startMonth ${start.year} - $endMonth ${end.year}';
    }
  }
  
  // Helper method to get short month name
  String _getShortMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
} 