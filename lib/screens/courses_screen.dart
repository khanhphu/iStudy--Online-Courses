import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istudy_courses/helpers/custom_format.dart';
import 'package:istudy_courses/models/courses.dart';
import 'package:istudy_courses/models/users.dart';
import 'package:istudy_courses/screens/course_detail_screen.dart';
import 'package:istudy_courses/services/api_service.dart';
import 'package:istudy_courses/services/course_enrollment_service.dart';
import 'package:istudy_courses/services/user_service.dart';
import 'package:istudy_courses/theme/colors.dart';
import 'package:istudy_courses/widgets/list_horizontalCourses.dart';
import 'package:istudy_courses/widgets/list_verticalCourses.dart';
import 'package:istudy_courses/widgets/profile_drawer_button.dart';
import 'package:istudy_courses/widgets/profile_drawer_menu.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesState();
}

class _CoursesState extends State<CoursesScreen> {
  List<Courses> courses = [];
  List<Courses> filteredCourses = [];
  Users? _currentUser;
  bool isLoading = true;
  bool isEnrolling = false;
  String errorMessage = '';
  //bool isEnrolled= false;
  // final ApiService _apiService = ApiService();
  final CourseEnrollmentService _courseService = CourseEnrollmentService();
  final UserService _userService = UserService();
  final TextEditingController searchController = TextEditingController();

  // Sample data cho horizontal courses (có thể thay bằng API sau)
  final List<Map<String, dynamic>> horizentalCourses = [
    {
      'startColor': 0xFF8E2DE2,
      'endColor': 0xFF5A4AE4,
      'crsHeadLine': 'Recommend',
      'crsImg': 'assets/uiuxbanner.png',
      'crsTitle': 'TalkSmart: English Speaking Made Easy',
      'statusColor': 0xFF5A4AE4,
    },
    {
      'startColor': 0xFF00FF87,
      'endColor': 0xFF4AE4DA,
      'crsHeadLine': 'NEW',
      'crsImg': 'assets/engbanner.png',
      'crsTitle': 'TalkSmart: English Speaking Made Easy',
      'statusColor': 0xFF5ED09B,
    },
    {
      'startColor': 0xFF00C9FF,
      'endColor': 0xFF5A4AE4,
      'crsHeadLine': 'Popular',
      'crsImg': 'assets/sftbanner.png',
      'crsTitle': 'Software Testing and Automation for Beginners',
      'statusColor': 0xFF95D4E7,
    },
  ];

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final fetchedCourses = await ApiService.getCourses();
      final user = await _userService.getCurrentUser();

      setState(() {
        courses = fetchedCourses;
        _currentUser = user;
        filteredCourses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        // Nếu API lỗi, hiển thị dữ liệu mẫu
        courses = _getSampleCourses();
        filteredCourses = courses;
      });
    }
  }

  Future<void> _reloadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print('Error reloading user data: $e');
    }
  }

  // Dữ liệu mẫu khi API không hoạt động
  List<Courses> _getSampleCourses() {
    return [
      Courses(
        id: 1,
        name: "TOEIC",
        members: 1,
        img: "assets/uiuxbanner.png",
        qty: 0,
        category: "English",
        desc: "toeic ",
        exp: 12,
        price: 13000,
      ),
    ];
  }

  void onSearch(String search) async {
    setState(() {
      isLoading = true;
    });

    if (search.isEmpty) {
      // Nếu không nhập gì thì hiển thị toàn bộ courses
      setState(() {
        filteredCourses = courses;
        isLoading = false;
      });
    } else {
      try {
        List<Courses> results = await ApiService.searchCourses(search);
        setState(() {
          filteredCourses = results;
          isLoading = false;
        });
      } catch (e) {
        print('Search error: $e');
        setState(() {
          filteredCourses = []; // hoặc giữ nguyên filteredCourses
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.purple,
      endDrawer: const ProfileDrawerMenu(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await loadCourses();
            await _reloadUserData();
          },

          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "iStudy",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontSize: 36,
                        ),
                      ),
                      Text(
                        "Khóa học",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 50),
                  const ProfileDrawerButton(),
                ],
              ),

              SizedBox(height: 22),

              // Horizontal Courses List
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: horizentalCourses.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final item = horizentalCourses[index];
                    return MyHorizontalCoursesList(
                      startColor: item['startColor'],
                      endColor: item['endColor'],
                      crsHeadLine: item['crsHeadLine'],
                      crsImg: item['crsImg'],
                      crsTitle: item['crsTitle'],
                      statusColor: item['statusColor'],
                    );
                  },
                ),
              ),

              SizedBox(height: 10),

              // Search Bar
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (value) => onSearch(value),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.light_blue,
                      contentPadding: EdgeInsets.all(0),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  onSearch('');
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      hintText: "Search courses",
                    ),
                  ),
                ],
              ),

              // Loading or Error State
              if (isLoading)
                Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  ),
                ),

              if (errorMessage.isNotEmpty && !isLoading)
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'API không khả dụng. Hiển thị dữ liệu mẫu.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Vertical Courses List
              if (!isLoading)
                ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  itemCount: filteredCourses.length,

                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    //enroll
                    final isEnrolled =
                        _currentUser?.enrolledCourses.contains(course.id) ??
                        false;
                    return VerticalListCourses(
                      courses: course,
                      crsImg:
                          course.img.isNotEmpty
                              ? course.img
                              : "assets/sftbanner.png",
                      crsTitle: course.name,
                      crsMembers: course.members,
                      crsRating: 4.0, // Có thể thêm rating vào model sau
                      onTap: () => _showCourseDetails(course, isEnrolled),
                    );
                  },
                ),

              // Empty State
              if (!isLoading && filteredCourses.isEmpty)
                Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.white.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy khóa học nào',
                          style: GoogleFonts.roboto(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigationBar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedIndex: 0,
          onDestinationSelected: (index) {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showCourseDetails(Courses course, bool isEnrolled) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            // ✅ Thêm StatefulBuilder để update UI trong modal
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Course Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child:
                                      course.img.startsWith('http')
                                          ? CachedNetworkImage(
                                            imageUrl: course.img,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.broken_image),
                                          )
                                          : Image.asset(
                                            course.img,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),

                              SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.name,
                                    style: GoogleFonts.roboto(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.purple,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CourseDetailScreen(
                                                courseId: course.id,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Xem chi tiết",
                                      style: GoogleFonts.roboto(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),

                              // Course Info Row
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      course.category,
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.people_alt_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    course.members.toString(),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),

                              // Description
                              Text(
                                'Mô tả khóa học',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),

                              Text(
                                course.desc,
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 30),

                              // Price and Enroll Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Giá khóa học',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        course.price == 0
                                            ? 'Miễn phí'
                                            : formatCurrency(course.price),
                                        style: GoogleFonts.roboto(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              course.price == 0
                                                  ? Colors.green
                                                  : AppColors.purple,
                                        ),
                                      ),
                                    ],
                                  ),

                                  ElevatedButton(
                                    onPressed:
                                        isEnrolled || isEnrolling
                                            ? null
                                            : () async {
                                              await _enrollCourse(
                                                course,
                                                setModalState,
                                              );
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isEnrolled
                                              ? Colors.grey
                                              : AppColors.purple,
                                      foregroundColor: AppColors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child:
                                        isEnrolling
                                            ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.white),
                                              ),
                                            )
                                            : Text(
                                              isEnrolled
                                                  ? 'Đã đăng ký'
                                                  : 'Đăng ký ngay',
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _enrollCourse(Courses course, StateSetter setModalState) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đăng nhập để đăng ký khóa học'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set loading state
    setState(() {
      isEnrolling = true;
    });
    setModalState(() {
      isEnrolling = true;
    });

    try {
      // Gọi service đăng ký khóa học
      bool success = await _courseService.enrollCourse(course.id);

      if (success) {
        // Reload user data để cập nhật enrolledCourses
        await _reloadUserData();

        Navigator.pop(context); // Đóng modal

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đăng ký khóa học: ${course.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể đăng ký khóa học. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Enrollment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng ký khóa học: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state
      setState(() {
        isEnrolling = false;
      });
      setModalState(() {
        isEnrolling = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
