import 'package:flutter/material.dart';
import 'package:istudy_courses/theme/colors.dart';

class AppTheme{
  static ThemeData get light=> ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.light_blue,
    scaffoldBackgroundColor: AppColors.light_blue,
    //scaffoldBackgroundColor: attribute of ThemeData- xac dinh mau nen cho Scaffold- Widget provide standard user interface structure.
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.light_blue,
    primary: AppColors.light_blue,
    secondary: AppColors.purple),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.black
      ),
      
    ),
    //button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
backgroundColor: AppColors.purple,
foregroundColor: AppColors.white,
maximumSize: Size.fromHeight(48),
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
)
     )
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: AppColors.white)
    )
  );
}