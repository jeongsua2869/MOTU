import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:motu/src/common/database.dart';
import 'package:motu/src/common/view/widget/bottom_nav_bar.dart';
import 'package:motu/src/common/view/widget/motu_button.dart';
import 'package:motu/src/design/color_theme.dart';
import 'package:motu/src/features/scenario/model/scenario_status.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';
import 'package:provider/provider.dart';
import 'package:motu/src/common/service/navigation_service.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  late ScenarioService _service;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _service = Provider.of<ScenarioService>(context, listen: false);
    log("Service 정상적으로 인식");
  }

  @override
  void initState() {
    super.initState();

    // 빌드가 완료된 후에 실행할 작업
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isScenarioRunning = getScenarioIsRunning();

      if (isScenarioRunning) {
        log('🌟 시나리오 진행 중, 앱이 종료된 후 다시 실행됨');

        // ScenarioService service =
        //     Provider.of<ScenarioService>(context, listen: false);
        ScenarioStatus currentStatus = getScenarioStatusData();

        if (currentStatus.endTime.isBefore(DateTime.now())) {
          log('🌟 시나리오 종료 시간이 지났습니다.');

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return FinishDialog(context, currentStatus, _service);
            },
          );
        } else {
          log('🌟 시나리오 종료 시간이 지나지 않았습니다. 시나리오 정보를 업데이트합니다.');

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return ContinueDialog(context, currentStatus, _service);
            },
          );
        }

        await _service.updateCurrentStatusWhenOpenApp(currentStatus);

        clearScenarioStatusData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = context.watch<NavigationService>();
    return Scaffold(
      body: IndexedStack(
        index: navigationService.selectedIndex,
        children: navigationService.screens,
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

Widget ContinueDialog(BuildContext context, ScenarioStatus currentStatus,
    ScenarioService service) {
  Size size = MediaQuery.of(context).size;

  Duration elapseTime = DateTime.now().difference(currentStatus.terminatedAt);
  service.returnRate = currentStatus.portfolio.returnRate;

  log(currentStatus.runningScenario.toJson().toString());
  log(currentStatus.portfolio.toJson().toString());

  return AlertDialog(
    backgroundColor: Colors.white,
    content: Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 8,
          right: 8,
          child: SizedBox(
            child: Row(
              children: [
                Expanded(
                  child: MotuNormalButton(
                    context,
                    color: ColorTheme.Purple1,
                    text: "이어서 진행하러 가기",
                    onPressed: () {
                      Navigator.of(context).pop();

                      Provider.of<NavigationService>(context, listen: false)
                          .goToScenario();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: size.height * 0.4,
          width: size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                const SizedBox(height: 24),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      Text(
                        "현재 ${service.getScenarioTitle(currentStatus.selectedScenario)}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "시나리오 진행 중",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                Consumer<ScenarioService>(builder: (context, service, child) {
                  if (service.totalEarningRate.toStringAsFixed(2) == "0.00" ||
                      currentStatus.portfolio.totalEarningRate
                              .toStringAsFixed(2) ==
                          service.totalEarningRate.toStringAsFixed(2)) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Gif(
                            image: const AssetImage(
                                'assets/images/gif/common.gif'),
                            autostart: Autostart.loop,
                            fit: BoxFit.fill,
                          ),
                          const Text("진행상황을 불러오고 있습니다"),
                        ],
                      ),
                    );
                  } else {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "앱 종료한 지 ${elapseTime.inMinutes}분 경과",
                            style: const TextStyle(fontSize: 16),
                          ),
                          // Text(
                          //   "현재 시점 ${service.currentStockTime}",
                          //   style: const TextStyle(fontSize: 16),
                          // ),
                          const SizedBox(height: 16),
                          Text(
                            "앱 종료 당시 수익률 : ${currentStatus.portfolio.totalEarningRate.toStringAsFixed(2)}%",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "현 시점 수익률 : ${service.totalEarningRate.toStringAsFixed(2)}%",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "시나리오 남은 시간 : ${service.remainingTime.inMinutes}분",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                }),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget FinishDialog(BuildContext context, ScenarioStatus currentStatus,
    ScenarioService service) {
  Size size = MediaQuery.of(context).size;

  return AlertDialog(
    backgroundColor: Colors.white,
    content: Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 8,
          right: 8,
          child: SizedBox(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Gif(
                        image: const AssetImage('assets/images/gif/common.gif'),
                        autostart: Autostart.loop,
                        fit: BoxFit.contain,
                        height: 80,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "결과 보고서 불러오는 중...",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: size.height * 0.4,
          width: size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                const SizedBox(height: 24),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      Text(
                        "${service.getScenarioTitle(currentStatus.selectedScenario)} 시나리오가",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "종료되었어요! 🎉🎉",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "앱이 꺼져있던 사이에 시나리오가 종료되었어요!",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "시나리오 결과보고서를 보러 가볼까요?",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
