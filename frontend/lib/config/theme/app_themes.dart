import 'package:flutter/material.dart';
<<<<<<< HEAD

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme()
=======
import 'app_colors.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
>>>>>>> fbce432 (Finish PR (project setup))
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
<<<<<<< HEAD
    color: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0XFF8B8B8B)),
    titleTextStyle: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
=======
    color: AppColors.background,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      fontFamily: 'Muli',
    ),
>>>>>>> fbce432 (Finish PR (project setup))
  );
}