import 'package:flutter/material.dart';
import 'package:flutter_calendar/service.dart';
import 'package:flutter_calendar/event_add_page.dart';
import 'package:flutter_calendar/event_detail_page.dart';
import 'package:flutter_calendar/google_data_source.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  final String accessToken;

  const CalendarPage({super.key, required this.accessToken});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController _calendarController = CalendarController();
  List<dynamic> _events = [];
  bool _isFetching = false;
  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (_isFetching) return;
    _isFetching = true;
    print('Fetching events...');
    try {
      final events = await getEventsFromCalendar(widget.accessToken);
      if (mounted) {
        setState(() {
          _events = events;
          print('Events fetched and state updated.');
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch events')),
      );
    } finally {
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Calendar App'),
      ),
      body: _events.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(8),
              child: SfCalendar(
                showDatePickerButton: true,
                // showNavigationArrow: true,
                view: CalendarView.month,
                initialSelectedDate: DateTime.now(),
                controller: _calendarController,
                allowedViews: const [
                  CalendarView.month,
                  CalendarView.week,
                ],
                dataSource: GoogleDataSource(_events),
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  showAgenda: true,
                ),
                onTap: (CalendarTapDetails details) {
                  if (details.targetElement == CalendarElement.calendarCell) {
                    final DateTime selectedDate = details.date!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEventPage(
                          accessToken: widget.accessToken,
                          selectedDate: selectedDate,
                        ),
                      ),
                    ).then((_) {
                      _fetchEvents();
                    });
                  } else if (details.appointments != null &&
                      details.appointments!.isNotEmpty) {
                    final appointment =
                        details.appointments!.first as Map<String, dynamic>;
                    print('Clicked Appointment: $appointment');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentDetailsPage(
                          appointment: appointment,
                          accessToken: widget.accessToken,
                        ),
                      ),
                    ).then((_) {
                      _fetchEvents();
                    });
                  }
                },
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) =>
      //             AddEventPage(accessToken: widget.accessToken, selectedDate: null,),
      //       ),
      //     ).then((_) {
      //       _fetchEvents();
      //     });
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
