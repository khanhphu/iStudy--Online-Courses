import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:istudy_courses/models/courses.dart';

class VerticalListCourses extends StatelessWidget {
  const VerticalListCourses({
    Key? key,
    required this.courses,
    required this.crsImg,
    required this.crsTitle,
    required this.crsMembers,
    required this.crsRating,
    this.price,
    this.instructor,
    this.isBookmarked = false,
    this.onBookmarkTap,
    this.onTap,
    this.gradientColors,
  }) : super(key: key);
  final Courses courses;
  final String crsImg, crsTitle;
  final double crsRating;
  final String? price, instructor;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap, onTap;
  final List<Color>? gradientColors;
  final int crsMembers;

  @override
  Widget build(BuildContext context) {
    // Default gradient colors if none provided
    final defaultGradient = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFA855F7), // Lighter purple
      const Color(0xFFE879F9), // Pink
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors ?? defaultGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: (gradientColors ?? defaultGradient).first.withOpacity(
                  0.3,
                ),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Subtle pattern overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Row(
                    children: [
                      // Course Icon/Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                            ),

                            // crsImg.startsWith('http')
                            //     ? Image.network(crsImg, fit: BoxFit.cover)
                            //     : Image.asset(crsImg, fit: BoxFit.cover),
                            child:
                                crsImg.startsWith('http')
                                    ? CachedNetworkImage(
                                      imageUrl: crsImg,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    )
                                    : Image.asset(crsImg, fit: BoxFit.cover),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Course Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title
                            Text(
                              crsTitle,
                              softWrap: true,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 18,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 12),

                            // Rating and Duration Row
                            Row(
                              children: [
                                // Rating
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        crsRating.toStringAsFixed(1),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Members
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        crsMembers.toString(),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bookmark/More Actions
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Bookmark Button
                          GestureDetector(
                            onTap: onBookmarkTap,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Price (if available)
                          if (price != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                price!,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      (gradientColors ?? defaultGradient).first,
                                  fontSize: 12,
                                ),
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
      ),
    );
  }
}

// Pre-defined gradient themes for different course categories
class CourseGradients {
  static const List<Color> programming = [Color(0xFF667eea), Color(0xFF764ba2)];

  static const List<Color> design = [
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
    Color(0xFFE879F9),
  ];

  // static const List<Color> business = [Color(0xFF11998e), Color(0xFF38ef7d)];

  // static const List<Color> photography = [Color(0xFFfd746c), Color(0xFFff9068)];

  // static const List<Color> marketing = [Color(0xFF4facfe), Color(0xFF00f2fe)];
}
