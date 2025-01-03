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
              title: "Basic Level",
              subtitle: "투자의 기초, 투자의 중요성과 투자 방법에 대한 기본적인 지식",
            ),
            const Gap(20),
            CourseTitle(
              context,
              asset: 'assets/images/learning/course/title/course2_title.png',
              title: "Standard Level",
              subtitle: "주식 투자의 기본, 주식 투자의 원리와 방법에 대한 기본적인 지식",
            ),
            const Gap(20),
            CourseTitle(
              context,
              asset: 'assets/images/learning/course/title/course3_title.png',
              title: "Advanced Level",
              subtitle: "투자의 전문가, 투자의 전문가가 되기 위한 전문적인 지식",
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Course1Page(),
          ),
        );
      },
      child: Stack(
        children: [
          Image.asset(
            asset,
            fit: BoxFit.cover,
            width: size.width,
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
      ),
    );
  }
}
