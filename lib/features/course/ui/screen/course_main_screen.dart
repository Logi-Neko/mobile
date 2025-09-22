import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/course_bloc.dart';
import '../../repository/course_repository.dart';
import '../../dto/course.dart';

class CourseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseBloc(CourseRepositoryImpl())..add(LoadCourses()),
      child: CourseView(),
    );
  }
}

class CourseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<CourseBloc>().add(LoadCourses()),
          ),
        ],
      ),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CourseLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is CourseLoaded) {
            return ListView.builder(
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];
                return CourseCard(
                  course: course,
                  onTap: () => _viewCourseDetail(context, course.id),
                );
              },
            );
          }

          if (state is CourseDetailLoaded) {
            return CourseDetailView(course: state.course);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chưa có khóa học nào'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<CourseBloc>().add(LoadCourses()),
                  child: Text('Tải lại'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _viewCourseDetail(BuildContext context, int courseId) {
    context.read<CourseBloc>().add(LoadCourseById(courseId));
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            course.thumbnailUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(Icons.image),
            ),
          ),
        ),
        title: Text(
          course.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.play_lesson, size: 16),
                SizedBox(width: 4),
                Text('${course.totalLesson} lessons'),
                SizedBox(width: 16),
                if (course.isPremium) ...[
                  Icon(Icons.star, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text('\${course.price.toStringAsFixed(2)}'),
                ],
              ],
            ),
          ],
        ),
        trailing: course.isActive
            ? Icon(Icons.arrow_forward_ios)
            : Icon(Icons.lock, color: Colors.grey),
        onTap: course.isActive ? onTap : null,
      ),
    );
  }
}

class CourseDetailView extends StatelessWidget {
  final Course course;

  const CourseDetailView({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              course.thumbnailUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  course.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (course.isPremium)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            course.description,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              _InfoCard(
                icon: Icons.play_circle_outline,
                title: 'Bài học',
                value: '${course.totalLesson}',
              ),
              SizedBox(width: 16),
              _InfoCard(
                icon: Icons.access_time,
                title: 'Thời lượng',
                value: '~${course.totalLesson * 10}p',
              ),
              SizedBox(width: 16),
              _InfoCard(
                icon: Icons.attach_money,
                title: 'Giá',
                value: course.price > 0
                    ? '${course.price.toStringAsFixed(0)}đ'
                    : 'Miễn phí',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}