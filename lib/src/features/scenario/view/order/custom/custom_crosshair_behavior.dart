import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:motu/src/features/scenario/service/scenario_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomCrosshairBehavior extends CrosshairBehavior {
  CustomCrosshairBehavior()
      : super(
          enable: true,
          activationMode: ActivationMode.longPress,
        );

  Offset? position;
  bool isShowing = false;
  bool isOrderedToHide = false;

  @override
  void drawHorizontalAxisLine(PaintingContext context, Offset offset,
      List<double>? dashArray, Paint strokePaint) {
    strokePaint
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..color = Colors.red
      ..strokeWidth = 1.2;
    dashArray = [5];
    super.drawHorizontalAxisLine(context, offset, dashArray, strokePaint);
  }

  @override
  void drawVerticalAxisLine(PaintingContext context, Offset offset,
      List<double>? dashArray, Paint strokePaint) {
    strokePaint
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..color = Colors.red
      ..strokeWidth = 1.2;
    dashArray = [5];
    super.drawVerticalAxisLine(context, offset, dashArray, strokePaint);
  }

  @override
  void show(x, double y, [String coordinateUnit = 'point']) {
    log("Crosshair show");

    if (coordinateUnit == 'pixel') {
      position = Offset(x.toDouble(), y);
    }

    // if (isShowing == false) {
    //   isOrderedToHide = false;
    //   isShowing = true;
    super.show(x, y, 'pixel');
    // }
  }

  void orderToHide() {
    isOrderedToHide = true;
  }

  @override
  void hide() {
    // if (isShowing == true) {
    //   isShowing = false;
    //   super.hide();
    // }
    if (isOrderedToHide) {
      isOrderedToHide = false;
      super.hide();
    }
  }
}
