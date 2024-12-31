import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:motu/src/features/learning/course/view/course1_page.dart';

class CourseSelectionPage extends StatelessWidget {
  const CourseSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("코스 선택하기"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 24.0,
        ),
        child: Column(
          children: [
            CourseTitle(
              context,
              asset: 'assets/images/learning/course/title/course1_title.png',
              title: "초심자를 위한 첫걸음",
              subtitle: "경제와 주식 투자에 대한 기초 지식을 쉽고 체계적으로 배울 수 있는 코스",
            ),
            const Gap(20),
            CourseTitle(
              context,
              asset: 'assets/images/learning/course/title/course2_title.png',
              title: "경제적 자유를 위한 첫 시작",
              subtitle: "투자의 중요성 확립, 목돈을 위해 어떻게 투자를 해야할지에 대한 단계별 안내",
            ),
            const Gap(20),
            CourseTitle(
              context,
              asset: 'assets/images/learning/course/title/course3_title.png',
              title: "금리와 경제",
              subtitle: "경제와 주식 투자에 대한 기초 지식을 쉽고 체계적으로 배울 수 있는 코스",
            ),
          ],
        ),
      ),
    );
  }

  Widget CourseTitle(BuildContext context,
      {required String asset,
      required String title,
      required String subtitle}) {
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Course1Page(),
              ),
            );
          },
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            width: size.width,
          ),
        ),
        Positioned(
          left: 160,
          top: 40,
          width: size.width - 210,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Gap(8),
              AutoSizeText(
                subtitle,
                minFontSize: 10,
                maxFontSize: 12,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
