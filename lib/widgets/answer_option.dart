import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final VoidCallback onTap;

  const AnswerOption({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey.shade300;

    if (isAnswered) {
      if (isSelected && isCorrect) {
        color = Colors.green;
      } else if (isSelected && !isCorrect) {
        color = Colors.red;
      } else if (isCorrect) {
        color = Colors.green.shade200;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isAnswered
                  ? (isSelected
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Colors.grey.shade300)
                  : Colors.white,
          border: Border.all(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text),
      ),
    );
  }
}
