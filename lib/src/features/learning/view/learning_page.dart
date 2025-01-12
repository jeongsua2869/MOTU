import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:motu/src/features/learning/course/view/course_selection_page.dart';
import 'package:motu/src/features/learning/news/view/news_list_screen.dart';
import 'package:motu/src/features/learning/term/view/term_main_page.dart';
import 'package:motu/src/features/learning/quiz/view/quiz_main.dart';
import '../../../common/view/widget/chatbot_fab.dart';
import '../column/view/article_list_screen.dart';

import '../../../design/color_theme.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("학습하기"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 0,
            ),
            child: Column(
              children: [
                // 코스 별 퀴즈 풀기 섹션
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/learning/course_main.png',
                      width: screenWidth,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CourseSelectionPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: ColorTheme.Purple1,
                          elevation: 0,
                        ),
                        child: const Text(
                          "코스 선택하기",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                const Gap(16),

                // Grid Section
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  childAspectRatio: 169 / 225,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermMainPage(),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/learning/method1.png',
                        width: screenWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizSelectionScreen(uid: auth.currentUser!.uid),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/learning/method2.png',
                        width: screenWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleListScreen(),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/learning/method3.png',
                        width: screenWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewsListPage(),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/learning/method4.png',
                        width: screenWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: const ChatbotFloatingActionButton(
          heroTag: 'learning',
        ),
      ),
    );
  }
}
