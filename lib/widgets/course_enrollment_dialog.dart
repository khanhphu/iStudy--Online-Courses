import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:istudy_courses/helpers/custom_format.dart';
import 'package:istudy_courses/models/courses.dart';

class CourseEnrollmentDialog extends StatelessWidget {
  final Courses course;
  final VoidCallback onEnroll;
  const CourseEnrollmentDialog({
    Key? key,
    required this.course,
    required this.onEnroll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: course.img,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, size: 50),
                    ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  Text(
                    'Số lượng: ${course.qty}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),

                  // Row(
                  //   children: [
                  //     Icon(Icons.star, color: Colors.amber, size: 16),
                  //     SizedBox(width: 4),
                  //     Text('${course.rating}'),
                  //     SizedBox(width: 16),
                  //     Icon(
                  //       Icons.access_time,
                  //       color: Colors.grey[600],
                  //       size: 16,
                  //     ),
                  //     SizedBox(width: 4),
                  //     Text('${course.duration}h'),
                  //     SizedBox(width: 16),
                  //     Container(
                  //       padding: EdgeInsets.symmetric(
                  //         horizontal: 8,
                  //         vertical: 2,
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color: Colors.blue[50],
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       child: Text(
                  //         course.level,
                  //         style: TextStyle(
                  //           fontSize: 12,
                  //           color: Colors.blue[700],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 12),

                  Text(
                    course.desc,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),

                  if (course.price > 0)
                    Text(
                      'Giá:' + formatCurrency(course.price),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onEnroll();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Đăng ký'),
        ),
      ],
    );
  }
}
