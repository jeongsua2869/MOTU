class StockFinancial {
  int year; // 연도
  String quarter; // 분기
  double revenue; // 수익
  double netIncome; // 순이익
  double totalAssets; // 총 자산
  double totalLiabilities; // 총 부채

  StockFinancial({
    required this.year,
    required this.quarter,
    required this.revenue,
    required this.netIncome,
    this.totalAssets = 0, // 기본값 0
    this.totalLiabilities = 0, // 기본값 0
  });

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'quarter': quarter,
      'revenue': revenue,
      'netIncome': netIncome,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
    };
  }

  // JSON에서 객체로 변환
  factory StockFinancial.fromJson(Map<String, dynamic> json) {
    return StockFinancial(
      year: json['year'],
      quarter: json['quarter'],
      revenue: _toDouble(json['revenue']),
      netIncome: _toDouble(json['netIncome']),
      totalAssets: _toDouble(json['totalAssets']),
      totalLiabilities: _toDouble(json['totalLiabilities']),
    );
  }

  factory StockFinancial.fromList(List<dynamic> data) {
    return StockFinancial(
      year: data[0] is int ? data[0] : int.parse(data[0].toString()),
      quarter: data[1].toString(),
      revenue: _toDouble(data[2]),
      netIncome: _toDouble(data[3]),
      totalAssets: _toDouble(data[4]),
      totalLiabilities: _toDouble(data[5]),
    );
  }

  List<dynamic> toList() {
    return [
      year,
      quarter,
      revenue,
      netIncome,
      totalAssets,
      totalLiabilities,
    ];
  }

  static double _toDouble(dynamic value) {
    // 값이 null이거나 변환이 불가능할 경우 기본값 0.0 반환
    return (value is double || value is int)
        ? value.toDouble()
        : double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  String toString() {
    return 'Year: $year, Quarter: $quarter, Revenue: $revenue, Net Income: $netIncome, Total Assets: $totalAssets, Total Liabilities: $totalLiabilities';
  }
}
