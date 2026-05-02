import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/screens/auth/signup_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _authError;

  late AnimationController _animController;
  late AnimationController _bgAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/google_icon.png'), context);
    precacheImage(const AssetImage('assets/images/habitspark_logo.png'), context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _authError = null;
    });

    try {
      final userCredential = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted && userCredential != null) {
        // Navigation is handled by main.dart StreamBuilder
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Incorrect Username or Password';
        if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please try again later.';
        }
        setState(() => _authError = errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _authError = null;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (mounted && userCredential != null) {
        // Handled by StreamBuilder
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _authError = e.toString().contains('cancelled') 
              ? 'Google sign-in cancelled' 
              : 'Google sign-in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Dynamic Background
          _buildAnimatedBackground(),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildHeader(),
                      const SizedBox(height: 60),
                      _buildSimpleForm(),
                      const SizedBox(height: 32),
                      _buildSignUpLink(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2D8A5B),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, child) {
        return Stack(
          children: [
            // Base Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF020617)],
                ),
              ),
            ),
            // Glowing Blobs
            Positioned(
              top: -100 + (50 * _bgAnimController.value),
              right: -100 + (30 * _bgAnimController.value),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2D8A5B).withAlpha(40),
                ),
              ),
            ),
            Positioned(
              bottom: -50 - (40 * _bgAnimController.value),
              left: -50 + (20 * _bgAnimController.value),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E40AF).withAlpha(30),
                ),
              ),
            ),
            // Blur Layer
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'logo',
          child: Image.asset(
            'assets/images/habitspark_logo.png',
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          'HabitSpark',
          style: GoogleFonts.outfit(
            fontSize: 35,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        Text(
          'Ignite your potential',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white60,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Password too short' : null,
          ),
          if (_authError != null) ...[
            const SizedBox(height: 12),
            Text(
              _authError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFF87171), fontSize: 13),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildPrimaryButton(),
          const SizedBox(height: 20),
          _buildGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withAlpha(30),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(40),
                Colors.white.withAlpha(10),
              ],
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white60,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Password too short' : null,
                ),
                if (_authError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _authError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFF87171), fontSize: 13),
                  ),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, // Implementation same as before
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildPrimaryButton(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGoogleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white60, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withAlpha(8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D8A5B), width: 2),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D8A5B), Color(0xFF1E40AF)],
        ),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          'Sign In',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: _isLoading ? null : _signInWithGoogle,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.white.withAlpha(30)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/google_icon.png', height: 20),
          const SizedBox(width: 10),
          Text(
            'Continue with Google',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "New here? ",
          style: TextStyle(color: Colors.white60),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
          child: const Text(
            "Create Account",
            style: TextStyle(
              color: Color(0xFF2D8A5B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
