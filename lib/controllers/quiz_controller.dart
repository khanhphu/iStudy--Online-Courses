import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:istudy_courses/helpers/app_routes.dart';
import 'package:istudy_courses/helpers/questions_data.dart';
import 'package:istudy_courses/models/quiz_question.dart';
import 'package:istudy_courses/screens/quiz_result_screen.dart';

class QuizController extends GetxController {
  final storage = GetStorage();
  final String uid;

  QuizController(this.uid);

  final RxInt currentIndex = 0.obs;
  final RxInt score = 0.obs;
  final Rx<QuizQuestion?> currentQuestion = Rx<QuizQuestion?>(null);
  final RxInt selectedAnswerIndex = (-1).obs;
  final RxBool isAnswered = false.obs;
  final RxInt timeLeft = 15.obs;
  Timer? _timer;

  late List<QuizQuestion> allQuestions;

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
  }

  void loadQuestions() {
    allQuestions = getRandomQuestions()..shuffle();
    currentQuestion.value = allQuestions[currentIndex.value];
    startTimer();
  }

  void startTimer() {
    timeLeft.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft.value == 0) {
        timer.cancel();
        moveToNext();
      } else {
        timeLeft.value--;
      }
    });
  }

  void selectAnswer(int index) {
    if (isAnswered.value) return;

    isAnswered.value = true;
    selectedAnswerIndex.value = index;

    if (index == currentQuestion.value!.correctIndex) {
      score.value++;
    }

    Future.delayed(Duration(seconds: 1), () {
      moveToNext();
    });
  }

  void moveToNext() {
    if (currentIndex.value < allQuestions.length - 1) {
      currentIndex.value++;
      currentQuestion.value = allQuestions[currentIndex.value];
      selectedAnswerIndex.value = -1;
      isAnswered.value = false;
      startTimer();
    } else {
      print("===> Đã hoàn thành tất cả câu hỏi. Đang chuyển trang...");

      _timer?.cancel();
      saveResult();
      //Get.offNamed(AppRoutes.quizResult);
      Get.off(() => QuizResultScreen());
    }
  }

  void saveResult() {
    final quizResult = {
      "score": score.value,
      "total": allQuestions.length,
      "timestamp": DateTime.now().toIso8601String(),
    };

    final key = "quizResults_$uid";
    final existing = storage.read<List>(key) ?? [];
    final updated = [...existing, quizResult];
    storage.write(key, updated);
  }

  void resetQuiz() {
    currentIndex.value = 0;
    score.value = 0;
    selectedAnswerIndex.value = -1;
    isAnswered.value = false;
    loadQuestions();
  }
}
