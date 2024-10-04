import 'package:intl/intl.dart';

String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  
  return DateFormat('dd-MM-yyyy HH:mm').format(parsedDate);
}