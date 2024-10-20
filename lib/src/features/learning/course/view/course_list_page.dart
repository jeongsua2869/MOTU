import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../design/color_theme.dart';
import 'course_map_screen.dart';

class CourseListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CourseListPage({super.key});

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('course').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('코스 목록'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchCourses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No courses found.'));
            } else {
              final courses = snapshot.data!;
              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return buildCourseCard(
                    context,
                    course['course_name'] ?? 'Unknown Course',
                    course['description'] ?? 'No description available.',
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildCourseCard(
      BuildContext context, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorTheme.colorPrimary,
          ),
        ),
        subtitle: Text(description),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 2,
          ),
          onPressed: () {
            navigateToCourseMap(context, title, description);
          },
          child: const Text(
            '시작하기',
            style: TextStyle(color: ColorTheme.colorPrimary),
          ),
        ),
        onTap: () {
          navigateToCourseMap(context, title, description);
        },
      ),
    );
  }

  void navigateToCourseMap(
      BuildContext context, String courseTitle, String description) {
    List<String> stages = [];

    if (courseTitle == '기초 경제 코스') {
      stages = ['기초 개념', '경제 원리', '시장 구조', '거시 경제', '경제 실습'];
    } else if (courseTitle == '주식 투자의 기초') {
      stages = ['주식의 이해', '투자 전략', '포트폴리오 구성', '리스크 관리', '주식 실습'];
    } else if (courseTitle == '기초 금융 코스') {
      stages = ['금융의 이해', '자산 관리', '투자 기본', '금융 리스크', '금융 실습'];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseMapScreen(
            courseName: courseTitle,
            courseDescription: description,
            stages: stages),
      ),
    );
  }
}
