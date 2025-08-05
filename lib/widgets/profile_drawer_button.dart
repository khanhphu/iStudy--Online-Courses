import 'package:flutter/material.dart';
import 'package:istudy_courses/theme/colors.dart';

class ProfileDrawerButton extends StatelessWidget {
  const ProfileDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 80, top: 10),
        child: IconButton(
          icon: CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.white,
            child: Icon(Icons.person, color: AppColors.purple),
          ),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
      ),
    );
  }
}
