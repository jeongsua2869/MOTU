import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motu/src/common/util/util.dart';

import 'package:motu/src/features/scenario/model/stock_data.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';
import 'package:motu/src/features/scenario/view/order/custom/custom_crosshair_behavior.dart';
import 'package:motu/src/features/scenario/view/order/custom/custom_trackball_behavior.dart';
import 'package:motu/src/features/scenario/view/widget/order/custom_date_format.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SynchronizedCharts extends StatefulWidget {
  final Size size;
  final ScenarioService service;

  const SynchronizedCharts(
      {super.key, required this.service, required this.size});

  @override
  State<SynchronizedCharts> createState() => _SynchronizedChartsState();
}

class _SynchronizedChartsState extends State<SynchronizedCharts> {
  late CustomTrackballBehavior _trackballBehavior;
  final CustomCrosshairBehavior _crosshairBehavior = CustomCrosshairBehavior();

  late ZoomPanBehavior _stockZoomPanBehavior;
  late ZoomPanBehavior _volumeZoomPanBehavior;

  late Offset _tapPosition;

  @override
  void initState() {
    super.initState();
    _tapPosition = Offset.zero;

    widget.service.stockDateTimeCategoryAxis = DateTimeCategoryAxis(
      dateFormat: CustomDateFormat('custom'),
      interval: 3,
      majorGridLines: const MajorGridLines(width: 0),
      edgeLabelPlacement: EdgeLabelPlacement.shift,
      initialVisibleMinimum: widget.service.visibleStockData.last.x
          .subtract(const Duration(days: 21)),
      minimum: widget.service.visibleStockData.first.x,
      maximum: widget.service.visibleStockData.last.x,
    );
    widget.service.volumeDateTimeCategoryAxis = DateTimeCategoryAxis(
      dateFormat: CustomDateFormat('custom'),
      interval: 3,
      isVisible: false,
      majorGridLines: const MajorGridLines(width: 0),
      edgeLabelPlacement: EdgeLabelPlacement.shift,
      initialVisibleMinimum: widget.service.visibleStockData.last.x
          .subtract(const Duration(days: 21)),
      minimum: widget.service.visibleStockData.first.x,
      maximum: widget.service.visibleStockData.last.x,
    );

    _trackballBehavior = CustomTrackballBehavior(
      (context, trackballDetails) {
        final currentIndex = widget.service.visibleStockData
            .indexWhere((data) => data.x == trackballDetails.point?.x);

        if (currentIndex != -1) {
          final stockData = widget.service.visibleStockData[currentIndex];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 5,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(stockData.x),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '시작 \t\t\t\t\t${Formatter.format(stockData.open)}원',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '마지막\t\t\t${Formatter.format(stockData.close)}원',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '최고 \t\t\t\t\t${Formatter.format(stockData.high)}원',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '최저 \t\t\t\t\t${Formatter.format(stockData.low)}원',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '거래량 \t\t${Formatter.format(stockData.volume)}주',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );

    _stockZoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      zoomMode: ZoomMode.x,
    );

    _volumeZoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      zoomMode: ZoomMode.x,
    );
  }

  // 공통 축 스타일 정의
  final numericAxisStyle = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );

  String formatDate(DateTime value) {
    final DateFormat formatter = DateFormat('yyyy.MM.dd', 'ko_KR');
    return formatter.format(value);
  }

  final GlobalKey<State<StatefulWidget>> _chartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //* MARK: - 주가 데이터 차트
        SizedBox(
          height: widget.size.height * 0.35,
          child: SfCartesianChart(
            key: _chartKey,
            // 주요 X축, Y축 설정
            primaryXAxis: widget.service.stockDateTimeCategoryAxis,
            primaryYAxis: NumericAxis(
              placeLabelsNearAxisLine: false,
              anchorRangeToVisiblePoints: true,
              rangePadding: ChartRangePadding.round,
              opposedPosition: true,
              axisLabelFormatter: (axisLabelRenderArgs) {
                int value = int.parse(axisLabelRenderArgs.text);
                String formattedValue = Formatter.format(value);

                widget.service.stockPriceLabelLength = formattedValue.length;

                // 고정 너비를 가진 라벨 반환
                return ChartAxisLabel(
                    formattedValue.toString(), numericAxisStyle);
              },
            ),
            // 줌 팬 설정
            zoomPanBehavior: _stockZoomPanBehavior,
            onZooming: (zoomingArgs) {
              _volumeZoomPanBehavior.zoomToSingleAxis(
                widget.service.volumeDateTimeCategoryAxis,
                zoomingArgs.currentZoomPosition,
                zoomingArgs.currentZoomFactor,
              );
            },

            crosshairBehavior: _crosshairBehavior,
            trackballBehavior: _trackballBehavior,

            onChartTouchInteractionDown: (tapArgs) {
              print("TAP POSITION");
              _crosshairBehavior.orderToHide();
              _trackballBehavior.orderToHide();
            },

            // series 데이터 설정
            series: <CartesianSeries<StockData, DateTime>>[
              // 캔들 시리즈
              CandleSeries<StockData, DateTime>(
                dataSource: widget.service.visibleStockData,
                xValueMapper: (StockData data, _) => data.x,
                openValueMapper: (StockData data, _) => data.open,
                closeValueMapper: (StockData data, _) => data.close,
                lowValueMapper: (StockData data, _) => data.low,
                highValueMapper: (StockData data, _) => data.high,
                enableSolidCandles: true,
                emptyPointSettings: const EmptyPointSettings(
                  mode: EmptyPointMode.gap,
                ),
                bearColor: Colors.blue,
                bullColor: Colors.red,
                animationDelay: 0,
                animationDuration: 500,
              ),
            ],
            margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
          ),
        ),
        //* MARK: - 거래량 데이터 차트
        SizedBox(
          height: widget.size.height * 0.13,
          child: SfCartesianChart(
            primaryXAxis: widget.service.volumeDateTimeCategoryAxis,
            primaryYAxis: NumericAxis(
              opposedPosition: true,
              maximumLabels: 2,
              rangePadding: ChartRangePadding.round,
              axisLabelFormatter: (axisLabelRenderArgs) {
                int value = int.parse(axisLabelRenderArgs.text);
                String formattedValue;

                if (value >= 1000000000) {
                  // 10억 이상
                  formattedValue =
                      '${(value / 1000000000).toStringAsFixed(1)}B';
                } else if (value >= 1000000) {
                  // 백만 이상
                  formattedValue = '${(value / 1000000).toStringAsFixed(1)}M';
                } else if (value >= 1000) {
                  // 천 이상
                  formattedValue = '${(value / 1000).toStringAsFixed(1)}K';
                } else {
                  formattedValue = value.toString();
                }

                int padding = widget.service.stockPriceLabelLength -
                    formattedValue.length +
                    7;

                return ChartAxisLabel(
                    formattedValue.padRight(padding), // 최대 너비에 맞춰 패딩
                    numericAxisStyle);
              },
            ),
            series: [
              // 거래량 막대 시리즈
              ColumnSeries<StockData, DateTime>(
                dataSource: widget.service.visibleStockData,
                xValueMapper: (StockData data, _) => data.x,
                yValueMapper: (StockData data, _) => data.volume,
                animationDelay: 0,
                animationDuration: 500,
                pointColorMapper: (data, index) {
                  if (index == 0) {
                    return Colors.red;
                  }
                  if (data.volume >=
                      widget.service.visibleStockData[index - 1].volume) {
                    return Colors.red;
                  } else {
                    return Colors.blue;
                  }
                },
              ),
            ],
            // 트랙볼 설정
            // trackballBehavior: TrackballBehavior(
            //   enable: true,
            //   activationMode: ActivationMode.longPress,
            //   builder: (context, trackballDetails) {
            //     print("TRACKBALL DETAILS");
            //     print(trackballDetails.point);
            //     String date = formatDate(trackballDetails.point?.x);
            //     String? open = trackballDetails.point?.open?.toInt().toString();
            //     String? close =
            //         trackballDetails.point?.close?.toInt().toString();
            //     String? high = trackballDetails.point?.high?.toInt().toString();
            //     String? low = trackballDetails.point?.low?.toInt().toString();

            //     if (trackballDetails.seriesIndex == 0) {
            //       return Container(
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(5),
            //           boxShadow: const [
            //             BoxShadow(
            //               color: Colors.black54,
            //               blurRadius: 5,
            //               offset: Offset(0, 5),
            //             ),
            //           ],
            //         ),
            //         padding: const EdgeInsets.all(10),
            //         child: Column(
            //           mainAxisSize: MainAxisSize.min,
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               date,
            //               style: const TextStyle(
            //                 color: Colors.black,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               '시작 \t\t\t\t\t${Formatter.format(int.parse(open!))}원',
            //               style: const TextStyle(
            //                 color: Colors.black,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               '마지막\t\t\t$close원',
            //               style: const TextStyle(
            //                 color: Colors.black,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               '최고 \t\t\t\t\t$high원',
            //               style: const TextStyle(
            //                 color: Colors.black,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               '최저 \t\t\t\t\t$low원',
            //               style: const TextStyle(
            //                 color: Colors.black,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             const Divider(),
            //             Text(
            //               '거래량\t\t\t\t${trackballDetails.point?.volume}',
            //               style: const TextStyle(
            //                 color: Colors.black,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ],
            //         ),
            //       );
            //     }
            //     return Container();
            //   },
            // ),
            // 줌 팬 설정
            zoomPanBehavior: _volumeZoomPanBehavior,
            onZooming: (zoomingArgs) {
              _stockZoomPanBehavior.zoomToSingleAxis(
                widget.service.stockDateTimeCategoryAxis,
                zoomingArgs.currentZoomPosition,
                zoomingArgs.currentZoomFactor,
              );
            },
            margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
          ),
        ),
      ],
    );
  }
}
