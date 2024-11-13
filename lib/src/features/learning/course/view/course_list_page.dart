import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 추가
import '../../../../design/color_theme.dart';
import 'course_map_page.dart'; // Updated import

class CourseListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userUid = FirebaseAuth.instance.currentUser?.uid ?? ''; // 사용자 uid를 필드로 추가

  CourseListPage({super.key});

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('course').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['course_id'] = doc.id; // course_id 추가
        return data;
      }).toList();
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
                    course['course_id'],
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
      BuildContext context, String courseId, String courseName, String description) {
    return GestureDetector(
      onTap: () {
        navigateToCourseMap(context, courseId);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 3,
        child: SizedBox(
          height: 130, // 고정 높이 설정
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorTheme.colorPrimary,
                  ),
                  maxLines: 1, // 한 줄로 제한
                  overflow: TextOverflow.ellipsis, // 텍스트가 길 경우 말줄임표로 표시
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3, // 최대 3줄까지 표시
                  overflow: TextOverflow.ellipsis, // 넘칠 경우 말줄임표로 표시
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToCourseMap(BuildContext context, String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseMapPage(
          courseId: courseId,
          uid: userUid, // userUid 전달
        ),
      ),
    );
  }
}
