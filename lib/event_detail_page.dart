import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_edit_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentDetailsPage extends StatefulWidget {
  final String accessToken;
  final Map<String, dynamic> appointment;

  const AppointmentDetailsPage({
    required this.appointment,
    required this.accessToken,
  });

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late Map<String, dynamic> _appointmentDetails;

  @override
  void initState() {
    super.initState();
    _appointmentDetails = widget.appointment;
  }

  Future<void> _fetchUpdatedEvent(String eventId) async {
    final response = await http.get(
      Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/primary/events/$eventId'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _appointmentDetails = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch updated event details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String eventId = _appointmentDetails['id'] ?? '';
    final startDateTime =
        DateTime.parse(_appointmentDetails['start']['dateTime']).toLocal();
    final endDateTime =
        DateTime.parse(_appointmentDetails['end']['dateTime']).toLocal();

    final formattedStartDateTime =
        DateFormat('MMM d, yyyy h:mm a').format(startDateTime);
    final formattedEndDateTime =
        DateFormat('MMM d, yyyy h:mm a').format(endDateTime);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios, 
            color: Colors.white, 
          ),
          onPressed: () {
            Navigator.pop(
                context);
          },
        ),
        title: const Text(
          'Appointment Details',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventPage(
                    appointment: _appointmentDetails,
                    accessToken: widget.accessToken,
                    eventId: eventId,
                  ),
                ),
              );
              if (result == true) {
                _fetchUpdatedEvent(eventId);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.title,
                  label: 'Title',
                  value: _appointmentDetails['summary'] ?? 'No Title',
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  icon: Icons.schedule,
                  label: 'Start Time',
                  value: formattedStartDateTime,
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  icon: Icons.schedule,
                  label: 'End Time',
                  value: formattedEndDateTime,
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  icon: Icons.description,
                  label: 'Details',
                  value: _appointmentDetails['description'] ?? 'No Description',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          // color: Colors.blue.shade600,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  // color: Colors.blue.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


