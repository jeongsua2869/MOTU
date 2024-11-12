import 'package:motu/src/features/scenario/model/stock_data.dart';
import 'package:motu/src/features/scenario/model/stock_financial.dart';
import 'package:motu/src/features/scenario/model/stock_news.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';

class ScenarioData {
  Map<String, String>
      stockCSVPaths; // 주식별 CSV 파일 경로, 예: {'관련주 A': '0_chart.csv'}
  Map<String, List<StockData>>
      storedAllStockData; // 시나리오 기간 동안의 전체 데이터를 미리 저장해놓는 변수
  Map<String, List<StockData>>
      visibleAllStockData; // 현재 진행중인 시나리오의 데이터를 미리 저장해놓는 변수

  Map<String, List<StockFinancial>> stockDataFinancial;
  Quarter currentQuarter; // 현재 분기
  StockFinancial q01Financial; // 1분기 재무재표
  StockFinancial q02Financial; // 2분기 재무재표
  StockFinancial q03Financial; // 3분기 재무재표
  StockFinancial q04Financial; // 4분기 재무재표
  List<StockNews> news;
  // 시나리오 기간 동안의 모든 뉴스

  ScenarioData({
    required this.stockCSVPaths,
    required this.storedAllStockData,
    required this.visibleAllStockData,
    required this.stockDataFinancial,
    required this.currentQuarter,
    required this.q01Financial,
    required this.q02Financial,
    required this.q03Financial,
    required this.q04Financial,
    required this.news,
  });

  factory ScenarioData.fromJson(Map<String, dynamic> json) {
    // storedAllStockData와 visibleAllStockData를 JSON에서 변환
    Map<String, List<StockData>> storedAllStockData =
        (json['storedAllStockData'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key,
          (value as List).map((item) => StockData.fromJson(item)).toList()),
    );

    Map<String, List<StockData>> visibleAllStockData =
        (json['visibleAllStockData'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key,
          (value as List).map((item) => StockData.fromJson(item)).toList()),
    );

    Map<String, List<StockFinancial>> stockDataFinancial =
        (json['stockDataFinancial'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
          key,
          (value as List)
              .map((item) => StockFinancial.fromJson(item))
              .toList()),
    );

    // 뉴스 데이터 처리
    List<StockNews> newsList =
        (json['news'] as List).map((item) => StockNews.fromJson(item)).toList();

    // stockCSVPaths 변환
    Map<String, String> stockCSVPaths =
        (json['stockCSVPaths'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value.toString()), // String으로 변환
    );

    return ScenarioData(
      stockCSVPaths: stockCSVPaths,
      storedAllStockData: storedAllStockData,
      visibleAllStockData: visibleAllStockData,
      stockDataFinancial: stockDataFinancial,
      currentQuarter: Quarter.values.firstWhere(
          (e) => e.toString().split('.').last == json['currentQuarter']),
      q01Financial: StockFinancial.fromJson(json['q01Financial']),
      q02Financial: StockFinancial.fromJson(json['q02Financial']),
      q03Financial: StockFinancial.fromJson(json['q03Financial']),
      q04Financial: StockFinancial.fromJson(json['q04Financial']),
      news: newsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockCSVPaths': stockCSVPaths,
      'storedAllStockData': storedAllStockData.map((key, value) =>
          MapEntry(key, value.map((stock) => stock.toJson()).toList())),
      'visibleAllStockData': visibleAllStockData.map((key, value) =>
          MapEntry(key, value.map((stock) => stock.toJson()).toList())),
      'stockDataFinancial': stockDataFinancial.map((key, value) =>
          MapEntry(key, value.map((financial) => financial.toJson()).toList())),
      'currentQuarter': currentQuarter.toString().split('.').last,
      'q01Financial': q01Financial.toJson(),
      'q02Financial': q02Financial.toJson(),
      'q03Financial': q03Financial.toJson(),
      'q04Financial': q04Financial.toJson(),
      'news': news.map((newsItem) => newsItem.toJson()).toList(),
    };
  }
}
