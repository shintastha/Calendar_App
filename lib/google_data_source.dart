import 'package:syncfusion_flutter_calendar/calendar.dart';

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource(List<dynamic> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final start = appointments![index]['start'];
    if (start['dateTime'] != null) {
      return DateTime.parse(start['dateTime']).toLocal();
    } else if (start['date'] != null) {
      return DateTime.parse(start['date']).toLocal();
    }
    return DateTime.now();
  }

  @override
  DateTime getEndTime(int index) {
    final end = appointments![index]['end'];
    if (end['dateTime'] != null) {
      return DateTime.parse(end['dateTime']).toLocal();
    } else if (end['date'] != null) {
      final start = DateTime.parse(end['date']);
      return start.add(const Duration(days: 1));
    }
    return DateTime.now();
  }

  @override
  String getSubject(int index) {
    return appointments![index]['summary'] ?? 'No Title';
  }

  @override
  String getNotes(int index) {
    return appointments![index]['description'] ?? '';
  }
}
