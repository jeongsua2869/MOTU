import 'package:flutter/material.dart';
import 'package:motu/src/design/color_theme.dart';
import 'package:motu/src/features/learning/course/service/course_service.dart';
import 'package:motu/src/features/learning/course/view/content/course_quiz_page.dart';
import 'package:motu/src/features/learning/course/view/course_detail_page.dart';
import 'package:motu/src/features/learning/quiz/view/incorrect_answers_screen.dart';
import 'package:motu/src/features/learning/quiz/view/widget/widget/circle_indicator.dart';
import 'package:provider/provider.dart';
import 'package:speech_balloon/speech_balloon.dart';

class CourseQuizCompletionPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> incorrectAnswers;
  final int index;
  final CourseService service;

  const CourseQuizCompletionPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.incorrectAnswers,
    required this.index,
    required this.service,
  });

  String getFeedbackMessage(double percentage) {
    if (percentage < 50) {
      return '더 공부가 필요해요!';
    } else if (percentage >= 50 && percentage < 90) {
      return '잘했어요!\n조금만 더 공부하면 되겠는걸요?';
    } else if (percentage >= 90 && percentage < 100) {
      return '정말 잘했어요!';
    } else {
      return '완벽해요!';
    }
  }

  String getFeedbackImage() {
    double percentage = (score / totalQuestions) * 100;

    if (percentage < 50) {
      return 'assets/images/character/sad_panda.png';
    } else if (percentage >= 50 && percentage < 90) {
      return 'assets/images/character/default_panda.png';
    } else {
      return 'assets/images/character/congratulation_panda.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = score >= totalQuestions * 0.9;
    double percentage = (score / totalQuestions) * 100;

    return Scaffold(
      backgroundColor: ColorTheme.colorWhite,
      appBar: AppBar(
        backgroundColor: ColorTheme.colorWhite,
        title: const Text(
          '퀴즈 완료',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorTheme.colorNeutral,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Transform.scale(
                      scale: 3,
                      child: CircularScoreIndicator(
                        score: score,
                        totalQuestions: totalQuestions,
                        isCompleted: isCompleted,
                      ),
                    ),
                    const SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          getFeedbackImage(),
                          width: 100,
                        ),
                        const SizedBox(width: 20),
                        SpeechBalloon(
                          nipLocation: NipLocation.left,
                          color: ColorTheme.colorPrimary,
                          width: 160,
                          height: 50,
                          borderRadius: 10,
                          child: Center(
                            child: Text(
                              getFeedbackMessage(percentage),
                              style: const TextStyle(
                                fontSize: 12,
                                color: ColorTheme.colorWhite,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.colorPrimary,
                  foregroundColor: ColorTheme.colorWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  if (percentage < 90) {
                    // 다시 시도
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseQuizPage(
                            index: index,
                            service: service,
                          ),
                        ));
                  } else {
                    // 학습 종료
                    await service.updateUserCourseCompletion(index);

                    Navigator.pop(context);

                    // 새로운 페이지로 푸쉬합니다.
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: service,
                            child: CourseDetailPage(level: service.level),
                          ),
                        ));
                  }
                },
                child: Text(percentage < 90 ? '다시 시도하기' : '학습 종료'),
              ),
            ),
            const SizedBox(height: 20),
            if (incorrectAnswers.isNotEmpty)
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.colorDisabled,
                    foregroundColor: ColorTheme.colorWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    debugPrint('복습');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IncorrectAnswersScreen(
                          incorrectAnswers: incorrectAnswers,
                        ),
                      ),
                    );
                  },
                  child: const Text('틀린 문제 복습하기'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
