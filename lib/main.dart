import 'package:flutter/material.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'package:logi_neko/features/course/ui/screen/course_main_screen.dart';
import 'package:logi_neko/features/subcription/screen/subcription.dart';

void main() async {
  await ApiService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogiNeko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        primarySwatch: Colors.purple,
      ),
      home: const CourseScreen(),
    );
  }
}
