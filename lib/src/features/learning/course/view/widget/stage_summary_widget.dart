import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:motu/src/features/learning/course/service/course_service.dart';

Widget StageSummaryWidget({
  required Color color,
  required String title,
  required String description,
  required CourseService service,
  required int index,
}) {
  return DefaultTextStyle(
    style: const TextStyle(color: Colors.black, fontSize: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white, // 전체 배경색을 화이트로
        borderRadius: BorderRadius.circular(15.0),
      ),
      height: 100,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: index == 1 || service.completionList[index - 2] == true
                  ? color
                  : const Color(0xffBDBDBD),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: Center(
              child: AutoSizeText(
                title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                maxLines: 1,
                maxFontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: AutoSizeText(
              description,
              maxFontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}
