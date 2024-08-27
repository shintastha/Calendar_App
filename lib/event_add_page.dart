import 'package:flutter/material.dart';
import 'package:flutter_calendar/service.dart';
import 'package:flutter_calendar/event_to_json.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  final String accessToken;
  final DateTime selectedDate;

  const AddEventPage({
    super.key,
    required this.accessToken,
    required this.selectedDate,
  });

  @override
  AddEventPageState createState() => AddEventPageState();
}

class AddEventPageState extends State<AddEventPage> {
  final _formKey1 = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  List<dynamic> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _startTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      widget.selectedDate
          .hour,
      0, 
    );
    _endTime = _startTime!.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController
        .dispose(); 
    _descriptionController.dispose();
    super.dispose();
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
            // Automatically set end time to 1 hour later
            _endTime = _startTime?.add(const Duration(hours: 1));
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }


  Future<void> _addEvent() async {
    if (_formKey1.currentState!.validate() &&
        _startTime != null &&
        _endTime != null) {
      final dynamic jsonEvent = await eventToJson(
        _titleController.text,
        _descriptionController.text, // Include description
        _startTime!,
        _endTime!,
      );
      await addEventToCalendar(widget.accessToken, jsonEvent);
      Navigator.pop(context,true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await getEventsFromCalendar(widget.accessToken);
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch events')),
      );
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
      Icons.arrow_back_ios, 
      color: Colors.white,   
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
        title: const Text(
          "Add Event",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _addEvent,
            child: const Text(
              "Save",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey1,
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
                      color: Color(0xffF4F4F4),
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
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startTime == null
                            ? 'Start Time'
                            : 'Start: ${DateFormat('yMMMd').format(_startTime!)} ${DateFormat('jm').format(_startTime!)}',
                        style: TextStyle(
                          color:
                              _startTime == null ? Colors.grey : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
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
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endTime == null
                            ? 'End Time'
                            : 'End: ${DateFormat('yMMMd').format(_endTime!)} ${DateFormat('jm').format(_endTime!)}',
                        style: TextStyle(
                          color: _endTime == null ? Colors.grey : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                maxLength: 300,
                maxLines: null,
                minLines: 2,
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
                      color: Color(0xffF4F4F4),
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
                  prefixIcon: const Padding(
                    padding:  EdgeInsets.only(bottom: 20.0),
                    child:  Icon(
                      Icons.description_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

