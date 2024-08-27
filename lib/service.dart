import 'dart:convert';

import 'package:http/http.dart' as http;

Future addEventToCalendar(String accessToken, dynamic jsonEvent) async {
  final headers = {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final response = await http.post(
    Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events'),
    headers: headers,
    body: jsonEncode(jsonEvent),
  );
  if (response.statusCode == 200) {
    print('Event inserted successfully');
  } else {
    print('Error inserting event: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

Future<List<dynamic>> getEventsFromCalendar(String accessToken) async {
  final headers = {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final response = await http.get(
    Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> events = jsonResponse['items'];
    return events;
  } else {
    print('Failed to fetch events: ${response.statusCode}');
    print('Response body: ${response.body}');
    return [];
  }
}

Future updateEventInCalendar(String accessToken, String eventId, dynamic jsonEvent) async {
  final headers = {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
  final response = await http.patch(
    Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events/$eventId'),
    headers: headers,
    body: jsonEncode(jsonEvent),
  );
  if (response.statusCode == 200) {
    print('Event updated successfully');
  } else {
    print('Error updating event: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

// Future<void> updateEventInCalendar(String accessToken, String eventId, dynamic jsonEvent) async {
//   final url = 'https://www.googleapis.com/calendar/v3/calendars/primary/events/$eventId';
//   final response = await http.patch(
//     Uri.parse(url),
//     headers: {
//       'Authorization': 'Bearer $accessToken',
//       'Content-Type': 'application/json',
//     },
//     body: jsonEncode(jsonEvent),
//   );

//   if (response.statusCode != 200) {
//     throw Exception('Failed to update event: ${response.body}');
//   }
// }
