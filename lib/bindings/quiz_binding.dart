import 'package:get/get.dart';
import 'package:istudy_courses/controllers/quiz_controller.dart';

class QuizBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(() => QuizController(Get.parameters['uid']!));
  }
}
