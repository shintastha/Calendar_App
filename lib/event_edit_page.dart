import 'package:flutter/material.dart';
import 'package:flutter_calendar/service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar/event_to_json.dart';

class EditEventPage extends StatefulWidget {
  final String accessToken;
  final Map<String, dynamic> appointment;
  final String eventId;

  const EditEventPage({
    super.key,
    required this.accessToken,
    required this.appointment,
    required this.eventId,
  });

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.appointment['summary']);
    _descriptionController =
        TextEditingController(text: widget.appointment['description']);
    _startTime =
        DateTime.parse(widget.appointment['start']['dateTime']).toLocal();
    _endTime = DateTime.parse(widget.appointment['end']['dateTime']).toLocal();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (time != null) {
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStart) {
            _startTime = dateTime;
            _endTime = _startTime?.add(const Duration(
                hours: 1)); // Automatically set end time to 1 hour later
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate() &&
        _startTime != null &&
        _endTime != null) {
      try {
        final dynamic jsonEvent = await eventToJson(
          _titleController.text,
          _descriptionController.text,
          _startTime!,
          _endTime!,
        );
        await updateEventInCalendar(
            widget.accessToken, widget.eventId, jsonEvent);
        Navigator.pop(context, true); // Go back to the previous page
      } catch (e) {
        print('Error updating event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update event')),
        );
      }
    } else {
      print('Please fill in all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
         leading: IconButton(
    icon: const Icon(
      Icons.arrow_back_ios, // Replace with your desired icon
      color: Colors.white,   // Icon color
    ),
    onPressed: () {
      Navigator.pop(context); // Define the action when the icon is pressed
    },
  ),
        title: const Text(
          "Edit Event",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _updateEvent,
            child: const Text(
              "Update",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 16.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color:  Color(0xffF4F4F4),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    fontFamily: 'DM-Sans',
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.50),
                  ),
                  prefixIcon: const Icon(Icons.menu, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDateTime(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color:  Color(0xffF4F4F4),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    hintText: 'Select Start Time',
                    hintStyle: TextStyle(
                      fontFamily: 'DM-Sans',
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.50),
                    ),
                  ),
                  child: Text(
                    _startTime == null
                        ? 'Start Time'
                        : 'Start: ${DateFormat('yMMMd').format(_startTime!)} ${DateFormat('jm').format(_startTime!)}',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDateTime(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color:  Color(0xffF4F4F4),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    hintText: 'Select End Time',
                    hintStyle: TextStyle(
                      fontFamily: 'DM-Sans',
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.50),
                    ),
                  ),
                  child: Text(
                    _endTime == null
                        ? 'End Time'
                        : 'End: ${DateFormat('yMMMd').format(_endTime!)} ${DateFormat('jm').format(_endTime!)}',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 16.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const  BorderSide(
                      color:  Color(0xffF4F4F4),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  hintText: 'Description',
                  hintStyle: TextStyle(
                    fontFamily: 'DM-Sans',
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.50),
                  ),
                  prefixIcon: const Icon(Icons.description, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


