import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motu/src/features/learning/column/model/article.dart';
import 'package:motu/src/features/learning/column/view/article_detail_screen.dart';
import '../../../../design/color_theme.dart';
import '../../quiz/view/quiz_screen.dart';

class CourseMapPage extends StatefulWidget {
  final String courseId;
  final String uid; // uid를 추가

  const CourseMapPage({
    super.key,
    required this.courseId,
    required this.uid, // uid를 필수로 설정
  });

  @override
  _CourseMapPageState createState() => _CourseMapPageState();
}

class _CourseMapPageState extends State<CourseMapPage> {
  String? selectedContent;

  Future<Map<String, dynamic>?> fetchCourseData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('course')
          .doc(widget.courseId)
          .get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> navigateToArticleDetailScreen(String contentId) async {
    try {
      DocumentSnapshot articleDoc = await FirebaseFirestore.instance
          .collection('financial_column')
          .doc(contentId)
          .get();

      if (articleDoc.exists) {
        final articleData = articleDoc.data() as Map<String, dynamic>;
        final article = Article(
          title: articleData['title'],
          imageUrl: articleData['imageUrl'],
          content: articleData['content'],
          topics: List<String>.from(articleData['topics'] ?? []),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      } else {
        print('Article not found.');
      }
    } catch (e) {
      print("Error navigating to ArticleDetailScreen: $e");
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
            final stages = courseData['stage'] as List<dynamic>? ?? [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity, // 화면 가로 크기로 설정
                    color: const Color(0xFFFFF1D1),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          selectedContent ?? courseData['description'] ?? 'No description available.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: List.generate(stages.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedContent = '${stages[index]['content_id']} - ${stages[index]['type']}';
                            });

                            final type = stages[index]['type'];
                            final contentId = stages[index]['content_id'];

                            if (type == 'quiz') {
                              navigateToQuizScreen(contentId);
                            } else if (type == 'financial_column') {
                              navigateToArticleDetailScreen(contentId);
                            }
                          },
                          child: buildStageCircle(index + 1),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void navigateToQuizScreen(String quizId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          collectionName: quizId,
          uid: widget.uid, // uid 전달
        ),
      ),
    );
  }

  Widget buildStageCircle(int number) {
    return Container(
      height: 80,
      width: 80,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
