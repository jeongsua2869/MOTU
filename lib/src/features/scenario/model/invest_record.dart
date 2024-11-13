import 'dart:developer';

import 'package:motu/src/features/scenario/service/scenario_service.dart';

class InvestRecord {
  String stock;
  TransactionType type;
  int price;
  int amount;

  InvestRecord({
    required this.stock,
    required this.type,
    required this.price,
    required this.amount,
  });

  // JSON에서 생성
  factory InvestRecord.fromJson(Map<String, dynamic> json) {
    // JSON에서 type을 가져오고 null 체크
    String? typeString = json['type'];

    // 유효한 타입인지 확인
    TransactionType type;
    if (typeString == null || typeString.isEmpty) {
      log('유효하지 않은 TransactionType: $typeString, 기본값으로 설정합니다.');
      type = TransactionType.buy; // 적절한 기본값으로 변경
    } else {
      // Enum 변환 시도
      try {
        type = TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last == typeString,
          orElse: () => TransactionType.buy, // 기본값 설정
        );
      } catch (e) {
        log('유효하지 않은 TransactionType: $typeString, 기본값으로 설정합니다.');
        type = TransactionType.buy; // 적절한 기본값으로 변경
      }
    }

    return InvestRecord(
      stock: json['stock'],
      type: type,
      price: json['price'],
      amount: json['amount'],
    );
  }

  // 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stock': stock,
      'type': type.toString().split('.').last, // Enum을 문자열로 변환
      'price': price,
      'amount': amount,
    };
  }

  InvestRecord.fromMap(Map<String, dynamic> map)
      : stock = map['stock'],
        type = map['type'],
        price = map['price'],
        amount = map['amount'];

  Map<String, dynamic> toMap() {
    return {
      'stock': stock,
      'type': type,
      'price': price,
      'amount': amount,
    };
  }
}
