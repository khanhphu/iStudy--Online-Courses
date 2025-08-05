import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istudy_courses/models/users.dart';
import '../theme/colors.dart'; // Đảm bảo AppColors.purple có định nghĩa

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // void _register() {
  //   setState(() {
  //     _errorMessage = null;
  //   });

  //   String username = _usernameController.text.trim();
  //   String email = _emailController.text.trim();
  //   String password = _passwordController.text.trim();
  //   String confirmPassword = _confirmPasswordController.text.trim();

  //   if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
  //     setState(() {
  //       _errorMessage = 'Vui lòng điền đầy đủ thông tin.';
  //     });
  //     return;
  //   }

  //   if (!email.contains('@')) {
  //     setState(() {
  //       _errorMessage = 'Email không hợp lệ.';
  //     });
  //     return;
  //   }

  //   if (password != confirmPassword) {
  //     setState(() {
  //       _errorMessage = 'Mật khẩu không khớp.';
  //     });
  //     return;
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Đăng ký thành công!')),
  //   );
  // }
  void _register() async {
    setState(() {
      _errorMessage = null;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng điền đầy đủ thông tin.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _errorMessage = 'Email không hợp lệ.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Mật khẩu không khớp.';
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      //user lay tu fb
      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final uid = firebaseUser.uid;
        //cap nhat display name

        //tao instance model
        final newUser = Users(
          uid: uid,
          email: email,
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
          phoneNumber: firebaseUser.phoneNumber,
          dateOfBirth: null,
          bio: null,
          enrolledCourses: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        //luu vao firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(newUser.toMap());

        // Thông báo đăng ký thành công
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));

        // Điều hướng & reset form
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        return;
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorMessage = 'Email đã được sử dụng.';
        } else if (e.code == 'weak-password') {
          _errorMessage = 'Mật khẩu quá yếu.';
        } else {
          _errorMessage = 'Đăng ký thất bại: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '${e.toString()}';
      });
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    VoidCallback? toggle,
    bool hasToggle = false,
  }) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF0F4FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            hasToggle
                ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggle,
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 150,
                  ), // tạo khoảng trống phía trên cho ảnh
                  // Card đăng ký
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Đăng ký thành viên',
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(_usernameController, 'Tên đăng nhập'),
                        const SizedBox(height: 15),
                        _buildTextField(_emailController, 'Email'),
                        const SizedBox(height: 15),
                        _buildTextField(
                          _passwordController,
                          'Mật khẩu',
                          obscure: _obscurePassword,
                          hasToggle: true,
                          toggle:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          _confirmPasswordController,
                          'Nhập lại mật khẩu',
                          obscure: _obscureConfirmPassword,
                          hasToggle: true,
                          toggle:
                              () => setState(
                                () =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                              ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Đăng ký'),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Ảnh minh họa nằm đè và lệch phải
              Positioned(
                top: 0,
                right: 16,
                child: Image.asset(
                  'assets/register2.png',
                  width: MediaQuery.of(context).size.width * 0.55,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              //circle
              Positioned(
                top: 5,
                right: 80,
                child: Container(
                  width: 200,
                  height: 200,
                  child: Image.asset('assets/circle.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
