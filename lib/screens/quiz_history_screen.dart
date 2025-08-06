import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:istudy_courses/services/local/storage_service.dart';

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = StorageService.currentUID ?? "guest";
    final data = StorageService().getQuizResults(uid);
    final List<Map<String, dynamic>> results = StorageService().getQuizResults(
      uid,
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử làm bài")),
      body:
          results.isEmpty
              ? const Center(child: Text("Chưa có bài làm nào."))
              : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  final date = DateTime.tryParse(item['date'] ?? '');
                  final formattedDate =
                      date != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(date)
                          : 'Không xác định';

                  return ListTile(
                    leading: const Icon(Icons.quiz_outlined),
                    title: Text(item['quizTitle'] ?? "Bài không tên"),
                    subtitle: Text(
                      "Điểm: ${item['score']}/${item['total']} - $formattedDate",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  );
                },
              ),
    );
  }
}
