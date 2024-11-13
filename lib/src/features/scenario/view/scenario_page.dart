import 'package:flutter/material.dart';
import 'package:motu/src/common/database.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';
import 'package:motu/src/features/scenario/view/content_page.dart';
import 'package:motu/src/features/scenario/view/intro_page.dart';
import 'package:provider/provider.dart';

class ScenarioPage extends StatelessWidget {
  const ScenarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isScenarioRunning = getScenarioIsRunning();

    if (isScenarioRunning) {
      ScenarioService scenarioService =
          Provider.of<ScenarioService>(context, listen: false);

      try {
        scenarioService.selectedScenario;
      } catch (e) {
        scenarioService.selectedScenario =
            getScenarioStatusData().selectedScenario;
      }
    }

    return Consumer<ScenarioService>(
      builder: (context, service, child) {
        return getScenarioIsRunning()
            ? ContentPage(service: service)
            : IntroPage(service: service);
      },
    );
  }
}
