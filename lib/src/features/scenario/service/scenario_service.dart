import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:motu/src/common/service/notifications.dart';
import 'package:motu/src/features/scenario/model/invest_record.dart';
import 'package:motu/src/features/scenario/model/scenario_status.dart';
import 'package:motu/src/features/scenario/model/stock_financial.dart';
import 'package:motu/src/features/scenario/model/stock_info.dart';
import 'package:motu/src/common/database.dart';
import 'package:motu/src/common/util/isolate_helper.dart';
import 'package:motu/src/common/util/util.dart';
import 'package:http/http.dart' as http;
import 'package:motu/src/features/scenario/view/widget/order/custom_date_format.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/stock_data.dart';
import '../model/stock_news.dart';

// 시나리오 타입
enum ScenarioType {
  disease,
  secondaryBattery,
  festival,
}

// 거래 유형
enum TransactionType {
  buy,
  sell,
}

// 분기
enum Quarter {
  first,
  second,
  third,
  fourth,
}

class ScenarioService extends ChangeNotifier with IsolateHelperMixin {
  Function? onNavigate; // 페이지 이동 함수
  Function? updateUserBalanceWhenFinish; // 사용자 잔액 업데이트 함수

  //* MARK: - 시나리오 관련 변수

  // 현재 시나리오 진행 중 여부
  bool isRunning = false;

  // 글로벌 타이머 및 인덱스
  Timer? _globalTimer;
  // 시작 인덱스 -> 거래일 기준 1년 뒤
  int _globalIndex = 20;
  int get globalIndex => _globalIndex;

  // 시나리오 남은 시간 타이머
  Timer? _remainingTimeTimer;
  Duration _remainingTime = Duration.zero;
  Duration get remainingTime => _remainingTime;

  // 타이머 상태 추적을 위한 변수
  bool _isTimerPaused = false;

  Duration? _pausedRemainingTime;
  int? _pausedGlobalIndex;

  // 시나리오 종료 시간
  late DateTime endTime;

  // 하루당 시간 간격
  int millisecondsPeriod = 4000;

  // 최신 주가 날짜
  late DateTime currentStockTime;

  // 관련주 드롭다운
  String selectedStock = '관련주 A';

  // 선택한 시나리오 타입
  late ScenarioType selectedScenario;

  // 관련주 이름 옵션 리스트
  List<String> stockOptions = [
    '관련주 A',
    '관련주 B',
    '관련주 C',
    '관련주 D',
    '관련주 E',
  ];

  // 관련주 주식 데이터 STORAGE CSV 경로
  Map<String, String> stockCSVPaths = {}; // 예: {'관련주 A': '0_chart.csv'}

  // 저장되어 있는 모든 관련주 주식 데이터
  final Map<String, List<StockData>> storedAllStockData = {};

  // 보여지고 있는 현재 관련주 주식 데이터
  final Map<String, List<StockData>> visibleAllStockData = {};

  // 보여지고 있는 현재 주식 데이터
  List<StockData> _visibleStockData = [];
  List<StockData> get visibleStockData => _visibleStockData;

  // 시나리오 초기 자금 저장
  int originBalance = 0;

  // 선택한 관련주 설명 텍스트 저장
  String selectedStockDescription = "";

  //* MARK: - 주식 정보 관련 변수

  final Map<String, List<StockInfo>> _stockDataInfo = {};
  get stockDataInfo => _stockDataInfo;

  StockInfo currentStockInfo = StockInfo(
    date: DateTime.now(),
    close: 0,
    change: 0,
    percentChange: 0,
    eps: 0,
    per: 0,
    bps: 0,
    pbr: 0,
    dividendPerShare: 0,
    dividendYield: 0,
    marketCap: 0,
  );

  final Map<String, List<StockFinancial>> _stockDataFinancial = {};
  get stockDataFinancial => _stockDataFinancial;

  Quarter currentQuarter = Quarter.first;

  StockFinancial q01Financial = StockFinancial(
    year: 1900,
    quarter: '',
    revenue: -1,
    netIncome: -1,
    totalAssets: -1,
    totalLiabilities: -1,
  );
  StockFinancial q02Financial = StockFinancial(
    year: 1900,
    quarter: '',
    revenue: -1,
    netIncome: -1,
    totalAssets: -1,
    totalLiabilities: -1,
  );
  StockFinancial q03Financial = StockFinancial(
    year: 1900,
    quarter: '',
    revenue: -1,
    netIncome: -1,
    totalAssets: -1,
    totalLiabilities: -1,
  );
  StockFinancial q04Financial = StockFinancial(
    year: 1900,
    quarter: '',
    revenue: -1,
    netIncome: -1,
    totalAssets: -1,
    totalLiabilities: -1,
  );

  Map<String, dynamic> _allNews = {};
  Map<String, dynamic> get allNews => _allNews;
  List<String> _allNewsKeys = [];
  List<String> get allNewsKeys => _allNewsKeys;
  final List<StockNews> _news = [];
  List<StockNews> get news => _news;

  //* MARK: - 시나리오 관련 함수
  Duration actualElapsed = Duration.zero;

  void pauseTimers() {
    if (!_isTimerPaused) {
      _isTimerPaused = true;

      // remainingTimeTimer 정지
      _remainingTimeTimer?.cancel();

      // globalTimer 정지
      _globalTimer?.cancel();

      // 정확한 시점 저장
      _pausedRemainingTime = _remainingTime;
      _pausedGlobalIndex = _globalIndex;

      actualElapsed = _timerStartTime.difference(_lastTickTime);

      if (actualElapsed.inMilliseconds > 4000) {
        actualElapsed =
            Duration(milliseconds: actualElapsed.inMilliseconds % 4000);
      }
      if (actualElapsed.inMilliseconds < 0) {
        actualElapsed =
            Duration(milliseconds: actualElapsed.inMilliseconds * -1);
      }

      dev.log("${actualElapsed.inMilliseconds}ms");

      notifyListeners();
    }
  }

  Future<void> resumeTimers() async {
    if (_isTimerPaused) {
      _isTimerPaused = false;

      _globalIndex = _pausedGlobalIndex!;

      // remainingTimeTimer 재개
      startRemainingTimeTimer(isResume: true);

      // globalTimer 재개
      // CancelableOperation으로 래핑
      await Future.delayed(
        Duration(milliseconds: actualElapsed.inMilliseconds),
        () {
          // 여기에 실행하고 싶은 특정 함수 호출
          _updateAllVisibleData();

          // 현재 주식 종목 정보 업데이트
          updateCurrentStockInfo();

          // 현재 보유한 주식의 총 투자 금액 업데이트
          updateTotalRatingPrice();

          // 현재 보유한 주식의 총 평가 금액 업데이트
          updateUnrealizedPnL();

          // 현재 보유한 주식들의 각각 수익률 업데이트
          setStockEarningRates();

          // 현재 보유한 주식의 총 수익률 업데이트
          setTotalEarningRate();

          // 현재 주식 종목 정보 업데이트
          checkFinancialInfoUpdate();

          // 뉴스 데이터 업데이트
          checkNewsUpdate();
        },
      );

      startDataUpdate();

      notifyListeners();
    }
  }

  // 시나리오 시작할 때 남은시간 타이머 시작
  void startRemainingTimeTimer({bool isResume = false}) {
    // back
    dev.log("⏱️ 시나리오 남은 시간 타이머 시작");

    if (storedAllStockData.isEmpty) return;

    // 전체 남은 시간 계산
    int totalMilliseconds =
        ((storedAllStockData[selectedStock]!.length - 1 - _globalIndex) *
                millisecondsPeriod)
            .toInt();

    if (isResume) {
      // 일시정지된 시간만큼 빼기
      _remainingTime = _pausedRemainingTime!;
    } else {
      _remainingTime = Duration(milliseconds: totalMilliseconds);
    }

    // 0.1초마다 남은 시간을 감소시키는 타이머
    _remainingTimeTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_remainingTime.inMilliseconds > 0) {
        _remainingTime -= const Duration(milliseconds: 100);

        notifyListeners();
      } else {
        _remainingTimeTimer?.cancel();
      }
    });
  }

  DateTime checkScenarioEndTime() {
    int totalMilliseconds =
        ((storedAllStockData[selectedStock]!.length - 1 - _globalIndex) *
                millisecondsPeriod)
            .toInt();

    // 밀리초를 초로 변환
    int totalSeconds = (totalMilliseconds / 1000).floor();

    // 분과 초 계산
    int minutes = (totalSeconds / 60).floor();
    int seconds = totalSeconds % 60;

    // 시 계산
    int hours = (minutes / 60).floor();
    minutes = minutes % 60; // 남은 분 계산

    DateTime endDateTime = DateTime.now().add(Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    ));

    return endDateTime;
  }

  DateTime _timerStartTime = DateTime.now(); // 타이머 시작 시간
  DateTime _lastTickTime = DateTime.now(); // 마지막 틱 시간

  // 시나리오 시간 흘러가도록 처리
  void startDataUpdate() {
    _timerStartTime = DateTime.now();

    // back
    _globalTimer =
        Timer.periodic(Duration(milliseconds: millisecondsPeriod), (timer) {
      // 현재 틱 시간 저장
      _lastTickTime = DateTime.now();
      print("${_lastTickTime.difference(_timerStartTime).inMilliseconds}ms");

      _updateAllVisibleData();

      // 현재 주식 종목 정보 업데이트
      updateCurrentStockInfo();

      // 현재 보유한 주식의 총 투자 금액 업데이트
      updateTotalRatingPrice();

      // 현재 보유한 주식의 총 평가 금액 업데이트
      updateUnrealizedPnL();

      // 현재 보유한 주식들의 각각 수익률 업데이트
      setStockEarningRates();

      // 현재 보유한 주식의 총 수익률 업데이트
      setTotalEarningRate();

      // 현재 주식 종목 정보 업데이트
      checkFinancialInfoUpdate();

      // 뉴스 데이터 업데이트
      checkNewsUpdate();

      notifyListeners();
    });
    notifyListeners();
  }

  void checkFinancialInfoUpdate() {
    if (q01Financial.year == 1900) {
      q01Financial.year = currentStockTime.year;
      q02Financial.year = currentStockTime.year;
      q03Financial.year = currentStockTime.year;
      q04Financial.year = currentStockTime.year;
    }

    // 분기 별 정보 업데이트
    int month = currentStockTime.month;
    if (month >= 1 && month <= 3) {
      currentQuarter = Quarter.first;
    } else if (month >= 4 && month <= 6) {
      currentQuarter = Quarter.second;
    } else if (month >= 7 && month <= 9) {
      currentQuarter = Quarter.third;
    } else {
      currentQuarter = Quarter.fourth;
    }
    updateQuarterFinancialData();
  }

  void checkNewsUpdate() {
    List<String> toRemove = [];
    for (String newsDate in _allNewsKeys) {
      DateTime newsDateTime = DateTime.parse(newsDate);
      String formattedNewsDate =
          '${newsDateTime.year.toString().padLeft(4, '0')}-${newsDateTime.month.toString().padLeft(2, '0')}-${newsDateTime.day.toString().padLeft(2, '0')}';

      if (newsDateTime.isBefore(currentStockTime)) {
        toRemove.add(newsDate);

        Timestamp timestamp = _allNews[formattedNewsDate]["date"];
        DateTime date = timestamp.toDate();

        StockNews news = StockNews(
          title: _allNews[formattedNewsDate]["title"],
          content: _allNews[formattedNewsDate]["content"],
          imageURL: _allNews[formattedNewsDate]["imageUrl"],
          date: DateTime(date.year, date.month, date.day),
        );

        _news.add(news);
        LocalPushNotifications.showSimpleNotification(
          title:
              "${news.date.year}년 ${news.date.month}월 ${news.date.day}일 뉴스 업데이트",
          body: news.title,
          payload: "news",
        );

        notifyListeners();
      }
    }
    for (String key in toRemove) {
      _allNewsKeys.remove(key);
    }
  }

  // 시나리오 시간 정지되도록 처리
  void stopAllTimer() {
    _globalTimer?.cancel();
    _globalTimer = null;

    _remainingTimeTimer?.cancel();
    _remainingTimeTimer = null;
  }

  // 모든 주가 데이터 업데이트, millisecondPeriod마다 호출
  Future<void> _updateAllVisibleData() async {
    bool isScenarioEnd = true;

    for (final stock in stockOptions) {
      if (_globalIndex < storedAllStockData[stock]!.length - 1) {
        visibleAllStockData[stock] =
            storedAllStockData[stock]!.sublist(0, _globalIndex + 1);
        isScenarioEnd = false;
      } else {
        visibleAllStockData[stock] = storedAllStockData[stock]!;
      }
    }

    if (isScenarioEnd == false) {
      _globalIndex++; // 다음 데이터 추가
    }

    // 선택된 주식의 visibleStockData 업데이트
    _updateVisibleStockData();

    // 시나리오 사이클 종료 시 처리
    handleScenarioEnd(isScenarioEnd);

    notifyListeners();
  }

  void handleScenarioEnd(bool isScenarioEnd) {
    if (isScenarioEnd) {
      dev.log('👏👏👏👏 시나리오 종료');
      stopAllTimer(); // 모든 데이터를 표시했으면 타이머 중지

      setScenarioIsRunning(false);

      clearScenarioStatusData();

      if (updateUserBalanceWhenFinish != null) {
        dev.log("💵 사용자 잔액 업데이트");
        updateUserBalanceWhenFinish!();
      }
      if (onNavigate != null) {
        dev.log("🚀 페이지 이동");
        onNavigate!();
      }
    }
  }

  // MARK: 시나리오 시작
  Future<void> initializeData() async {
    dev.log("Data initialized");

    // 모든 관련주 데이터 불러오기
    await _loadAllData();

    _updateAllVisibleData();

    // 관련주 설명 업데이트
    await getStockDescription();

    // 데이터 업데이트 타이머 시작 (Back)
    startDataUpdate();

    // 남은 시간 타이머 시작 (Back)
    startRemainingTimeTimer();

    // 불러온 데이터를 바탕으로 초기 데이터 설정 (252일 데이터)
    _initializeVisibleData();

    notifyListeners();
  }

  void updateCurrentStatusWhenResume(ScenarioStatus status) {
    Duration spendTime = DateTime.now().difference(status.terminatedAt);

    _globalIndex = status.globalIndex +
        (spendTime.inMilliseconds / millisecondsPeriod).floor();

    dev.log("과거 global index: ${status.globalIndex}");
    dev.log("현재 global index: $_globalIndex");

    _updateAllVisibleData();

    // 현재 주식 종목 정보 업데이트
    updateCurrentStockInfo();

    // 현재 보유한 주식의 총 투자 금액 업데이트
    updateTotalRatingPrice();

    // 현재 보유한 주식의 총 평가 금액 업데이트
    updateUnrealizedPnL();

    // 현재 보유한 주식들의 각각 수익률 업데이트
    setStockEarningRates();

    // 현재 보유한 주식의 총 수익률 업데이트
    setTotalEarningRate();

    // 현재 주식 종목 정보 업데이트
    checkFinancialInfoUpdate();

    // 뉴스 데이터 업데이트
    checkNewsUpdate();

    // 전체 남은 시간 계산
    int totalMilliseconds =
        ((storedAllStockData[selectedStock]!.length - 1 - _globalIndex) *
                millisecondsPeriod)
            .toInt();
    _remainingTime = Duration(milliseconds: totalMilliseconds);

    notifyListeners();
  }

  Future<void> updateCurrentStatusWhenOpenApp(ScenarioStatus status) async {
    Duration spendTime = DateTime.now().difference(status.terminatedAt);

    _globalIndex = status.globalIndex +
        (spendTime.inMilliseconds / millisecondsPeriod).floor();

    dev.log("과거 global index: ${status.globalIndex}");
    dev.log("현재 global index: $_globalIndex");

    // 모든 관련주 데이터 불러오기
    await _loadAllData();

    totalPurchasePrice = status.portfolio.totalPurchasePrice;
    totalRatingPrice = status.portfolio.totalRatingPrice;
    unrealizedPnL = status.portfolio.unrealizedPnL;
    realizedPnL = status.portfolio.realizedPnL;
    returnRate = status.portfolio.returnRate;
    totalEarningRate = status.portfolio.totalEarningRate;

    investStocks = status.portfolio.investStocks;
    earningRates = status.portfolio.earningRates;
    investRecords = status.portfolio.investRecords;

    _updateAllVisibleData();

    // 관련주 설명 업데이트
    await getStockDescription();

    // 데이터 업데이트 타이머 시작 (Back)
    startDataUpdate();

    // 남은 시간 타이머 시작 (Back)
    startRemainingTimeTimer();

    // 불러온 데이터를 바탕으로 초기 데이터 설정 (252일 데이터)
    _initializeVisibleData();

    notifyListeners();
  }

  // 모든 관련주 데이터 불러오기
  Future<void> _loadAllData() async {
    List<String> storageFiles = [];
    try {
      final storage = FirebaseStorage.instance.ref();
      final Reference chartPathRef;
      switch (selectedScenario) {
        case ScenarioType.disease:
          chartPathRef = storage.child('scenario/covid/chart/');
          break;
        case ScenarioType.secondaryBattery:
          chartPathRef = storage.child('scenario/secondary_battery/chart/');
        case ScenarioType.festival:
          chartPathRef = storage.child('scenario/festival/chart/');
          break;
      }
      final ListResult result = await chartPathRef.listAll();

      for (var item in result.items) {
        storageFiles.add(item.name);
      }

      // 랜덤 선택을 위한 Random 객체 생성
      Random random = Random();

      // 리스트에서 랜덤으로 5개 선택
      List<String> randomSelectedFiles = List.from(storageFiles)
        ..shuffle(random);
      randomSelectedFiles = randomSelectedFiles.sublist(0, 5);
      dev.log('Random selected files: $randomSelectedFiles');

      stockCSVPaths = {
        "관련주 A": randomSelectedFiles[0],
        "관련주 B": randomSelectedFiles[1],
        "관련주 C": randomSelectedFiles[2],
        "관련주 D": randomSelectedFiles[3],
        "관련주 E": randomSelectedFiles[4],
      };

      dev.log('Loaded stock CSV paths: $stockCSVPaths');

      List<Future<void>> futures = [];

      for (var stock in stockOptions) {
        // stock을 인자로 직접 전달
        futures.add(_loadDataForStock(stock));
        futures.add(_loadInfoForStock(stock));
        futures.add(_loadFinancialForStock(stock));
      }
      futures.add(_loadNewsForStock());

      await Future.wait(futures);
    } catch (e) {
      dev.log('Unexpected error: $e');
    }
  }

  List<StockData> _parseCSVToStockData(List<List<dynamic>> csvData) {
    // 첫 번째 행(헤더)을 제거합니다.
    csvData.removeAt(0);
    return csvData.map((row) => StockData.fromList(row)).toList();
  }

  List<StockInfo> _parseCSVToStockInfo(List<List<dynamic>> csvData) {
    // 첫 번째 행(헤더)을 제거합니다.
    csvData.removeAt(0);

    return csvData.map((row) => StockInfo.fromList(row)).toList();
  }

  List<StockFinancial> _parseCSVToStockFinancial(List<List<dynamic>> csvData) {
    // 첫 번째 행(헤더)을 제거합니다.
    csvData.removeAt(0);
    return csvData.map((row) => StockFinancial.fromList(row)).toList();
  }

  Future<void> _loadDataForStock(String stock) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      Reference pathRef;
      switch (selectedScenario) {
        case ScenarioType.disease:
          pathRef =
              storageRef.child("scenario/covid/chart/${stockCSVPaths[stock]!}");
          break;
        case ScenarioType.secondaryBattery:
          pathRef = storageRef.child(
              "scenario/secondary_battery/chart/${stockCSVPaths[stock]!}");
          break;
        case ScenarioType.festival:
          pathRef = storageRef
              .child("scenario/festival/chart/${stockCSVPaths[stock]!}");
          break;
      }

      final url = await pathRef.getDownloadURL();
      final response = await http.get(Uri.parse(url)); // http.get 사용

      if (response.statusCode == 200) {
        String csvString = response.body;

        // CSV Data
        List<List<dynamic>> csvStockData =
            const CsvToListConverter().convert(csvString, eol: '\n');

        storedAllStockData[stock] = _parseCSVToStockData(csvStockData);
        dev.log('Loaded CSV file for $stock chart');

        notifyListeners();
      } else {
        throw Exception('Failed to load CSV file for $stock');
      }
    } catch (e) {
      dev.log('Error loading DATA for $stock : $e');
    }
  }

  Future<void> _loadInfoForStock(String stock) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      Reference pathRef;
      String stockID = stockCSVPaths[stock]![0];
      switch (selectedScenario) {
        case ScenarioType.disease:
          pathRef = storageRef.child("scenario/covid/info/${stockID}_info.csv");
          break;
        case ScenarioType.secondaryBattery:
          pathRef = storageRef
              .child("scenario/secondary_battery/info/${stockID}_info.csv");
          break;
        case ScenarioType.festival:
          pathRef =
              storageRef.child("scenario/festival/info/${stockID}_info.csv");
          break;
      }

      final url = await pathRef.getDownloadURL();
      final response = await http.get(Uri.parse(url)); // http.get 사용

      if (response.statusCode == 200) {
        String csvString = response.body;
        // CSV Data
        List<List<dynamic>> csvStockData =
            const CsvToListConverter().convert(csvString, eol: '\n');
        _stockDataInfo[stock] = _parseCSVToStockInfo(csvStockData);
        dev.log('Loaded CSV file for $stock info');

        notifyListeners();
      } else {
        throw Exception('Failed to load CSV file for $stock');
      }
    } catch (e) {
      dev.log('Error loading INFO for $stock : $e');
    }
  }

  Future<void> _loadFinancialForStock(String stock) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      Reference pathRef;
      String stockID = stockCSVPaths[stock]![0];
      switch (selectedScenario) {
        case ScenarioType.disease:
          pathRef = storageRef
              .child("scenario/covid/financial/${stockID}_financial.csv");
          break;
        case ScenarioType.secondaryBattery:
          pathRef = storageRef.child(
              "scenario/secondary_battery/financial/${stockID}_financial.csv");
          break;
        case ScenarioType.festival:
          pathRef = storageRef
              .child("scenario/festival/financial/${stockID}_financial.csv");
          break;
      }

      final url = await pathRef.getDownloadURL();
      final response = await http.get(Uri.parse(url)); // http.get 사용

      if (response.statusCode == 200) {
        String csvString = response.body;

        // CSV Data
        List<List<dynamic>> csvStockData =
            const CsvToListConverter().convert(csvString, eol: '\n');

        _stockDataFinancial[stock] = _parseCSVToStockFinancial(csvStockData);

        dev.log('Loaded CSV file for $stock financial');

        notifyListeners();
      } else {
        throw Exception('Failed to load CSV file for $stock');
      }
    } catch (e) {
      dev.log('Error loading FINANCIAL for $stock : $e');
    }
  }

  Future<void> _loadNewsForStock() async {
    try {
      final instance = FirebaseFirestore.instance;
      final collection = instance.collection('scenario');
      late DocumentSnapshot doc;

      switch (selectedScenario) {
        case ScenarioType.disease:
          doc = await collection.doc('covid').get();
          break;
        case ScenarioType.secondaryBattery:
          doc = await collection.doc('second_battery').get();
          break;
        case ScenarioType.festival:
          doc = await collection.doc('festival').get();
          break;
      }

      if (doc.exists) {
        _allNews = doc.data() as Map<String, dynamic>;
        _allNewsKeys = _allNews.keys.toList();

        dev.log('Loaded firestore news data');
        notifyListeners();
      }
    } catch (e) {
      dev.log('Error loading news : $e');
    }
  }

  void _initializeVisibleData() {
    dev.log("stockdata length: ${storedAllStockData[selectedStock]!.length}");

    for (final stock in stockOptions) {
      if (storedAllStockData.containsKey(stock)) {
        final stockData = storedAllStockData[stock]!;
        final int endIndex = stockData.length < 21 ? stockData.length : 21;
        visibleAllStockData[stock] = stockData.sublist(0, endIndex);
      } else {
        // 해당 주식 데이터가 없는 경우 빈 리스트로 초기화
        visibleAllStockData[stock] = [];
      }
    }
  }

  //* 시간 관리하는 부분 (Back)
  void _updateVisibleStockData() {
    dev.log("$selectedStock 업데이트");
    if (visibleAllStockData.containsKey(selectedStock)) {
      _visibleStockData = visibleAllStockData[selectedStock]!;

      // 데이터가 비어있지 않은지 확인
      currentStockTime = visibleStockData.last.x;

      stockDateTimeCategoryAxis = DateTimeCategoryAxis(
        dateFormat: CustomDateFormat('custom'),
        interval: 3,
        majorGridLines: const MajorGridLines(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        minimum: visibleStockData.first.x,
        maximum: visibleStockData.last.x,
      );
      volumeDateTimeCategoryAxis = DateTimeCategoryAxis(
        dateFormat: CustomDateFormat('custom'),
        interval: 3,
        isVisible: false,
        majorGridLines: const MajorGridLines(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        minimum: visibleStockData.first.x,
        maximum: visibleStockData.last.x,
      );
    } else {
      _visibleStockData = [];
      dev.log('Warning: No data found for $selectedStock');
    }

    notifyListeners();
  }

  //* MARK: - 변수 SETTER

  void setSelectedScenario(ScenarioType scenario) {
    selectedScenario = scenario;
    notifyListeners();
  }

  // 드롭다운으로 관련주 변경
  Future<void> setSelectedStock(String value) async {
    selectedStock = value;
    dev.log("변경한 관련주: ${stockCSVPaths[selectedStock]![0]}");

    // 선택된 주식의 visibleStockData 업데이트
    _updateAllVisibleData();

    // 관련주 설명 업데이트
    await getStockDescription();

    notifyListeners();
  }

  void setOriginBalance(int value) {
    originBalance = value;
    notifyListeners();
  }

  // MARK: - dispose
  @override
  void dispose() {
    stopAllTimer();
    super.dispose();
  }

  // MARK: - 고정된 텍스트를 보여주는 함수

  String explainTextbyCell(String cell) {
    String explainText = "";
    if (cell == "매출액") {
      explainText =
          "매출액은 기업이 판매한 상품이나 용역에 대한 대가로 받은 금액입니다. \n\n매출액 = 판매량 x 판매가격";
    }
    if (cell == "영업이익") {
      explainText =
          "영업이익은 기업이 영업활동을 통해 얻은 이익입니다. \n\n영업이익 = 매출액 - 매출원가 - 판매비와 관리비";
    }
    if (cell == "당기순이익") {
      explainText = "당기순이익은 기업이 당기에 얻은 순이익입니다. \n\n당기순이익 = 영업이익 - 이자비용 - 세금";
    }
    if (cell == "자산총계") {
      explainText = "자산총계는 기업이 보유한 자산의 총액입니다. \n\n자산총계 = 유동자산 + 비유동자산";
    }
    if (cell == "부채총계") {
      explainText = "부채총계는 기업이 부담해야 하는 총부채의 총액입니다. \n\n부채총계 = 유동부채 + 비유동부채";
    }
    return explainText;
  }

  //* MARK: - SynchoronizedChart 관련

  late DateTimeCategoryAxis stockDateTimeCategoryAxis;
  late DateTimeCategoryAxis volumeDateTimeCategoryAxis;

  int stockPriceLabelLength = 5;

  //*---------------------------------------------------------------------------
  //* MARK: - 관련주 당 주식 종목 정보

  Future<void> getStockDescription() async {
    String stockID = stockCSVPaths[selectedStock]!.split('_').first;

    final doc = await FirebaseFirestore.instance
        .collection('stock_info')
        .doc(stockID)
        .get();

    if (doc.exists) {
      selectedStockDescription = "$selectedStock는 ${doc['description']}";
    } else {
      selectedStockDescription = '해당 관련주 정보 없음';
    }
  }

  void setStockDataInfo(String stock, List<StockInfo> stockInfo) {
    _stockDataInfo[stock] = stockInfo;
    notifyListeners();
  }

  void updateCurrentStockInfo() {
    if (_stockDataInfo.containsKey(selectedStock)) {
      List<StockInfo> stockInfo = _stockDataInfo[selectedStock]!;
      currentStockInfo = stockInfo.firstWhere(
        (element) => element.date == currentStockTime,
        orElse: () => StockInfo(
          date: DateTime.now(),
          close: 0,
          change: 0,
          percentChange: 0,
          eps: 0,
          per: 0,
          bps: 0,
          pbr: 0,
          dividendPerShare: 0,
          dividendYield: 0,
          marketCap: 0,
        ),
      );
    } else {
      currentStockInfo = StockInfo(
        date: DateTime.now(),
        close: 0,
        change: 0,
        percentChange: 0,
        eps: 0,
        per: 0,
        bps: 0,
        pbr: 0,
        dividendPerShare: 0,
        dividendYield: 0,
        marketCap: 0,
      );
    }

    notifyListeners();
  }

  //* MARK: 관련주 당 분기별 정보

  void setStockDataFinancial(
      String stock, List<StockFinancial> stockFinancial) {
    _stockDataFinancial[stock] = stockFinancial;
    notifyListeners();
  }

  StockFinancial resetQuarterFinancialData() {
    return StockFinancial(
      year: currentStockTime.year - 1,
      quarter: '',
      revenue: -1,
      netIncome: -1,
      totalAssets: -1,
      totalLiabilities: -1,
    );
  }

  void updateQuarterFinancialData() {
    List<StockFinancial> thisYearData;

    switch (currentQuarter) {
      case Quarter.first:
        thisYearData = _stockDataFinancial[selectedStock]!
            .where((data) => data.year == currentStockTime.year - 1)
            .toList();
        q04Financial = thisYearData.firstWhere(
          (element) => element.quarter == 'Q12',
          orElse: () => StockFinancial(
            year: currentStockTime.year,
            quarter: 'Q12',
            revenue: -1,
            netIncome: -1,
            totalAssets: -1,
            totalLiabilities: -1,
          ),
        );
        break;
      case Quarter.second:
        thisYearData = _stockDataFinancial[selectedStock]!
            .where((data) => data.year == currentStockTime.year)
            .toList();
        q01Financial = thisYearData.firstWhere(
          (element) => element.quarter == 'Q03',
          orElse: () => StockFinancial(
            year: currentStockTime.year,
            quarter: 'Q03',
            revenue: -1,
            netIncome: -1,
            totalAssets: -1,
            totalLiabilities: -1,
          ),
        );

        break;
      case Quarter.third:
        thisYearData = _stockDataFinancial[selectedStock]!
            .where((data) => data.year == currentStockTime.year)
            .toList();
        q02Financial = thisYearData.firstWhere(
          (element) => element.quarter == 'Q06',
          orElse: () => StockFinancial(
            year: currentStockTime.year,
            quarter: 'Q06',
            revenue: -1,
            netIncome: -1,
            totalAssets: -1,
            totalLiabilities: -1,
          ),
        );

        break;
      case Quarter.fourth:
        thisYearData = _stockDataFinancial[selectedStock]!
            .where((data) => data.year == currentStockTime.year)
            .toList();
        q03Financial = thisYearData.firstWhere(
          (element) => element.quarter == 'Q09',
          orElse: () => StockFinancial(
            year: currentStockTime.year,
            quarter: 'Q09',
            revenue: -1,
            netIncome: -1,
            totalAssets: -1,
            totalLiabilities: -1,
          ),
        );

        break;
    }
  }

  //*---------------------------------------------------------------------------
  //* MARK: - 뉴스탭 관련

  List<StockNews> sortNewsList() {
    return List<StockNews>.from(news)
      ..sort((a, b) {
        if (a.isRead == b.isRead) return 0;
        return a.isRead ? 1 : -1;
      });
  }

  int checkUnreadNews() {
    int unreadCount = 0;
    for (StockNews news in _news) {
      if (!news.isRead) {
        unreadCount++;
      }
    }
    return unreadCount;
  }

  // MARK: - 보유 주식 데이터 (포트폴리오)
  int totalPurchasePrice = 0; // 총 구매 금액

  int totalRatingPrice = 0; // 평가 금액

  int unrealizedPnL = 0; // 평가 손익

  int realizedPnL = 0; // 실현 손익

  double returnRate = 0; // 수익률

  double totalEarningRate = 0; // 전체 수익률

  // [주식명: [보유량, 매입단가 * 보유량]]
  Map<String, List<int>> _investStocks = {
    '관련주 A': [0, 0],
    '관련주 B': [0, 0],
    '관련주 C': [0, 0],
    '관련주 D': [0, 0],
    '관련주 E': [0, 0],
  };

  Map<String, double> _earningRates = {
    '관련주 A': 0,
    '관련주 B': 0,
    '관련주 C': 0,
    '관련주 D': 0,
    '관련주 E': 0,
  };

  List<InvestRecord> _investRecords = [];

  set investStocks(Map<String, List<int>> value) {
    _investStocks = value;
    notifyListeners();
  }

  set earningRates(Map<String, double> value) {
    _earningRates = value;
    notifyListeners();
  }

  set investRecords(List<InvestRecord> value) {
    _investRecords = value;
    notifyListeners();
  }

  Map<String, double> get earningRates => _earningRates;

  // 전체 수익률 계산
  void setTotalEarningRate() {
    double profitContribution = 0;
    int totalInvestPrice = 0;
    if (totalPurchasePrice == 0) {
      totalEarningRate = 0;
    } else {
      for (String stock in _investStocks.keys) {
        double earningRate = _earningRates[stock]!;
        if (earningRate.isNaN) {
          earningRate = 0;
        }
        profitContribution += _investStocks[stock]![1] * earningRate;
        totalInvestPrice += _investStocks[stock]![1];
      }

      totalEarningRate = profitContribution / totalInvestPrice;
    }
  }

  Map<String, List<int>> get investStocks => _investStocks;
  void setInvestStocks(String stock, TransactionType type, int amount) {
    if (type == TransactionType.buy) {
      _investStocks[stock]![0] += amount;
    } else {
      _investStocks[stock]![0] -= amount;
    }

    int price = visibleAllStockData[stock]!.last.close.toInt(); // 현재가
    if (type == TransactionType.buy) {
      _investStocks[stock]![1] += price * amount;
    } else {
      _investStocks[stock]![1] -= price * amount;
    }

    dev.log('보유 주식: $_investStocks');

    notifyListeners();
  }

  bool checkInvested() {
    for (String stock in _investStocks.keys) {
      if (_investStocks[stock]![0] != 0) {
        return true;
      }
    }
    return false;
  }

  List<InvestRecord> get investRecords => _investRecords;
  void setInvestRecords(InvestRecord record) {
    _investRecords.add(record);

    notifyListeners();
  }

  void updateTotalRatingPrice() {
    int total = 0;
    for (String stock in _investStocks.keys) {
      total += _investStocks[stock]![0] *
          visibleAllStockData[stock]!.last.close.toInt();
    }
    totalRatingPrice = total;

    notifyListeners();
  }

  void updateTotalPurchasePrice() {
    int total = 0;
    for (InvestRecord record in _investRecords) {
      if (record.type == TransactionType.buy) {
        total += record.price * record.amount;
      }
    }
    totalPurchasePrice = total;

    notifyListeners();
  }

  void updateUnrealizedPnL() {
    if (totalRatingPrice == 0) {
      unrealizedPnL = 0;
      return;
    }

    int total = 0;
    for (String stock in _investStocks.keys) {
      int currentValue = _investStocks[stock]![0] *
          visibleAllStockData[stock]!.last.close.toInt(); // 현재가
      int purchaseValue = _investStocks[stock]![1]; // 매입단가 * 보유량
      total += (currentValue - purchaseValue);
    }

    unrealizedPnL = total;

    notifyListeners();
  }

  // 실현손익 업데이트
  // 실현손익 = 매도 당시 가격 (현재가 * 매도종목수) - 매수 당시 가격 (매수가 * 매수종목수)
  void updateRealizedPnL(InvestRecord record) {
    int currentPrice = record.price; // 현재가
    int purchasePrice;
    try {
      purchasePrice = _investStocks[record.stock]![1] ~/
          _investStocks[record.stock]![0]; // 매입단가
    } catch (e) {
      if (e is UnsupportedError) {
        purchasePrice = 0; // 기본값 설정
        dev.log("Error: Division by zero for stock: ${record.stock}");
      } else {
        rethrow;
      }
    }

    realizedPnL = (currentPrice - purchasePrice) * record.amount;

    notifyListeners();
  }

  String currentPriceStr() {
    if (totalRatingPrice - totalPurchasePrice == 0) {
      return '0';
    } else {
      if (totalRatingPrice - totalPurchasePrice > 0) {
        return '+${Formatter.format(totalRatingPrice - totalPurchasePrice)}';
      } else {
        return Formatter.format(totalRatingPrice - totalPurchasePrice.abs());
      }
    }
  }

  String currentPercentStr() {
    if (totalRatingPrice - totalPurchasePrice == 0) {
      return '0.0%';
    } else {
      double percent =
          (totalRatingPrice - totalPurchasePrice) / totalPurchasePrice * 100;
      if (percent > 0) {
        return '+${percent.toStringAsFixed(1)}%';
      } else {
        return '${percent.toStringAsFixed(1)}%';
      }
    }
  }

  int getRemainStockToBalance() {
    int total = 0;
    for (String stock in _investStocks.keys) {
      total += investStocks[stock]![0] *
          visibleAllStockData[stock]!.last.close.toInt();
    }

    return total;
  }

  void setStockEarningRates() {
    for (String stock in _investStocks.keys) {
      int totalInvestPrice = 0;
      for (InvestRecord record in _investRecords) {
        if (record.stock == stock) {
          if (record.type == TransactionType.buy) {
            totalInvestPrice += record.price * record.amount;
          } else {
            totalInvestPrice -= record.price * record.amount;
          }
        }
      }
      int totalValuationPrice =
          (investStocks[stock]![0] * visibleAllStockData[stock]!.last.close)
              .toInt();

      double earningRate =
          (totalValuationPrice - totalInvestPrice) / totalInvestPrice * 100;

      _earningRates[stock] = earningRate;
    }
  }

  // MARK: - 시나리오 초기화
  void resetAllData() {
    dev.log("Resetting all data");

    _globalIndex = 20;
    // _globalIndex = 0;

    visibleAllStockData.clear();
    visibleStockData.clear();
    storedAllStockData.clear();
    _stockDataInfo.clear();
    _stockDataFinancial.clear();
    _news.clear();
    _allNews.clear();
    _allNewsKeys.clear();

    stockCSVPaths.clear();
    selectedStock = '관련주 A';
    // isChangeStock = false;

    _investRecords.clear();
    _investStocks.forEach((key, value) {
      _investStocks[key] = [0, 0];
    });

    totalPurchasePrice = 0;
    totalRatingPrice = 0;
    unrealizedPnL = 0;
    realizedPnL = 0;

    stopAllTimer();

    clearScenarioStatusData();

    notifyListeners();
  }

  // TODO: MARK: 파베에서 가져오도록 수정해야함
  // 시나리오 주제 제목 불러오기
  String getScenarioTitle(ScenarioType type) {
    switch (type) {
      case ScenarioType.disease:
        return '질병과 주식';
      case ScenarioType.secondaryBattery:
        return '2차전지와 주식';
      case ScenarioType.festival:
        return '2024 한동대학교 가을축제 LISTEN';
    }
  }

  String timeoverCommentMsg() {
    String comment = "";

    switch (selectedScenario) {
      case ScenarioType.disease:
        comment =
            "코로나는 우리 일상에 많은 변화를 가져다주었어요.\n\n전 세계에 큰 변화를 불러온 코로나는 경제/주가에 어떤 영향을 미쳤는지 함께 알아볼까요?";
        break;
      case ScenarioType.secondaryBattery:
        comment = "전기차 시대가 도래하면서 2차전지 관련주들이 주목받고 있어요.\n\n"
            "2차전지 관련주들의 주가는 어떻게 변화했는지 함께 알아볼까요?";
        break;
      case ScenarioType.festival:
        comment = "다들 축제 재밌게 즐기고 계신가요?\n\n"
            "MOTU앱을 통해 재밌게 주식 투자를 배워보시는 건 어떨까요?";
    }

    return comment;
  }
}
