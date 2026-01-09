import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/views/auth/login_view.dart';
import 'package:fridge_to_fork_assistant/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != _passwordController.text) return 'Mật khẩu không khớp';
    return null;
  }

  // Parse error message to user-friendly Vietnamese
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('user already registered') ||
        errorStr.contains('already exists') ||
        errorStr.contains('email already')) {
      return 'Email này đã được đăng ký';
    }
    if (errorStr.contains('invalid email')) {
      return 'Email không hợp lệ';
    }
    if (errorStr.contains('weak password') ||
        errorStr.contains('password')) {
      return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn';
    }
    if (errorStr.contains('too many requests') ||
        errorStr.contains('rate limit')) {
      return 'Quá nhiều lần thử. Vui lòng đợi một lát';
    }
    if (errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('socket')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet';
    }
    return 'Đăng ký thất bại. Vui lòng thử lại';
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await authService.signUpWithEmailPassword(email, password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng ký thành công. Vui lòng đăng nhập.'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Navigate to login and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (Route<dynamic> route) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      _buildLogo(),
                      const SizedBox(height: 32),
                      Text(
                        'Tạo tài khoản',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bắt đầu cuộc hành trình ẩm thực của bạn',
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
                      const SizedBox(height: 24),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 32),
                      _buildRegisterButton(primaryColor),
                      const SizedBox(height: 32),
                      _buildLoginLink(primaryColor),
                      const SizedBox(height: 40),
                    ],
                  ),
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
          validator: _validateEmail,
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
          validator: _validatePassword,
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xác nhận Mật khẩu',
          style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_confirmPasswordVisible,
          decoration: _inputDecoration(
            hintText: '••••••••',
            prefixIcon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              },
            ),
          ),
          validator: _validateConfirm,
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

  Widget _buildRegisterButton(Color primaryColor) {
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
      onPressed: _isLoading ? null : signUp,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
            )
          : Text(
              'Đăng ký',
              style: GoogleFonts.beVietnamPro(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildLoginLink(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: GoogleFonts.beVietnamPro(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: _isLoading
              ? null
              : () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  ),
          child: Text(
            'Đăng nhập',
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