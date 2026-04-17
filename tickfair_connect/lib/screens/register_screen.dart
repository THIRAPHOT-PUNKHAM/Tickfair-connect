import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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

    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthService>().signUp(email, password);
      if (mounted) Navigator.pop(context);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Create Account', style: TextStyle(color: Color(0xFF1A5F7A))),
        iconTheme: const IconThemeData(color: Color(0xFF1A5F7A)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join TickFair',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Register to start booking tickets fairly',
                  style: TextStyle(fontSize: 13, color: Color(0xFF5A7B8C)),
                ),
                const SizedBox(height: 24),
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
                    hintText: 'Create a password',
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
                const SizedBox(height: 20),
                // Confirm Password Field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    helperText: 'Must match password',
                    helperStyle: const TextStyle(fontSize: 12, color: Color(0xFF5A7B8C)),
                    prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                // Error Message
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
                // Register Button
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Create Account'),
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
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
