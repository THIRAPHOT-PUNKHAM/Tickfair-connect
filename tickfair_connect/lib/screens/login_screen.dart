import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showPassword = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthService>().signInWithGoogle();
      if (mounted) Navigator.pushReplacementNamed(context, '/events');
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      // Show user-friendly error message
      if (errorMsg.contains('popup_closed')) {
        errorMsg = 'Sign-in was cancelled. Please try again.';
      }
      setState(() => _error = errorMsg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      setState(() => _error = 'Please use a Gmail account (@gmail.com)');
      return;
    }

    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthService>().signIn(email, password);
      if (mounted) Navigator.pushReplacementNamed(context, '/events');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Header
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_activity,
                        size: 100,
                        color: AppTheme.primaryColor,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                const Center(
                  child: Text(
                    'TickFair Connect',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A5F7A),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Fair Queuing for Smart Events',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A7B8C),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    helperText: 'Must use @gmail.com',
                    helperStyle: const TextStyle(fontSize: 12, color: Color(0xFF5A7B8C)),
                    prefixIcon: const Icon(Icons.email, color: AppTheme.primaryColor),
                    suffixIcon: _emailController.text.isNotEmpty
                        ? const Icon(Icons.check_circle, color: AppTheme.successColor)
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    helperText: 'Minimum 8 characters',
                    helperStyle: const TextStyle(fontSize: 12, color: Color(0xFF5A7B8C)),
                    prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.errorColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                // Login Button
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Sign In'),
                      ),
                const SizedBox(height: 16),
                // Google Sign-In Button
                _loading
                    ? const SizedBox.shrink()
                    : ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const Icon(Icons.mail),
                        label: const Text('Sign in with Gmail'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                const SizedBox(height: 16),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RegisterScreen.routeName),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
