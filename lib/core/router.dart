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
import 'package:farmlink/features/orders/orders_screen.dart';
import 'package:farmlink/data/models/product.dart';
import 'package:farmlink/main.dart';
import 'package:farmlink/features/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:farmlink/data/models/profile_model.dart';
import 'package:farmlink/features/products/add_product_screen.dart';
import 'package:farmlink/data/repositories/auth_repository.dart';

final routerProvider = Provider<GoRouter>((ref) {
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref.read(authRepositoryProvider).authStateChanges),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final isLoggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';
      final isSplash = state.uri.toString() == '/';

      if (!isLoggedIn) {
        if (!isLoggingIn && !isSplash) {
          return '/login';
        }
      } else {
        if (isLoggingIn || isSplash) {
          return '/home';
        }
      }
      
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