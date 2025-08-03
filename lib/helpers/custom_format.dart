import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final format = NumberFormat("#,###", "vi_VN");
  return "${format.format(amount)} VND";
}
