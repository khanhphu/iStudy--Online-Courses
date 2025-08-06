import 'dart:math';

import 'package:istudy_courses/models/quiz_question.dart';

List<QuizQuestion> getRandomQuestions() {
  final allQuestions = [
    QuizQuestion(
      question: "What is Flutter?",
      options: ["A bird", "A framework", "A food", "None"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Which language does Flutter use?",
      options: ["Dart", "Java", "Swift", "C++"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "What is StatefulWidget?",
      options: ["Stateless", "Dynamic", "Fixed", "HTML"],
      correctIndex: 1,
    ),
    // Thêm nhiều câu hỏi tuỳ ý
  ];

  allQuestions.shuffle(Random());
  return allQuestions.take(3).toList(); // Random 3 câu mỗi lần
}
