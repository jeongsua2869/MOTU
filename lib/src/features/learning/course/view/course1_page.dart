import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class Course1Page extends StatefulWidget {
  const Course1Page({super.key});

  @override
  State<Course1Page> createState() => _Course1PageState();
}

class _Course1PageState extends State<Course1Page> {
  int? _selectedButtonIndex;
  OverlayEntry? _overlayEntry;
  bool _isAutoScrolling = false;
  final ScrollController _scrollController = ScrollController();

  scrollListener() async {
    if (_isAutoScrolling) {
      return;
    }
    _overlayEntry?.remove();
    setState(() {
      _selectedButtonIndex = null;
      _overlayEntry = null;
    });
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      scrollListener();
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToButton(
      GlobalKey currentKey, GlobalKey nextKey, int currentIdx) async {
    _isAutoScrolling = true;

    final RenderBox renderBox =
        currentKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double buttonHeight = renderBox.size.height;
    final double targetOffset =
        offset.dy - (screenHeight / 4) + (buttonHeight / 2);

    final double newOffset = _scrollController.offset + targetOffset;

    // 스크롤 가능한 범위 내에서만 스크롤
    if (newOffset < _scrollController.position.minScrollExtent) {
      await _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (newOffset > _scrollController.position.maxScrollExtent) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // 여러 개의 GlobalKey를 관리하기 위한 Map
    final Map<int, GlobalKey> buttonKeys = {};

    return Scaffold(
      backgroundColor: const Color(0xFF41AD6E),
      body: GestureDetector(
        onTap: () {
          print("onTap");
          _overlayEntry?.remove();
          setState(() {
            _selectedButtonIndex = null;
            _overlayEntry = null;
          });
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const SliverAppBar(
              floating: true,
              snap: true,
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF41AD6E),
              title: Text("초심자를 위한 Basic 레벨"),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          body: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: 3,
            itemBuilder: (context, backgroundIndex) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            'assets/images/learning/course/background/course1_bg.png',
                            height: size.height,
                            fit: BoxFit.fitHeight,
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/images/learning/course/background/course1_bg.png',
                        height: size.height,
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ),
                  Positioned(
                    width: size.width,
                    child: Center(
                      child: DottedLine(
                        direction: Axis.vertical,
                        lineLength: size.height * 2,
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
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ListView.builder(
                      itemCount: 6,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, levelIndex) {
                        int currentIdx = backgroundIndex * 6 + levelIndex + 1;

                        // 버튼별 고유 키 생성 및 저장
                        buttonKeys[currentIdx] =
                            buttonKeys[currentIdx] ?? GlobalKey();

                        return Padding(
                          padding: levelIndex != 0
                              ? EdgeInsets.only(top: (size.height / 4))
                              : EdgeInsets.zero,
                          child: Padding(
                            padding: backgroundIndex != 0 && levelIndex == 0
                                ? EdgeInsets.only(top: 50.0 * backgroundIndex)
                                : EdgeInsets.zero,
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ElevatedButton(
                                    key: buttonKeys[currentIdx],
                                    onPressed: () {
                                      log("currentIdx: $currentIdx");
                                      log("backgroundIndex: $backgroundIndex / levelIndex: $levelIndex");

                                      _overlayEntry?.remove();

                                      if (buttonKeys[currentIdx + 1] == null) {
                                        setState(() {
                                          _selectedButtonIndex = currentIdx;
                                        });

                                        _showOverlay(
                                            context,
                                            buttonKeys[currentIdx]!,
                                            buttonKeys[currentIdx + 1]);
                                      } else {
                                        _scrollToButton(
                                                buttonKeys[currentIdx]!,
                                                buttonKeys[currentIdx + 1]!,
                                                currentIdx)
                                            .then((value) {
                                          log("scrollToButton done");
                                          setState(() {
                                            _selectedButtonIndex = currentIdx;
                                          });

                                          _showOverlay(
                                              context,
                                              buttonKeys[currentIdx]!,
                                              buttonKeys[currentIdx + 1]);
                                        });
                                      }
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showOverlay(
      BuildContext context, GlobalKey currentKey, GlobalKey? nextKey) {
    debugPrint("show overlay");

    final RenderBox currentRenderBox =
        currentKey.currentContext!.findRenderObject() as RenderBox;
    final Offset currentOffset = currentRenderBox.localToGlobal(Offset.zero);

    final double top = currentOffset.dy + currentRenderBox.size.height / 2;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 60,
        right: 60,
        top: nextKey == null ? top - 160 : top + 60, // 마지막 버튼일 경우 윗부분에 표현
        child: DefaultTextStyle(
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
                  decoration: const BoxDecoration(
                    color: Color(0xff006F2D),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: const Center(
                    child: AutoSizeText(
                      '1-1. 경제의 기초 이해하기',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      maxFontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: AutoSizeText(
                    '경제의 정의와 기본개념와 경제의 중요성에 대해 알아봅니다.',
                    maxFontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _isAutoScrolling = false;
  }
}
