import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istudy_courses/screens/courses_screen.dart';
import 'package:istudy_courses/screens/main_screen.dart';
import 'package:istudy_courses/theme/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _isResetPasswordLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _login() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ email và mật khẩu', isError: true);
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showMessage('Email không hợp lệ', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CoursesScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy tài khoản với email này';
          break;
        case 'wrong-password':
          errorMessage = 'Mật khẩu không chính xác';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          errorMessage = 'Tài khoản đã bị vô hiệu hóa';
          break;
        case 'too-many-requests':
          errorMessage = 'Quá nhiều lần thử. Vui lòng thử lại sau';
          break;
        default:
          errorMessage = e.message ?? 'Đăng nhập thất bại';
      }
      _showMessage(errorMessage, isError: true);
    } catch (e) {
      _showMessage('Có lỗi xảy ra. Vui lòng thử lại', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  //next step: update HOME SCREEN LAYOUT
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    // Validate email input
    if (email.isEmpty) {
      _showMessage('Vui lòng nhập email để đặt lại mật khẩu', isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Email không hợp lệ', isError: true);
      return;
    }

    // Show confirmation dialog
    final shouldReset = await _showResetPasswordDialog(email);
    if (!shouldReset) return;

    setState(() => _isResetPasswordLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessage(
        'Đã gửi email đặt lại mật khẩu đến $email. Vui lòng kiểm tra hộp thư của bạn.',
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy tài khoản với email này';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        case 'too-many-requests':
          errorMessage = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
          break;
        default:
          errorMessage = e.message ?? 'Không thể gửi email đặt lại mật khẩu';
      }
      _showMessage(errorMessage, isError: true);
    } catch (e) {
      _showMessage('Có lỗi xảy ra. Vui lòng thử lại', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isResetPasswordLoading = false);
      }
    }
  }

  Future<bool> _showResetPasswordDialog(String email) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Xác nhận đặt lại mật khẩu',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              content: Text(
                'Bạn có muốn gửi email đặt lại mật khẩu đến:\n$email?',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.roboto(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E1E6E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Gửi',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 4 : 3),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
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

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/amico.png', height: 230),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      isPassword: false,
                      isSmallScreen: isSmallScreen,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu',
                      isPassword: true,
                      isSmallScreen: isSmallScreen,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            _isResetPasswordLoading ? null : _resetPassword,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isResetPasswordLoading) ...[
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF2E1E6E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              'Quên mật khẩu?',
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF2E1E6E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E1E6E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10 : 10,
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  'Đăng nhập',
                                  style: GoogleFonts.roboto(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_passwordVisible : false,
        cursorColor: const Color(0xFF4A148C),
        keyboardType:
            isPassword ? TextInputType.text : TextInputType.emailAddress,
        textInputAction:
            isPassword ? TextInputAction.done : TextInputAction.next,
        style: GoogleFonts.roboto(
          fontSize: isSmallScreen ? 15 : 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.roboto(
            color: Colors.grey[600],
            fontSize: isSmallScreen ? 14 : 15,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: isSmallScreen ? 16 : 20,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                      size: isSmallScreen ? 20 : 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }
}
