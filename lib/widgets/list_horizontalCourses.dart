import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istudy_courses/theme/colors.dart';

class MyHorizontalCoursesList extends StatelessWidget {
  const MyHorizontalCoursesList({
    Key? key,
    required this.startColor,
    required this.endColor,
    required this.crsHeadLine,
    required this.crsImg,
    required this.crsTitle,
    required this.statusColor,
  }) : super(key: key);
  //mau sac cho card view courses
  //1. mau nen la mau gradient
  final int startColor, endColor, statusColor;
  final String crsHeadLine, crsTitle, crsImg;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 26),
      child: Container(
        width: 246,
        height: 349,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: const Alignment(0, 1),
            colors: <Color>[Color(startColor), Color(endColor)],
          ),
        ),
        //Status course: Recommend, New, Popular
        child: Stack(
          children: [
            Positioned(
              top: 15,
              left: 11,
              child: Container(
                padding: EdgeInsets.all(10),
                height: 39,
                decoration: BoxDecoration(
                  color: Color(this.statusColor),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Text(
                  crsHeadLine,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 11,
              right: 11, //de title khoa hoc xuong dong, k bi cat chu
              child: Text(
                crsTitle,
                textAlign: TextAlign.left,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontSize: 16,
                ),
                maxLines: 2,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 40,
              width: 190,
              height: 200,
              child: Image.asset(crsImg, scale: 1, fit: BoxFit.fill),
            ),
          ],
        ),
      ),
    );
  }
}
