import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istudy_courses/controllers/quiz_controller.dart';
import 'package:istudy_courses/widgets/answer_option.dart';
import 'package:istudy_courses/widgets/question_timer.dart';

class QuizScreen extends StatelessWidget {
  final String uid;

  QuizScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.put(QuizController(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() {
        final question = controller.currentQuestion.value;
        if (question == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              QuestionTimer(timeLeft: controller.timeLeft),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Câu ${controller.currentIndex.value + 1}: ${question.question}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: question.options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 đáp án mỗi hàng
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return AnswerOption(
                      index: index,
                      text: question.options[index],
                      isSelected: controller.selectedAnswerIndex.value == index,
                      isCorrect: index == question.correctIndex,
                      isAnswered: controller.isAnswered.value,
                      onTap: () => controller.selectAnswer(index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
