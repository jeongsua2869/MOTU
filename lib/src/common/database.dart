import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:motu/src/features/scenario/model/scenario_data.dart';
import 'package:motu/src/features/scenario/model/scenario_status.dart';
import 'package:motu/src/features/scenario/model/stock_portfolio.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';

void setOnboardingDone() {
  final box = Hive.box(name: 'onboarding');
  box.put('done', true);
  log("🐝 로컬DB 저장 : ${box.get('done')}");
}

bool getOnboardingDone() {
  final box = Hive.box(name: 'onboarding');
  bool result = box.get('done') ?? false;
  // log("🐝 로컬DB 조회 : $result");
  return result;
}

void initHiveDB() {
  final box = Hive.box(name: 'scenario');
  log("🐝 로컬DB 초기화 : $box");
}

void setScenarioIsRunning(bool bool) async {
  final box = Hive.box(name: 'scenario');
  box.put('isRunning', bool);
  log("🐝 로컬DB 저장 : ${box.get('isRunning')}");
}

bool getScenarioIsRunning() {
  final box = Hive.box(name: 'scenario');
  bool result = box.get('isRunning') ?? false;
  // log("🐝 로컬DB 조회 : $result");
  return result;
}

void setScenarioStatusData(ScenarioService service) {
  final box = Hive.box(name: 'scenario');
  print("initial balance: ${service.originBalance}");
  StockPortfolio portfolio = StockPortfolio(
    initialBalance: service.originBalance,
    totalPurchasePrice: service.totalPurchasePrice,
    totalRatingPrice: service.totalRatingPrice,
    unrealizedPnL: service.unrealizedPnL,
    realizedPnL: service.realizedPnL,
    returnRate: service.returnRate,
    totalEarningRate: service.totalEarningRate,
    investStocks: service.investStocks,
    earningRates: service.earningRates,
    investRecords: service.investRecords,
  );

  ScenarioData data = ScenarioData(
    stockCSVPaths: service.stockCSVPaths,
    storedAllStockData: service.storedAllStockData,
    visibleAllStockData: service.visibleAllStockData,
    stockDataFinancial: service.stockDataFinancial,
    currentQuarter: service.currentQuarter,
    q01Financial: service.q01Financial,
    q02Financial: service.q02Financial,
    q03Financial: service.q03Financial,
    q04Financial: service.q04Financial,
    news: service.news,
  );

  ScenarioStatus status = ScenarioStatus(
    selectedScenario: service.selectedScenario,
    terminatedAt: DateTime.now(),
    endTime: service.checkScenarioEndTime(),
    globalIndex: service.globalIndex,
    runningScenario: data,
    portfolio: portfolio,
  );

  box.put('status', status.toJson());

  log("⏰ 시나리오 종료 시간 : ${status.endTime}");
  log("🐝 로컬DB에 Scenario Status 저장");
}

void clearScenarioStatusData() {
  final box = Hive.box(name: 'scenario');
  box.delete('status');
  log("🐝 로컬DB에 Scenario Status 삭제");
}

ScenarioStatus getScenarioStatusData() {
  final box = Hive.box(name: 'scenario');
  final result = box.get('status');
  ScenarioStatus status = ScenarioStatus.fromJson(result);

  return status;
}
