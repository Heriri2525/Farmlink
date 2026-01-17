import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/features/auth/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // Watch loading state
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ... (Keeping logo and text same, omitted for brevity if I could, but replace_file needs strict blocks.
              // I will target the class structure mainly).
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Farm Link',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 60),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue to Farm Link',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 40),

              // Form
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Email Address', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Password', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, 
                  child: const Text('Forgot Password?'),
                ),
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    try {
                      await ref.read(authControllerProvider.notifier).signIn(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      if (mounted) context.go('/home');
                    } catch (e) {
                      if (mounted) _showErrorDialog(context, e.toString());
                    }
                  },
                  child: isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Text('Login'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey[500])),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 24),
              
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ref.read(authControllerProvider.notifier).signInWithGoogle();
                        // Note: Allow redirection time
                      } catch (e) {
                         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 28), // Placeholder for Google Icon
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.grey[700])),
                  GestureDetector(
                    onTap: () {
                      context.push('/register');
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
