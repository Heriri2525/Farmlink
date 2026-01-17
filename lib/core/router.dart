import 'package:farmlink/features/profile/edit_profile_screen.dart';
import 'package:farmlink/features/profile/order_history_screen.dart';
import 'package:farmlink/features/profile/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/features/auth/login_screen.dart';
import 'package:farmlink/features/auth/register_screen.dart';
import 'package:farmlink/features/home/home_screen.dart';
import 'package:farmlink/features/products/product_details_screen.dart';
import 'package:farmlink/features/notifications/notifications_screen.dart';
import 'package:farmlink/features/search/search_screen.dart';
import 'package:farmlink/features/orders/orders_screen.dart'; // Single, correct import
import 'package:farmlink/data/models/product.dart';
import 'package:farmlink/main.dart'; // For Splash Screen
import 'package:farmlink/features/auth/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:farmlink/data/models/profile_model.dart';
import 'package:farmlink/features/products/add_product_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref.read(authRepositoryProvider).authStateChanges),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isLoggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';
      final isSplash = state.uri.toString() == '/';

      if (isLoggedIn) {
        // If logged in and trying to go to login/register or splash, go to home
        if (isLoggingIn || isSplash) {
          return '/home';
        }
      } 
      // Note: We don't force redirect to login from splash, so user can see splash content.
      // But if they try to access home/protected routes without login, we should redirect.
      // For now, let's keep it simple: If logged in -> Home. 
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) {
          final product = state.extra as Product?;
          return AddProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final profile = state.extra as Profile?;
          return EditProfileScreen(profile: profile);
        },
      ),
      GoRoute(
        path: '/order-history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      // OAuth callback route - handles Google OAuth redirect
      GoRoute(
        path: '/login-callback',
        builder: (context, state) {
          // This screen will process the OAuth callback
          return const OAuthCallbackScreen();
        },
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// OAuth Callback Screen to handle Google OAuth redirect
class OAuthCallbackScreen extends StatefulWidget {
  const OAuthCallbackScreen({super.key});

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleOAuthCallback();
  }

  Future<void> _handleOAuthCallback() async {
    try {
      // Get the current URI from the router state
      final uri = GoRouterState.of(context).uri;
      
      // Extract session from the OAuth callback URL
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      
      if (mounted) {
        // Session is set, navigate to home
        context.go('/home');
      }
    } catch (e) {
      // If there's an error, redirect to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: ${e.toString()}')),
        );
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}