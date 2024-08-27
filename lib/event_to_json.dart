Future<dynamic> eventToJson(
  String title,
  String description,
  DateTime startTime,
  DateTime endTime,
) async {
  final json = {
    'summary': title,
    'description': description,
    'start': {'dateTime': startTime.toUtc().toIso8601String()},
    'end': {'dateTime': endTime.toUtc().toIso8601String()}
  };
  return json;
}
