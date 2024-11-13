import 'package:motu/src/features/scenario/model/invest_record.dart';

class StockPortfolio {
  int initialBalance; // 시나리오 시작 당시 자본금
  int totalPurchasePrice; // 총 매수 금액
  int totalRatingPrice; // 총 평가 금액
  int unrealizedPnL; // 평가 손익
  int realizedPnL; // 실현 손익
  double returnRate = 0; // 수익률
  double totalEarningRate = 0; // 전체 수익률
  Map<String, List<int>> investStocks; // [주식명: [보유량, 매입단가 * 보유량]]
  Map<String, double> earningRates; // [주식명: 수익률]
  List<InvestRecord> investRecords; // 투자 기록

  StockPortfolio({
    required this.initialBalance,
    required this.totalPurchasePrice,
    required this.totalRatingPrice,
    required this.unrealizedPnL,
    required this.realizedPnL,
    required this.returnRate,
    required this.totalEarningRate,
    required this.investStocks,
    required this.earningRates,
    required this.investRecords,
  });

  factory StockPortfolio.fromJson(Map<String, dynamic> json) {
    return StockPortfolio(
      initialBalance: json['initialBalance'],
      totalPurchasePrice: json['totalPurchasePrice'],
      totalRatingPrice: json['totalRatingPrice'],
      unrealizedPnL: json['unrealizedPnL'],
      realizedPnL: json['realizedPnL'],
      returnRate: json['returnRate'],
      totalEarningRate: json['totalEarningRate'],
      investStocks: (json['investStocks'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          List<int>.from(value), // List<int>로 변환
        ),
      ),
      earningRates: (json['earningRates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toDouble()), // double로 변환
      ),
      investRecords: (json['investRecords'] as List)
          .map((item) => InvestRecord.fromJson(item))
          .toList(), // InvestRecord 객체로 변환
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initialBalance': initialBalance,
      'totalPurchasePrice': totalPurchasePrice,
      'totalRatingPrice': totalRatingPrice,
      'unrealizedPnL': unrealizedPnL,
      'realizedPnL': realizedPnL,
      'returnRate': returnRate.isNaN ? 0.0 : returnRate, // NaN 체크,
      'totalEarningRate':
          totalEarningRate.isNaN ? 0.0 : totalEarningRate, // NaN 체크,
      'investStocks': investStocks.map((key, value) => MapEntry(key, value)),
      'earningRates': earningRates.map((key, value) {
        // NaN 체크 후 기본값으로 대체
        return MapEntry(key, value.isNaN ? 0.0 : value);
      }),
      'investRecords': investRecords.map((record) => record.toJson()).toList(),
    };
  }
}
