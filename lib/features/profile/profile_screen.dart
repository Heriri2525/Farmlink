import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/features/auth/auth_controller.dart';
import 'package:go_router/go_router.dart';

import 'package:farmlink/data/repositories/profile_repository.dart'; // Ensure this is present

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                backgroundImage: profile?['avatar_url'] != null ? NetworkImage(profile!['avatar_url']!) : null, // Fixed here
                child: profile?['avatar_url'] == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null, // Fixed here
              ),
              const SizedBox(height: 16),
              Text(
                profile?['name'] ?? 'No Name Set', // Fixed here
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(profile?['email'] ?? 'No Email Set', style: TextStyle(color: Colors.grey[600])), // Fixed here
              const SizedBox(height: 8),
              Text(profile?['phone'] ?? 'No Phone Set', style: TextStyle(color: Colors.grey[600])), // Fixed here
              const SizedBox(height: 32),
              
               _buildProfileItem(context, Icons.person_outline, 'Edit Profile & Settings', () {
                context.push('/edit-profile', extra: profile);
              }),
              _buildProfileItem(context, Icons.history, 'Order History', () {
                context.push('/order-history');
              }),
              _buildProfileItem(context, Icons.help_outline, 'Help & Support', () {
                context.push('/help-support');
              }),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                 onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Yes', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Connection Issue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'We updated your profile! Please hot-restart the app to apply the fixes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userProfileProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}