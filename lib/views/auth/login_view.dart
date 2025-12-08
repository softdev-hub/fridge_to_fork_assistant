import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/views/auth/register_view.dart';
import 'package:fridge_to_fork_assistant/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final authService = AuthService();

  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4CAF50);
    const backgroundColor = Color(0xFFF8FAF7);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    _buildLogo(),
                    const SizedBox(height: 32),
                    Text(
                      'Bếp trợ lý',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng trở lại!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildEmailField(),
                    const SizedBox(height: 24),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildForgotPassword(),
                    const SizedBox(height: 32),
                    _buildLoginButton(primaryColor),
                    const SizedBox(height: 32),
                    _buildRegisterLink(primaryColor),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    const primaryColor = Color(0xFF4CAF50);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hintText: 'nhapemail@domain.com',
            prefixIcon: Icons.email,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mật khẩu',
          style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: _inputDecoration(
            hintText: '••••••••',
            prefixIcon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {required String hintText,
      required IconData prefixIcon,
      Widget? suffixIcon}) {
    const primaryColor = Color(0xFF4CAF50);
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
        child: Icon(prefixIcon, color: Colors.grey[400]),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: GoogleFonts.beVietnamPro(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  Widget _buildForgotPassword() {
    const primaryColor = Color(0xFF4CAF50);
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password functionality
        },
        child: Text(
          'Quên mật khẩu?',
          style: GoogleFonts.beVietnamPro(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(Color primaryColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        elevation: 0,
      ),
      onPressed: login,
      child: Text(
        'Đăng nhập',
        style: GoogleFonts.beVietnamPro(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRegisterLink(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: GoogleFonts.beVietnamPro(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          ),
          child: Text(
            'Đăng ký',
            style: GoogleFonts.beVietnamPro(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
