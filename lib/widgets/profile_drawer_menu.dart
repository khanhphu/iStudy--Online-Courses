import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:istudy_courses/screens/quiz_history_screen.dart';
import 'package:istudy_courses/screens/splash_screen.dart';
import 'package:istudy_courses/services/local/storage_service.dart';
import 'package:istudy_courses/theme/colors.dart';

class ProfileDrawerMenu extends StatelessWidget {
  const ProfileDrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : const AssetImage('assets/amico.png')
                              as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  //  user?.displayName ?? "User",
                  user?.email.toString() ?? "User",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Hồ sơ cá nhân'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Lịch sử bài làm'),
            onTap: () {
              Get.to(() => const QuizHistoryScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Trang chủ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          //Dung de xoa du lieu data storage- set lai onBoarding =true de hien thi cac trang onboarding
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Wipe out'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (_) => AlertDialog(
                      backgroundColor: AppColors.blur_purple,
                      title: const Text('Xác nhận'),
                      content: const Text(
                        'Bạn có chắc muốn xoá toàn bộ dữ liệu và đặt lại ứng dụng?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Huỷ'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Đồng ý'),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                await StorageService.resetAll();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            //xyu ly sau
          ),
        ],
      ),
    );
  }
}
