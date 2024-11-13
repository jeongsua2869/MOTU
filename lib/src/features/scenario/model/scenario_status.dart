import 'package:motu/src/features/scenario/model/scenario_data.dart';
import 'package:motu/src/features/scenario/model/stock_portfolio.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';

class ScenarioStatus {
  ScenarioType selectedScenario;
  DateTime terminatedAt; // 앱 Terminate 시간
  DateTime endTime; // 시나리오 종료 시간
  int globalIndex; // 시나리오 전체 러닝타임 중 현재 시간
  ScenarioData runningScenario; // 현재 진행중인 시나리오
  StockPortfolio portfolio; // 보유 주식 포트폴리오

  ScenarioStatus({
    required this.selectedScenario,
    required this.terminatedAt,
    required this.endTime,
    required this.globalIndex,
    required this.runningScenario,
    required this.portfolio,
  });

  factory ScenarioStatus.fromJson(Map<String, dynamic> json) {
    return ScenarioStatus(
      selectedScenario: ScenarioType.values.firstWhere(
          (e) => e.toString().split('.').last == json['selectedScenario']),
      terminatedAt: DateTime.parse(json['terminatedAt']),
      endTime: DateTime.parse(json['endTime']),
      globalIndex: json['globalIndex'],
      runningScenario: ScenarioData.fromJson(json['runningScenario']),
      portfolio: StockPortfolio.fromJson(json['portfolio']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedScenario': selectedScenario.toString().split('.').last,
      'terminatedAt': terminatedAt.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'globalIndex': globalIndex,
      'runningScenario': runningScenario.toJson(),
      'portfolio': portfolio.toJson(),
    };
  }
}
