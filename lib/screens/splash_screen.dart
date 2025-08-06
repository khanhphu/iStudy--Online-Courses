import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istudy_courses/screens/courses_screen.dart';
import 'package:istudy_courses/screens/login_screen.dart';
import 'package:istudy_courses/screens/onboarding_screen.dart';
import 'package:istudy_courses/services/local/storage_service.dart';
import 'package:istudy_courses/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(seconds: 2)); // delay để splash hiện

    bool seenOnboarding = StorageService.hasSeenOnboarding;
    bool remember = StorageService.isRemembered;
    final email = StorageService.email;
    final password = StorageService.password;

    // Debug logging
    print('Splash Debug:');
    print('seenOnboarding: $seenOnboarding');
    print('remember: $remember');
    print('email: $email');
    print('password: ${password != null ? "***" : null}');

    if (!seenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return; // Thêm return để tránh thực hiện code phía dưới
    }

    if (remember && email != null && password != null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Thành công chuyển vào màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CoursesScreen()),
        );
      } catch (e) {
        print('Auto-login failed: $e');

        // Đăng nhập thất bại, xóa thông tin lưu trữ và chuyển về LoginPage
        // StorageService.clearRememberData(); // Thêm method này để xóa dữ liệu lỗi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } else {
      print(
        'Going to LoginPage - remember: $remember, email: $email, password: $password',
      );

      // Trường hợp: remember = false hoặc email/password = null
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/amico.png', // Thay bằng hình ảnh phù hợp nếu cần
                // height: MediaQuery.of(context).size.height * 0.3,
                // width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
                height: 300,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.error_outline,
                      size: 100,
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                'iStudy',
                style: GoogleFonts.roboto(
                  textStyle: Theme.of(context).textTheme.headlineLarge,
                ).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                'Học dễ dàng và nhanh chóng!\nXem video bài giảng mọi lúc, mọi nơi',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              // FilledButton(
              //   onPressed:
              //       () => Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => const LoginPage(),
              //           settings: const RouteSettings(name: 'LoginPage'),
              //         ),
              //       ),
              //   style: FilledButton.styleFrom(
              //     minimumSize: const Size.fromHeight(70),
              //     backgroundColor: Colors.white,
              //     foregroundColor: AppColors.purple,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     textStyle: const TextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              //   child: const Text("Đăng nhập"),
              // ),
              // const SizedBox(height: 15),
              // OutlinedButton(
              //   onPressed:
              //       () => Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => const RegisterPage(),
              //           settings: const RouteSettings(name: 'RegisterPage'),
              //         ),
              //       ),
              //   style: OutlinedButton.styleFrom(
              //     minimumSize: const Size.fromHeight(70),
              //     side: const BorderSide(
              //       color: AppColors.blur_purple,
              //       width: 1.5,
              //     ),
              //     foregroundColor: AppColors.blur_purple,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     textStyle: const TextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: AppColors.white,
              //     ),
              //   ),
              //   child: const Text("Đăng ký"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
