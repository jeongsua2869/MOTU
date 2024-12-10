import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:motu/src/common/util/util.dart';
import 'package:motu/src/features/scenario/view/order/stock_info.dart';
import 'package:motu/src/features/scenario/view/order/synchronized_charts.dart';
import 'package:motu/src/features/scenario/view/widget/order/keyword_popup.dart';
import 'package:motu/src/features/scenario/view/widget/order/stock_trade_widget.dart';
import 'package:motu/src/design/color_theme.dart';
import 'package:motu/src/common/view/widget/motu_button.dart';
import 'package:provider/provider.dart';
import '../../service/scenario_service.dart';

class StockOrderTab extends StatelessWidget {
  const StockOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Consumer<ScenarioService>(builder: (context, service, child) {
      if (service.visibleStockData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gif(
                image: const AssetImage('assets/images/gif/loading.gif'),
                autostart: Autostart.loop,
                fit: BoxFit.fill,
              ),
              const Text("차트를 불러오고 있습니다"),
            ],
          ),
        );
      }

      return Stack(
        children: [
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PopupMenuButton<String>(
                              initialValue: service.selectedStock,
                              onSelected: (String value) {
                                service.setSelectedStock(value);
                              },
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Text(
                                    service.selectedStock,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    CupertinoIcons.chevron_down,
                                    color: ColorTheme.Grey3,
                                    size: 16,
                                  ),
                                ],
                              ),
                              itemBuilder: (BuildContext context) {
                                return service.stockOptions
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final isLast = entry.key ==
                                      service.stockOptions.length - 1;
                                  return PopupMenuItem<String>(
                                    value: entry.value,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        border: !isLast
                                            ? const Border(
                                                bottom: BorderSide(
                                                  color: ColorTheme.Grey2,
                                                  width: 1,
                                                ),
                                              )
                                            : null,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0),
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            Text(
                              "${Formatter.format(service.visibleStockData.last.close.toInt())}원",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TabBar(
                          labelColor: ColorTheme.Black1,
                          unselectedLabelColor: ColorTheme.Grey3,
                          indicatorColor: ColorTheme.Black1,
                          indicatorSize: TabBarIndicatorSize.tab,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: [
                            SizedBox(
                              width: screenSize.width * 0.1,
                              child: const Tab(
                                  child: Text("차트",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ))),
                            ),
                            SizedBox(
                              width: screenSize.width * 0.2,
                              child: const Tab(
                                  child: Text("종목정보",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ))),
                            ),
                          ],
                        ),
                      ),

                      // TabBarView
                      SizedBox(
                        height: screenSize.height * 0.5,
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            SynchronizedCharts(
                              service: service,
                              size: screenSize,
                            ),
                            StockInfo(
                              service: service,
                              screenSize: screenSize,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: ColorTheme.Grey2, width: 0.5),
                  bottom: BorderSide(color: ColorTheme.Grey2, width: 0.5),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: MotuNormalButton(
                      context,
                      text: '매수',
                      color: Colors.red,
                      onPressed: () {
                        // TODO: 나중에 다시 하겠습니다.
                        // service.pauseTimers();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              content: StockTradeWidget(
                                  service: service,
                                  tradeType: StockTradeType.buy),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MotuNormalButton(
                      context,
                      text: '매도',
                      color: Colors.blue,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              content: StockTradeWidget(
                                  service: service,
                                  tradeType: StockTradeType.sell),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
