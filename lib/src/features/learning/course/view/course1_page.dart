import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class Course1Page extends StatefulWidget {
  const Course1Page({super.key});

  @override
  State<Course1Page> createState() => _Course1PageState();
}

class _Course1PageState extends State<Course1Page> {
  int? _selectedButtonIndex;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // 여러 개의 GlobalKey를 관리하기 위한 Map
    final Map<int, GlobalKey> buttonKeys = {};

    return Scaffold(
      backgroundColor: const Color(0xFF41AD6E),
      appBar: AppBar(
        title: const Text("초심자를 위한 첫걸음"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF41AD6E),
        shadowColor: Colors.transparent,
        elevation: 4,
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, backgroundIndex) {
          return Stack(
            children: [
              Image.asset(
                'assets/images/learning/course/background/course1_bg.png',
                height: size.height,
                fit: BoxFit.fitHeight,
              ),
              Positioned(
                width: size.width,
                child: Center(
                  child: DottedLine(
                    direction: Axis.vertical,
                    lineLength: size.height,
                    lineThickness: 10,
                    dashLength: 16,
                    dashColor: const Color(0xFF41AD6E),
                    dashRadius: 0,
                    dashGapLength: 16,
                    dashGapColor: Colors.transparent,
                    dashGapRadius: 0,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                bottom: 0,
                left: 0,
                right: 0,
                child: ListView.builder(
                  itemCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, levelIndex) {
                    int currentIdx = backgroundIndex * 3 + levelIndex + 1;

                    // 버튼별 고유 키 생성 및 저장
                    buttonKeys[currentIdx] =
                        buttonKeys[currentIdx] ?? GlobalKey();

                    return Padding(
                      padding: levelIndex != 0
                          ? EdgeInsets.only(top: (size.height / 4))
                          : EdgeInsets.zero,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ElevatedButton(
                              key: buttonKeys[currentIdx],
                              onPressed: () {
                                setState(() {
                                  _selectedButtonIndex = currentIdx;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: const Color(0xFF41AD6E),
                                fixedSize: const Size(80, 80),
                                padding: EdgeInsets.zero,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 10,
                                ),
                              ),
                              child: Text(
                                currentIdx.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              // child: Image.asset(
                              //   "assets/images/learning/course/isCompleted.png",
                              //   width: 50,
                              // ),
                            ),
                            if (_selectedButtonIndex == currentIdx)
                              Positioned(
                                top: -1,
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/learning/course/course1_character.png',
                                      width: 60,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
