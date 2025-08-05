import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:istudy_courses/models/courses.dart';
import 'package:istudy_courses/models/users.dart';
import 'package:istudy_courses/screens/course_detail_screen.dart';
import 'package:istudy_courses/screens/edit_profile_screen.dart';
import 'package:istudy_courses/services/api_service.dart';
import 'package:istudy_courses/services/user_service.dart';
import 'package:istudy_courses/theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final ApiService _courseService = ApiService();
  Users? _currentUser;
  List<Courses> _enrolledCourses = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        final courses = await _courseService.getEnrolledCourse(
          user.enrolledCourses,
        );
        setState(() {
          _currentUser = user;
          _enrolledCourses = courses;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light_blue,
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentUser == null
              ? const Center(child: Text("Không thể tải thông tin người dùng"))
              : RefreshIndicator(
                onRefresh: _loadUserData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [_buildProfileHeader(), _buildTabSection()],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                _currentUser!.photoURL != null
                    ? CachedNetworkImageProvider(_currentUser!.photoURL!)
                    : null,
            child:
                _currentUser!.photoURL == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
          ),
          const SizedBox(height: 12),
          Text(
            _currentUser!.displayName ?? 'null',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser!.email,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (_currentUser!.bio != null) ...[
            const SizedBox(height: 12),
            Text(
              _currentUser!.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Khóa học', '${_enrolledCourses.length}'),
              _buildStatItem('Hoàn thành', '0'),
              _buildStatItem('Điểm số', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              tabs: [
                const Tab(text: 'Thông tin'),
                Tab(text: 'Khóa học (${_enrolledCourses.length})'),
              ],
            ),
          ),
          Container(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [_buildInfoTab(), _buildCoursesTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            Icons.phone,
            'SĐT',
            _currentUser!.phoneNumber ?? 'null',
          ),
          _buildInfoItem(
            Icons.cake,
            'Ngày sinh',
            _currentUser!.dateOfBirth != null
                ? '${_currentUser!.dateOfBirth!.day}/${_currentUser!.dateOfBirth!.month}/${_currentUser!.dateOfBirth!.year}'
                : 'null',
          ),
          _buildInfoItem(
            Icons.calendar_today,
            'Ngày tham gia',
            '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    if (_enrolledCourses.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Chưa đăng ký khóa học nào',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _enrolledCourses.length,
        itemBuilder:
            (context, index) => _buildCourseCard(_enrolledCourses[index]),
      ),
    );
  }

  Widget _buildCourseCard(Courses course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: course.img,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
            errorWidget:
                (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
          ),
        ),
        title: Text(
          course.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                const Text("4"),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time_sharp,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text('${course.startDate}'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'detail',
                  child: Text('Xem chi tiết'),
                ),
              ],
          onSelected: (value) {
            if (value == 'detail') _navigateToDetailCourse(course.id);
          },
        ),
      ),
    );
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentUser: _currentUser!),
      ),
    );
    if (result == true) _loadUserData();
  }

  void _navigateToDetailCourse(int courseId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseId: courseId),
      ),
    );
    if (result == true) _loadUserData();
  }

  // Future<void> _navigateToDetailCourse(course)

  Future<void> _unenrollCourse(Courses course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: Text(
              'Bạn có chắc muốn hủy đăng ký khóa học "${course.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      // TODO: Implement logic to unenroll
      // bool success = await _userService.unenroll(course.id);
      // if (success) _loadUserData();
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
