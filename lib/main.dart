import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:farmlink/core/constants.dart';
import 'package:farmlink/core/theme.dart';
import 'package:farmlink/core/router.dart';
import 'package:farmlink/features/notifications/notification_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import flutter_secure_storage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions( // Use authOptions
      authFlowType: AuthFlowType.pkce, // Correct enum case
      pkceAsyncStorage: SupabaseSecureStorage(), // Use custom secure storage
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

// Custom storage implementation for PKCE using FlutterSecureStorage
class SupabaseSecureStorage extends GotrueAsyncStorage {
  const SupabaseSecureStorage();

  @override
  Future<String?> getItem({required String key}) async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: key);
  }

  @override
  Future<void> removeItem({required String key}) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: key, value: value);
  }
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    // Listen for new notifications to show SnackBar
    ref.listen(notificationsStreamProvider, (previous, next) {
      next.whenData((notifications) {
        if (previous?.value != null && notifications.length > previous!.value!.length) {
          // A new notification was added
          final newNotification = notifications.first; // Assumes ordered by desc
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(newNotification.title),
              action: SnackBarAction(
                label: 'View',
                onPressed: () => router.push('/notifications'),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    });

    return MaterialApp.router(
      title: 'Farm Link',
      theme: AppTheme.theme,
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
    );
  }
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Farm Link',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Connecting Farmers and Buyers',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              
              const SizedBox(height: 48),
              
              // Description
              Text(
                'Welcome to Farm Link\n\nYour trusted marketplace for buying and selling fresh agricultural products directly from farmers.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
              ),
              
              const Spacer(),
              
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
