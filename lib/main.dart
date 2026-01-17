import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:farmlink/core/constants.dart';
import 'package:farmlink/core/theme.dart';
import 'package:farmlink/core/router.dart';
import 'package:farmlink/features/notifications/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  String? initError;

  // Initialize Firebase
  try {
    // Note: For Web, you must provide FirebaseOptions:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
  } catch (e) {
    initError = e.toString();
    debugPrint('Firebase initialization failed: $initError');
  }

  runApp(ProviderScope(
    child: isFirebaseInitialized 
      ? const MyApp() 
      : MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Firebase Initialization Failed',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: $initError\n\n'
                      'Tip: If you are running on Web, you must run "flutterfire configure" '
                      'to generate lib/firebase_options.dart and use it in initializeApp.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
  ));
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
