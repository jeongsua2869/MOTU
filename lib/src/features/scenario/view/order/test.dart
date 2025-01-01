import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  Size size;
  TestScreen({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    print('🌟 TestScreen build');
    return Container(
      height: size.height * 0.35,
      color: Colors.red,
    );
  }
}
