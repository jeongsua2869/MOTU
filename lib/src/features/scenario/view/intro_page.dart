import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';
import 'package:motu/src/features/scenario/view/widget/tutorial_popup.dart';
import 'package:motu/src/design/color_theme.dart';
import 'package:motu/src/common/view/widget/chatbot_fab.dart';
import 'dart:developer' as dev;

import 'package:provider/provider.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScenarioService service =
        Provider.of<ScenarioService>(context, listen: false);

    void showTutorialPopup(ScenarioType type) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: TutorialPopup(type: type),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('주제'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 24,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: ScenarioType.values.length,
                itemBuilder: (context, index) {
                  final scenario = ScenarioType.values[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(service.getScenarioTitle(scenario),
                            style: const TextStyle(
                                color: ColorTheme.White,
                                fontWeight: FontWeight.bold)),
                        tileColor: ColorTheme.Purple1,
                        minVerticalPadding: 36,
                        contentPadding: const EdgeInsets.only(left: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onTap: () {
                          dev.log(
                              "📈 ${service.getScenarioTitle(scenario)} 시나리오 시작");
                          service.setSelectedScenario(scenario);

                          showTutorialPopup(scenario);
                        },
                      ),
                      const Gap(20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          const ChatbotFloatingActionButton(heroTag: 'scenario'),
    );
  }
}
