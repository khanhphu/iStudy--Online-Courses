import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istudy_courses/screens/login_page.dart';
import '../theme/colors.dart';
import 'register_page.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple, // Màu nền tím giống trong hình
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/amico.png', // Thay bằng hình ảnh phù hợp nếu cần
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.7,
                errorBuilder: (context, error, stackTrace) => const Icon(
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
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                    settings: const RouteSettings(name: 'LoginPage'),
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(70),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text("Đăng nhập"),
              ),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                    settings: const RouteSettings(name: 'RegisterPage'),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(70),
                  side: const BorderSide(color: AppColors.blur_purple, width: 1.5),
                  foregroundColor: AppColors.blur_purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white
                  ),
                ),
                child: const Text("Đăng ký"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}