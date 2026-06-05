import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/auth_service.dart';
import '../widgets/app_theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailMode = false; // Show email form instead of Google button
  bool _isSignUp = false;    // Switch between Sign In and Sign Up

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await _authService.signUpWithEmailAndPassword(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dynamic background elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentNeon.withValues(alpha: 0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(
                  begin: 1.0,
                  end: 1.2,
                  duration: 4.seconds,
                  curve: Curves.easeInOut,
                ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(
                  begin: 1.0,
                  end: 1.3,
                  duration: 5.seconds,
                  curve: Curves.easeInOut,
                ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom - 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 40),
                    // App Logo / Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentNeon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              height: 32,
                              width: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ).animate().rotate(
                              duration: 800.ms,
                              curve: Curves.easeOutBack,
                            ).scale(),
                        const SizedBox(width: 12),
                        Text(
                          'Trackify',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Track everything that matters.\nAll in one place.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2),
                    
                    const SizedBox(height: 60),

                    // Authentication form / buttons card
                    AnimatedSize(
                      duration: 300.ms,
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.accentNeon.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                        ),
                        child: _isEmailMode ? _buildEmailForm(theme) : _buildSocialLanding(theme),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2),

                    const SizedBox(height: 24),

                    // Terms and conditions text
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms & Privacy Policy',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Social Auth Landing (Default State)
  Widget _buildSocialLanding(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _handleGoogleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF262626),
            foregroundColor: AppTheme.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: AppTheme.accentNeon,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                        height: 18,
                        width: 18,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.language,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.white10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'OR',
                style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Divider(color: Colors.white10)),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _isEmailMode = true;
              _isSignUp = false;
            });
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accentNeon,
            side: const BorderSide(color: AppTheme.accentNeon, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Continue with Email',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Email Sign In / Sign Up Form
  Widget _buildEmailForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEmailMode = false;
                  });
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
              ),
              Text(
                _isSignUp ? 'Create Account' : 'Welcome Back',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 40), // Spacer balancing the back button
            ],
          ),
          const SizedBox(height: 24),
          if (_isSignUp) ...[
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentNeon,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _isSignUp ? 'Sign Up' : 'Log In',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                    _formKey.currentState?.reset();
                  });
                },
                child: Text(
                  _isSignUp ? 'Log In' : 'Sign Up',
                  style: const TextStyle(
                    color: AppTheme.accentNeon,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable themed text field matching FamPay design language
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppTheme.accentNeon, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF262626),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentNeon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}
