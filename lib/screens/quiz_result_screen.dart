import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istudy_courses/controllers/quiz_controller.dart';
import 'package:istudy_courses/screens/main_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find();
    final score = controller.score.value;
    final total = controller.allQuestions.length;
    final percent = (score / total * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('🎉 Quiz Result'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 80),
            const SizedBox(height: 20),
            Text(
              'You scored',
              style: TextStyle(fontSize: 22, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '$score / $total',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '($percent%)',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                controller.resetQuiz();
                Get.back(); // Go back to QuizScreen
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Get.off(HomeScreen());
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
                minimumSize: const Size.fromHeight(30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
