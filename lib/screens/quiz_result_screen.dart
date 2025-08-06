import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istudy_courses/controllers/quiz_controller.dart';
import 'package:istudy_courses/screens/main_screen.dart';

class QuizResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text('Quiz Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: ${controller.score.value}/${controller.allQuestions.length}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.resetQuiz();
                Get.back(); // Go back to QuizScreen
              },
              child: Text('Retry Quiz'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.off(HomeScreen());
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
