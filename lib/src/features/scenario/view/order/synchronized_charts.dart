import 'package:flutter/material.dart';
import 'package:motu/src/common/util/util.dart';

import 'package:motu/src/features/scenario/model/stock_data.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';
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
  late ZoomPanBehavior _stockZoomPanBehavior;
  late ZoomPanBehavior _volumeZoomPanBehavior;

  @override
  void initState() {
    super.initState();

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

    _stockZoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      enableSelectionZooming: true,
      zoomMode: ZoomMode.x,
    );

    _volumeZoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      enableSelectionZooming: true,
      zoomMode: ZoomMode.x,
    );
  }

  // 공통 축 스타일 정의
  final numericAxisStyle = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //* MARK: - 주가 데이터 차트
        SfCartesianChart(
          // 주요 X축, Y축 설정
          primaryXAxis: widget.service.stockDateTimeCategoryAxis,
          primaryYAxis: NumericAxis(
            placeLabelsNearAxisLine: false,
            anchorRangeToVisiblePoints: true,
            rangePadding: ChartRangePadding.round,
            opposedPosition: true,
            // axisLabelFormatter: (axisLabelRenderArgs) {
            //   int value = int.parse(axisLabelRenderArgs.text);

            //   String formattedValue;

            //   // Y축 값에 따라 레이블 포맷 변경
            //   if (value >= 10000000) {
            //     formattedValue = '${(value / 10000000).toStringAsFixed(0)}천만';
            //   } else if (value >= 1000000) {
            //     formattedValue = '${(value / 1000000).toStringAsFixed(1)}백만';
            //   } else if (value >= 100000) {
            //     formattedValue = '${(value / 100000).toStringAsFixed(1)}십만';
            //   } else if (value >= 10000) {
            //     formattedValue = '${(value / 10000).toStringAsFixed(1)}만';
            //   } else {
            //     formattedValue = axisLabelRenderArgs.text; // 기본 포맷
            //   }

            //   return ChartAxisLabel(
            //     formattedValue,
            //     const TextStyle(
            //       fontSize: 11,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   );
            // },
            axisLabelFormatter: (axisLabelRenderArgs) {
              int value = int.parse(axisLabelRenderArgs.text);
              String formattedValue = Formatter.format(value);

              widget.service.stockPriceLabelLength = formattedValue.length;

              // 고정 너비를 가진 라벨 반환
              return ChartAxisLabel(
                  formattedValue.toString(),
                  // 왼쪽 패딩으로 너비 통일
                  numericAxisStyle);
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
          // 트랙볼 설정
          trackballBehavior: TrackballBehavior(),
          // 십자선 설정
          crosshairBehavior: CrosshairBehavior(
            enable: true,
            activationMode: ActivationMode.longPress,
            lineType: CrosshairLineType.both,
            lineColor: Colors.grey,
            lineWidth: 1,
            lineDashArray: const <double>[5, 5],
          ),
          margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
        ),
        //* MARK: - 거래량 데이터 차트
        SizedBox(
          height: widget.size.height * 0.15,
          child: SfCartesianChart(
            primaryXAxis: widget.service.volumeDateTimeCategoryAxis,
            primaryYAxis: NumericAxis(
              opposedPosition: true,
              maximumLabels: 2,
              rangePadding: ChartRangePadding.round,
              // axisLabelFormatter: (axisLabelRenderArgs) {
              //   int value = int.parse(axisLabelRenderArgs.text);

              //   String formattedValue;

              //   // Y축 값에 따라 레이블 포맷 변경
              //   if (value >= 10000000) {
              //     formattedValue = '${(value / 10000000).toStringAsFixed(0)}천만';
              //   } else if (value >= 1000000) {
              //     formattedValue = '${(value / 1000000).toStringAsFixed(1)}백만';
              //   } else if (value >= 100000) {
              //     formattedValue = '${(value / 100000).toStringAsFixed(1)}십만';
              //   } else if (value >= 10000) {
              //     formattedValue = '${(value / 10000).toStringAsFixed(1)}만';
              //   } else {
              //     formattedValue = axisLabelRenderArgs.text; // 기본 포맷
              //   }

              //   return ChartAxisLabel(
              //     formattedValue,
              //     const TextStyle(
              //       fontSize: 11,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   );
              // },
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
            trackballBehavior: TrackballBehavior(),
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
