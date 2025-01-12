import 'package:flutter/material.dart';
import 'package:motu/src/design/color_theme.dart';
import 'package:motu/src/features/learning/course/service/course_service.dart';
import 'package:motu/src/features/learning/course/view/course_detail_page.dart';
import 'package:provider/provider.dart';

class CourseTempPage extends StatelessWidget {
  final int index;
  final CourseService service;

  const CourseTempPage({
    super.key,
    required this.index,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.88,
            child: const Center(
              child: Text('현재 개발 중입니다.'),
            ),
          ),
          SizedBox(
            width: size.width * 0.9,
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
              },
              child: const Text('학습 완료'),
            ),
          ),
        ],
      ),
    );
  }
}
