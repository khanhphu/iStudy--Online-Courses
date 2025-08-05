import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:istudy_courses/models/courses.dart';
import 'package:istudy_courses/models/users.dart';
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
  List<Courses> _enrolledCrs = [];
  bool _isLoading = true;
  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
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
        ); //int
        setState(() {
          _currentUser = user;
          _enrolledCrs = courses;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light_blue,
      appBar: AppBar(
        title: Text('Hồ Sơ Cá Nhân'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _navigateToEditProfile(),
          ),

          IconButton(icon: Icon(Icons.logout), onPressed: () => _signOut()),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _currentUser == null
              ? Center(child: Text(" Khong the load thong tin nguoi dung"))
              : RefreshIndicator(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [_buildProHeader(), _buildTabSection()],
                  ),
                ),
                onRefresh: () => _loadUserData(),
              ),
    );
  }

  Widget _buildProHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
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
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
              SizedBox(height: 16),
              //ten- mail
              Text(
                _currentUser!.displayName ?? 'null',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _currentUser!.email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              if (_currentUser!.bio != null) ...[
                SizedBox(height: 12),
                Text(
                  _currentUser!.bio!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
              SizedBox(height: 20),
              //thong ke
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStartItem('Khóa học', '${_enrolledCrs.length}'),
                  _buildStartItem(
                    'Hoàn thành',
                    '0',
                  ), // Có thể thêm logic tính toán
                  _buildStartItem(
                    'Điểm số',
                    '0',
                  ), // Có thể thêm logic tính toán
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
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
      margin: EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              tabs: [
                Tab(text: 'Thông tin'),
                Tab(text: 'Khóa học (${_enrolledCrs.length})'),
              ],
            ),
          ),
          Container(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [_buildInforTab(), _buildCoursesTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInforTab() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInforItem(
            icon: Icons.phone,
            title: 'SDT',
            value: _currentUser!.phoneNumber ?? 'null',
          ),
          _buildInforItem(
            icon: Icons.cake,
            title: 'Ngay sinh',
            value:
                _currentUser!.dateOfBirth != null
                    ? '${_currentUser!.dateOfBirth!.day}/${_currentUser!.dateOfBirth!.month}/${_currentUser!.dateOfBirth!.year}'
                    : 'null',
          ),
          _buildInforItem(
            icon: Icons.calendar_today,
            title: 'Ngay tham gia',
            value:
                '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildInforItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
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
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    if (_enrolledCrs.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
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
        padding: EdgeInsets.all(16),
        itemCount: _enrolledCrs.length,
        itemBuilder: (context, index) {
          final course = _enrolledCrs[index];
          return _buildCourseCard(course);
        },
      ),
    );
  }

  Widget _buildCourseCard(Courses course) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
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
                  child: Icon(Icons.image),
                ),
            errorWidget:
                (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
                ),
          ),
        ),
        title: Text(
          course.name,
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            // Text(
            //   course.instructor,
            //   style: TextStyle(color: Colors.grey[600]),
            // ),
            // SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text("4"),
                SizedBox(width: 16),
                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                SizedBox(width: 4),
                Text('${course.qty}'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                PopupMenuItem(child: Text('Hủy đăng ký'), value: 'unenroll'),
              ],
          onSelected: (value) {
            if (value == 'unenroll') {
              _unenrollCourse(course);
            }
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

    if (result == true) {
      _loadUserData();
    }
  }

  Future<void> _unenrollCourse(Courses course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận'),
            content: Text(
              'Bạn có chắc muốn hủy đăng ký khóa học "${course.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xác nhận'),
              ),
            ],
          ),
    );

    // if (confirm == true) {
    //   final success = await _userService.u(course.id);
    //   if (success) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Đã hủy đăng ký khóa học thành công')),
    //     );
    //     _loadUserData();
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Có lỗi xảy ra khi hủy đăng ký'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Đăng xuất'),
            content: Text('Bạn có chắc muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Đăng xuất'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
