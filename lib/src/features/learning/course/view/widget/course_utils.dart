import 'package:flutter/material.dart';
import 'package:motu/src/features/learning/course/view/course_selection_page.dart';

Text CourseTitleText(CourseLevel level) {
  switch (level) {
    case CourseLevel.Basic:
      return const Text("초급");
    case CourseLevel.Standard:
      return const Text("중급");
    case CourseLevel.Advanced:
      return const Text("고급");
  }
}

// local - 변경될 일 없음
List<Image> CourseBackgrounds(CourseLevel level, Size size) {
  switch (level) {
    case CourseLevel.Basic:
      return [
        Image.asset(
          'assets/images/learning/course/background/course1_bg1.png',
          height: size.height,
          fit: BoxFit.fitHeight,
        ),
        Image.asset(
          'assets/images/learning/course/background/course1_bg2.png',
          height: size.height,
          fit: BoxFit.fitHeight,
        ),
      ];
    case CourseLevel.Standard:
      return [
        Image.asset(
          'assets/images/learning/course/background/course2_bg1.png',
          height: size.height,
          fit: BoxFit.fitHeight,
        ),
        Image.asset(
          'assets/images/learning/course/background/course2_bg2.png',
          height: size.height,
          fit: BoxFit.fitHeight,
        ),
      ];
    case CourseLevel.Advanced:
      return [
        Image.asset(
          'assets/images/learning/course/background/course3_bg1.png',
          height: size.height,
          fit: BoxFit.fitHeight,
        ),
        Image.asset(
          'assets/images/learning/course/background/course3_bg2.png',
          height: size.height,
          fit: BoxFit.fitHeight,
        ),
      ];
  }
}

// local - 변경될 일 없음
Image CourseCharacter(CourseLevel level) {
  switch (level) {
    case CourseLevel.Basic:
      return Image.asset(
        'assets/images/learning/course/character/course1_character.png',
        width: 60,
      );
    case CourseLevel.Standard:
      return Image.asset(
        'assets/images/learning/course/character/course2_character.png',
        width: 60,
      );
    case CourseLevel.Advanced:
      return Image.asset(
        'assets/images/learning/course/character/course3_character.png',
        width: 60,
      );
  }
}
