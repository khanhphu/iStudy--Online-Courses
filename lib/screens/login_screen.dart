import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istudy_courses/screens/courses_screen.dart';
import 'package:istudy_courses/screens/main_screen.dart';
import 'package:istudy_courses/screens/register_screen.dart';
import 'package:istudy_courses/services/local/storage_service.dart';
import 'package:istudy_courses/theme/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _isResetPasswordLoading = false;
  bool _rememberMe = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ email và mật khẩu', isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Email không hợp lệ', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (_rememberMe) {
        StorageService.setRememberMe(true);
        StorageService.saveCredentials(email, password);
      } else {
        StorageService.setRememberMe(false);
        StorageService.clearCredentials();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CoursesScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      final error = switch (e.code) {
        'user-not-found' => 'Không tìm thấy tài khoản với email này',
        'wrong-password' => 'Mật khẩu không chính xác',
        'invalid-email' => 'Email không hợp lệ',
        'user-disabled' => 'Tài khoản đã bị vô hiệu hóa',
        'too-many-requests' => 'Quá nhiều lần thử. Vui lòng thử lại sau',
        _ => e.message ?? 'Đăng nhập thất bại',
      };
      _showMessage(error, isError: true);
    } catch (_) {
      _showMessage('Có lỗi xảy ra. Vui lòng thử lại', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !_isValidEmail(email)) {
      _showMessage(
        'Vui lòng nhập email hợp lệ để đặt lại mật khẩu',
        isError: true,
      );
      return;
    }

    final confirm = await _showResetPasswordDialog(email);
    if (!confirm) return;

    setState(() => _isResetPasswordLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessage(
        'Đã gửi email đặt lại mật khẩu đến $email. Vui lòng kiểm tra hộp thư của bạn.',
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      final error = switch (e.code) {
        'user-not-found' => 'Không tìm thấy tài khoản với email này',
        'invalid-email' => 'Email không hợp lệ',
        'too-many-requests' => 'Quá nhiều yêu cầu. Vui lòng thử lại sau',
        _ => e.message ?? 'Không thể gửi email đặt lại mật khẩu',
      };
      _showMessage(error, isError: true);
    } finally {
      if (mounted) setState(() => _isResetPasswordLoading = false);
    }
  }

  Future<bool> _showResetPasswordDialog(String email) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Xác nhận đặt lại mật khẩu',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                ),
                content: Text(
                  'Bạn có muốn gửi email đặt lại mật khẩu đến:\n$email?',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.roboto(color: Colors.grey[700]),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                    ),
                    child: Text(
                      'Gửi',
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
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
                      _emailController,
                      'Email',
                      false,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _passwordController,
                      'Mật khẩu',
                      true,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: Text(
                        'Ghi nhớ đăng nhập',
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                      value: _rememberMe,
                      onChanged:
                          (value) =>
                              setState(() => _rememberMe = value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            _isResetPasswordLoading ? null : _resetPassword,
                        child:
                            _isResetPasswordLoading
                                ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Quên mật khẩu?',
                                  style: GoogleFonts.roboto(
                                    color: AppColors.purple,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                : Text(
                                  'Đăng nhập',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Chưa có tài khoản?', style: GoogleFonts.roboto()),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Đăng ký',
                            style: GoogleFonts.roboto(color: AppColors.purple),
                          ),
                        ),
                      ],
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isPassword,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_passwordVisible : false,
        keyboardType:
            isPassword ? TextInputType.text : TextInputType.emailAddress,
        textInputAction:
            isPassword ? TextInputAction.done : TextInputAction.next,
        style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                  )
                  : null,
        ),
      ),
    );
  }
}
