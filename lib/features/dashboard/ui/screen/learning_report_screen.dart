import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:logi_neko/core/router/app_router.dart';
import '../widgets/profile_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/subject_progress.dart';
import '../widgets/custom_bottom_navigation.dart';

class LearningReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.router.pushAndPopUntil(
              const HomeRoute(),
              predicate: (route) => false,
            ),
        ),
        title: Text(
          'Báo cáo học tập',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileCard(),
            SizedBox(height: 16),
            StatsRow(),
            SizedBox(height: 24),
            WeeklyChart(),
            SizedBox(height: 24),
            SubjectProgress(),
            SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}
