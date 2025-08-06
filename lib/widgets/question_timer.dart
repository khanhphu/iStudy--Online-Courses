import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionTimer extends StatelessWidget {
  final RxInt timeLeft;

  const QuestionTimer({required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LinearProgressIndicator(
        value: timeLeft.value / 15,
        backgroundColor: Colors.grey.shade300,
        color: Colors.blue,
        minHeight: 8,
      ),
    );
  }
}
