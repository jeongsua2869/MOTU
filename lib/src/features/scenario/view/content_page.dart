import 'package:flutter/material.dart';
import 'package:motu/src/features/profile/model/balance_detail.dart';
import 'package:motu/src/features/scenario/model/scenario_result.dart';
import 'package:motu/src/features/login/service/auth_service.dart';
import 'package:motu/src/features/scenario/view/balance/stock_balance.dart';
import 'package:motu/src/features/scenario/view/news/stock_news_tab.dart';
import 'package:motu/src/features/scenario/view/order/stock_order.dart';
import 'package:motu/src/features/scenario/view/timeover_page.dart';
import 'package:motu/src/design/color_theme.dart';
import 'package:motu/src/common/view/widget/common_dialog.dart';
import 'package:provider/provider.dart';

import '../service/scenario_service.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late AuthService _authService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ScenarioService service = context.watch<ScenarioService>();

    service.onNavigate = () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TimeoverPage()),
        (route) => false,
      );
    };

    service.updateUserBalanceWhenFinish = () {
      int remainingStockPrice = service.getRemainStockToBalance();
      _authService.user?.balance += remainingStockPrice;

      int change = _authService.user!.balance - service.originBalance;
      bool isIncome = change > 0;
      int amount = change.abs();

      BalanceDetail thisDetail = BalanceDetail(
        date: DateTime.now(),
        content: "시나리오로 인한 잔고 변동",
        amount: amount,
        isIncome: isIncome,
      );
      _authService.addBalanceDetail(thisDetail);

      ScenarioResult result = ScenarioResult(
        date: DateTime.now(),
        subject: service.getScenarioTitle(service.selectedScenario),
        isIncome: isIncome,
        totalReturn: amount,
        returnRate: service.totalPurchasePrice == 0
            ? "0.0"
            : ((service.totalRatingPrice - service.totalPurchasePrice) /
                    service.totalPurchasePrice *
                    100)
                .toStringAsFixed(1),
      );
      _authService.addScenarioRecord(result);
    };

    int hours = service.remainingTime.inHours;
    int minutes = (service.remainingTime.inMinutes % 60);
    int seconds = (service.remainingTime.inSeconds % 60);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
            width: size.width / 1.9,
            height: size.height / 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/scenario/info_time.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                            fontSize: 20, color: ColorTheme.Purple1),
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/scenario/info_time.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return CommonDialog(context);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), // 패딩 조절
            child: Image.asset(
              "assets/images/scenario/exit.png",
              fit: BoxFit.contain, // 이미지가 컨테이너에 맞게 조절됨
            ),
          ),
        ),
        backgroundColor: ColorTheme.Purple5,
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Column(
            children: [
              Container(
                color: ColorTheme.Grey1,
                child: TabBar(
                  tabs: [
                    SizedBox(
                      width: size.width * 0.15,
                      child: const Tab(
                          child: Text("주문",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ))),
                    ),
                    SizedBox(
                      width: size.width * 0.15,
                      child: Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("뉴스",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                            service.checkUnreadNews() != 0
                                ? const SizedBox(width: 6)
                                : const SizedBox(),
                            // 동그란 원 안에 Text로 숫자를 표시할 수 있는 원을 만들어줘
                            service.checkUnreadNews() != 0
                                ? Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      service.checkUnreadNews().toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.15,
                      child: const Tab(
                          child: Text("잔고",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ))),
                    ),
                  ],
                  indicatorColor: ColorTheme.Purple1,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.only(left: 10),
                ),
              ),
              const Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    StockOrderTab(),
                    StockNewsTab(),
                    StockBalanceTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
