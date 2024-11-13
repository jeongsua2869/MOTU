import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../design/color_theme.dart';

class CourseMapScreen extends StatelessWidget {
  final String courseId;

  const CourseMapScreen({
    super.key,
    required this.courseId,
  });

  Future<Map<String, dynamic>?> fetchCourseData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('course').doc(courseId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('코스 맵'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchCourseData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No course data found.'));
          } else {
            final courseData = snapshot.data!;
            final stages = courseData['stages'] as List<dynamic>? ?? [];

            return SingleChildScrollView(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 배경 이미지를 여러 개 추가
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/course/course_bottom.png',
                        width: MediaQuery.of(context).size.width, // 전체 화면 너비
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        'assets/images/course/course_top.png',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              courseData['course_name'] ?? 'Unknown Course',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorTheme.colorPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(courseData['description'] ?? 'No description available.'),
                            Column(
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: buildStageCircle(),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 155,
                    left: 10,
                    child: Image.asset(
                      'assets/images/course/course_character.png',
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildStageCircle() {
    return Container(
      height: 60,
      width: 60,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
