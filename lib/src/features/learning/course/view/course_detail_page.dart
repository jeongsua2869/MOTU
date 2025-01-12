import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:motu/src/features/learning/column/model/article.dart';
import 'package:motu/src/features/learning/course/model/status.dart';
import 'package:motu/src/features/learning/course/service/course_service.dart';
import 'package:motu/src/features/learning/course/view/content/course_column_page.dart';
import 'package:motu/src/features/learning/course/view/content/course_quiz_page.dart';
import 'package:motu/src/features/learning/course/view/content/course_temp_page.dart';
import 'package:motu/src/features/learning/course/view/content/course_term_card.dart';
import 'package:motu/src/features/learning/course/view/course_selection_page.dart';
import 'package:motu/src/features/learning/course/view/widget/course_utils.dart';
import 'package:motu/src/features/learning/course/view/widget/stage_summary_widget.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class CourseDetailPage extends StatefulWidget {
  final CourseLevel level;

  const CourseDetailPage({super.key, required this.level});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late Color coursePrimaryColor;
  late Color courseSecondaryColor;

  int? _selectedButtonIndex;
  OverlayEntry? _overlayEntry;
  bool _isAutoScrolling = false;
  final ScrollController _scrollController = ScrollController();

  // local method
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

  scrollListener2() {
    // 스크롤 위치가 리스트뷰의 끝에 도달하면 스크롤을 막음
    if (_scrollController.offset >= lastStagePosition) {
      _scrollController.position.jumpTo(lastStagePosition);
    }
  }

  double lastStagePosition = 0.0;

  double getButtonOffset(GlobalKey key) {
    final double scrollOffset = _scrollController.offset;
    // offset = Offset(offset.dx, offset.dy + scrollOffset);
    return scrollOffset;
  }

  @override
  void initState() {
    log("Init State CourseDetailPage");
    getCourseColorByLevel();
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ChangeNotifierProvider(
      create: (context) => CourseService(widget.level),
      child: Scaffold(
        backgroundColor: coursePrimaryColor,
        body: GestureDetector(
          onTap: () {
            _overlayEntry?.remove();
            setState(() {
              _selectedButtonIndex = null;
              _overlayEntry = null;
            });
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                foregroundColor: Colors.white,
                backgroundColor: coursePrimaryColor,
                title: CourseTitleText(widget.level),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            body: Consumer<CourseService>(builder: (context, service, child) {
              if (service.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // 여러 개의 GlobalKey를 관리하기 위한 Map
              final Map<int, GlobalKey> buttonKeys = {};

              // 전체 스테이지 개수를 받아와야 함
              int totalStageFromFirebase = service.totalStage;

              if (totalStageFromFirebase > service.completionList.length) {
                service.fetchUserCompletionListLength();
              }

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemCount: (totalStageFromFirebase / 6).ceil(),
                itemBuilder: (context, backgroundIndex) {
                  return Stack(
                    children: [
                      Column(
                        children: CourseBackgrounds(widget.level, size),
                      ),
                      Positioned(
                        width: size.width,
                        child: Center(
                          child: DottedLine(
                            direction: Axis.vertical,
                            lineLength: size.height * 2,
                            lineThickness: 10,
                            dashLength: 16,
                            dashColor: widget.level != CourseLevel.Standard
                                ? coursePrimaryColor
                                : courseSecondaryColor,
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
                          itemCount:
                              (backgroundIndex == totalStageFromFirebase - 1)
                                  ? totalStageFromFirebase % 6
                                  : 6,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, stageIndex) {
                            int currentIdx =
                                backgroundIndex * 6 + stageIndex + 1;

                            // 버튼별 고유 키 생성 및 저장
                            buttonKeys[currentIdx] =
                                buttonKeys[currentIdx] ?? GlobalKey();

                            if (totalStageFromFirebase == currentIdx &&
                                lastStagePosition == 0.0) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                lastStagePosition =
                                    getButtonOffset(buttonKeys[currentIdx]!) +
                                        ((1 + totalStageFromFirebase % 6) *
                                            (size.height / 2.5));
                              });

                              _scrollController.addListener(() {
                                scrollListener2();
                              });
                            }

                            return Padding(
                              padding: stageIndex != 0
                                  ? EdgeInsets.only(top: (size.height / 4))
                                  : EdgeInsets.zero,
                              child: Padding(
                                padding: backgroundIndex != 0 && stageIndex == 0
                                    ? EdgeInsets.only(
                                        top: 50.0 * backgroundIndex)
                                    : EdgeInsets.zero,
                                child: Padding(
                                  padding: totalStageFromFirebase - 1 ==
                                              backgroundIndex &&
                                          stageIndex - 1 == stageIndex
                                      ? const EdgeInsets.only(bottom: 50.0)
                                      : EdgeInsets.zero,
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (currentIdx <=
                                            totalStageFromFirebase)
                                          ElevatedButton(
                                            key: buttonKeys[currentIdx],
                                            onPressed: () {
                                              log("currentIdx: $currentIdx");
                                              log("backgroundIndex: $backgroundIndex / stageIndex: $stageIndex");

                                              _overlayEntry?.remove();

                                              if (buttonKeys[currentIdx + 1] ==
                                                  null) {
                                                setState(() {
                                                  _selectedButtonIndex =
                                                      currentIdx;
                                                });

                                                _showOverlay(
                                                  context,
                                                  buttonKeys[currentIdx]!,
                                                  buttonKeys[currentIdx + 1],
                                                  service,
                                                  currentIdx,
                                                );
                                              } else {
                                                _scrollToButton(
                                                        buttonKeys[currentIdx]!,
                                                        buttonKeys[
                                                            currentIdx + 1]!,
                                                        currentIdx)
                                                    .then((value) {
                                                  log("scrollToButton done");
                                                  setState(() {
                                                    _selectedButtonIndex =
                                                        currentIdx;
                                                  });

                                                  _showOverlay(
                                                    context,
                                                    buttonKeys[currentIdx]!,
                                                    buttonKeys[currentIdx + 1],
                                                    service,
                                                    currentIdx,
                                                  );
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              backgroundColor: currentIdx ==
                                                          1 ||
                                                      service.completionList[
                                                              currentIdx - 2] ==
                                                          true
                                                  ? widget.level !=
                                                          CourseLevel.Standard
                                                      ? coursePrimaryColor
                                                      : courseSecondaryColor
                                                  : const Color(0xffBDBDBD),
                                              fixedSize: const Size(80, 80),
                                              padding: EdgeInsets.zero,
                                              side: const BorderSide(
                                                color: Colors.white,
                                                width: 10,
                                              ),
                                            ),
                                            child: service.completionList[
                                                        currentIdx - 1] ==
                                                    true
                                                ? Image.asset(
                                                    "assets/images/learning/course/isCompleted.png",
                                                    width: 50,
                                                  )
                                                : Text(
                                                    currentIdx.toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                          )
                                        else
                                          const SizedBox.shrink(),
                                        if (_selectedButtonIndex == currentIdx)
                                          Positioned(
                                            top: -1,
                                            child:
                                                CourseCharacter(widget.level),
                                          ),
                                      ],
                                    ),
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
              );
            }),
          ),
        ),
      ),
    );
  }

  // local method
  void getCourseColorByLevel() {
    switch (widget.level) {
      case CourseLevel.Basic:
        coursePrimaryColor = const Color(0xFF41AD6E);
        courseSecondaryColor = const Color(0xFF006F2D);
        break;
      case CourseLevel.Standard:
        coursePrimaryColor = const Color(0xFF65C9FF);
        courseSecondaryColor = const Color(0xFF0083FB);
        break;
      case CourseLevel.Advanced:
        coursePrimaryColor = const Color(0xFF6D45B6);
        courseSecondaryColor = const Color(0xFF6D45B6);
        break;
    }
  }

  // local method
  void _showOverlay(
    BuildContext context,
    GlobalKey currentKey,
    GlobalKey? nextKey,
    CourseService service,
    int index,
  ) {
    debugPrint("show overlay");

    Status status = service.stageStatusList[index - 1];

    final RenderBox currentRenderBox =
        currentKey.currentContext!.findRenderObject() as RenderBox;
    final Offset currentOffset = currentRenderBox.localToGlobal(Offset.zero);

    final double top = currentOffset.dy + currentRenderBox.size.height / 2;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 60,
        right: 60,
        top: top + 60, // 마지막 버튼일 경우 윗부분에 표현
        child: GestureDetector(
          onTap: index == 1 || service.completionList[index - 2] == true
              ? () {
                  _overlayEntry?.remove();
                  setState(() {
                    _selectedButtonIndex = null;
                    _overlayEntry = null;
                  });

                  navigateToStage(service, index);
                }
              : () {
                  toastification.show(
                    autoCloseDuration: const Duration(seconds: 2),
                    alignment: Alignment.topCenter,
                    animationDuration: const Duration(milliseconds: 300),
                    showProgressBar: false,
                    context: context,
                    type: ToastificationType.warning,
                    title: const Text("알림"),
                    description: const Text("이전 스테이지를 먼저 학습해주세요!"),
                  );
                },
          child: StageSummaryWidget(
            color: courseSecondaryColor,
            title: "${status.stage}. ${status.title}",
            description: status.description,
            service: service,
            index: index,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _isAutoScrolling = false;
  }

  void navigateToStage(CourseService service, int index) {
    Status status = service.stageStatusList[index - 1];

    switch (status.type) {
      case "financial_column":
        debugPrint("navigate to financial column");
        Article article = Article(
          title: service.contentList[index - 1]['title'],
          content: service.contentList[index - 1]['content'],
          imageUrl: service.contentList[index - 1]['imageUrl'],
          topics: service.contentList[index - 1]['topics'],
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CourseColumnPage(
            article: article,
            service: service,
            index: index,
          );
        }));
        break;
      case "terminology":
        debugPrint("navigate to terminology");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CourseTermCard(
            index: index,
            courseService: service,
          );
        }));
        break;
      case "explanation":
        debugPrint("navigate to explanation");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CourseTempPage(index: index, service: service);
        }));
        break;
      case "quiz":
        debugPrint("navigate to quiz");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CourseQuizPage(index: index, service: service);
        }));
        break;
      default:
        break;
    }
  }

  // local method
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
}
