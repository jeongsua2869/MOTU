import 'dart:developer';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomTrackballBehavior extends TrackballBehavior {
  CustomTrackballBehavior(this.builder)
      : super(
          enable: true,
          activationMode: ActivationMode.longPress,
          hideDelay: double.infinity,
          shouldAlwaysShow: true,
        );

  bool isOrderedToHide = false;

  @override
  final ChartTrackballBuilder? builder;

  @override
  void show(x, double y, [String coordinateUnit = 'point']) {
    log("Trackball show");

    super.show(x, y, coordinateUnit);
  }

  void orderToHide() {
    isOrderedToHide = true;
  }

  @override
  void hide() {
    if (isOrderedToHide) {
      log("Trackball hide");
      isOrderedToHide = false;
      super.hide();
    }
  }
}
