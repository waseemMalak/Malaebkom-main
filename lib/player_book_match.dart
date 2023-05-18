import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'player.dart';

import 'package:firebase_auth/firebase_auth.dart';

class PlayerBookMatch extends StatefulWidget {
  final DocumentSnapshot field;

  const PlayerBookMatch({required this.field});

  @override
  _PlayerBookMatchState createState() => _PlayerBookMatchState();
}

enum DurationSelection {
  oneHour,
  oneAndHalfHours,
  twoHours,
}

enum MatchType {
  private,
  public,
}

class _PlayerBookMatchState extends State<PlayerBookMatch> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  List<TimeOfDay> availableTimes = [];
  DurationSelection durationSelection = DurationSelection.oneHour;
  MatchType selectedMatchType = MatchType.private;
  double selectedDuration = 1.0; // Default duration multiplier

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    final openingHours = widget.field['openingHours'];
    final openingTimeString = openingHours.split(' - ')[0];
    final closingTimeString = openingHours.split(' - ')[1];
    final openingTime = _parseTimeOfDay(openingTimeString);
    final closingTime = _parseTimeOfDay(closingTimeString);
    availableTimes = getAvailableTimes(openingTime, closingTime);
    selectedTime = openingTime;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  bool _isTimeWithinRange(
      TimeOfDay time, TimeOfDay startTime, TimeOfDay endTime) {
    final currentTimeValue = time.hour * 60 + time.minute;
    final startTimeValue = startTime.hour * 60 + startTime.minute;
    final endTimeValue = endTime.hour * 60 + endTime.minute;

    if (startTimeValue <= endTimeValue) {
      return currentTimeValue >= startTimeValue &&
          currentTimeValue <= endTimeValue;
    } else {
      return currentTimeValue >= startTimeValue ||
          currentTimeValue <= endTimeValue;
    }
  }

  void _selectTime(TimeOfDay? selected) {
    if (selected != null) {
      final openingHours = widget.field['openingHours'];
      final openingTimeString = openingHours.split(' - ')[0];
      final closingTimeString = openingHours.split(' - ')[1];
      final openingTime = _parseTimeOfDay(openingTimeString);
      final closingTime = _parseTimeOfDay(closingTimeString);

      if (_isTimeWithinRange(selected, openingTime, closingTime)) {
        setState(() {
          selectedTime = selected;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Time'),
              content: Text('Please select a time within the opening hours.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  List<TimeOfDay> getAvailableTimes(TimeOfDay startTime, TimeOfDay endTime) {
    final List<TimeOfDay> times = [];
    TimeOfDay currentTime = startTime;

    while (currentTime.hour < endTime.hour ||
        (currentTime.hour == endTime.hour &&
            currentTime.minute <= endTime.minute)) {
      times.add(currentTime);
      currentTime = _incrementTimeByOneHour(currentTime);
    }

    return times;
  }

  TimeOfDay _incrementTimeByOneHour(TimeOfDay time) {
    final hour = (time.hour + 1) % 24;
    return TimeOfDay(hour: hour, minute: time.minute);
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final format = DateFormat.jm(); // h:mm a
    final time = format.parse(timeString);
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  Widget _buildDurationRadioButton(
      DurationSelection value, String text, double durationMultiplier) {
    return RadioListTile<DurationSelection>(
      title: Text(text),
      value: value,
      groupValue: durationSelection,
      onChanged: (DurationSelection? selectedValue) {
        if (selectedValue != null) {
          setState(() {
            durationSelection = selectedValue;
            selectedDuration = durationMultiplier;
          });
        }
      },
    );
  }

  Widget _buildMatchTypeRadioButton(
      MatchType value, String text, String tooltip) {
    return MouseRegion(
      cursor: SystemMouseCursors.help,
      child: Tooltip(
        message: tooltip,
        child: RadioListTile<MatchType>(
          title: Text(text),
          value: value,
          groupValue: selectedMatchType,
          onChanged: (MatchType? selectedValue) {
            if (selectedValue != null) {
              setState(() {
                selectedMatchType = selectedValue;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double price = widget.field['price'] * selectedDuration;
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Field: ${widget.field['fieldName']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Field Name: ${widget.field['fieldName']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text('Select Date'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: DropdownButton<TimeOfDay>(
                    value: selectedTime,
                    onChanged: _selectTime,
                    items: availableTimes.map((TimeOfDay time) {
                      final timeString = time.format(context);
                      return DropdownMenuItem<TimeOfDay>(
                        value: time,
                        child: Text(timeString),
                      );
                    }).toList(),
                    menuMaxHeight:
                        200, // Set the maximum height of the dropdown menu
                    isDense: true,
                  ),
                ),
                SizedBox(width: 8),
                Text('Selected Time: ${selectedTime.format(context)}'),
              ],
            ),
            SizedBox(height: 16),
            Text('Select Duration:'),
            _buildDurationRadioButton(DurationSelection.oneHour, '1 Hour', 1),
            _buildDurationRadioButton(
                DurationSelection.oneAndHalfHours, '1.5 Hours', 1.5),
            _buildDurationRadioButton(DurationSelection.twoHours, '2 Hours', 2),
            SizedBox(height: 16),
            Text('Select Match Type:'),
            _buildMatchTypeRadioButton(MatchType.private, 'Private Match',
                'This match is private only you can see this match'),
            _buildMatchTypeRadioButton(MatchType.public, 'Public Match',
                'This match is public other users can see this match and Join!'),
            Text(
              'Field booking total price: ${price.toStringAsFixed(2)} JD',
              style: TextStyle(fontSize: 18),
            ),
            Spacer(), // Add a spacer to push the button to the bottom
            ElevatedButton(
              onPressed: () {
                String? userId = FirebaseAuth.instance.currentUser?.uid;

                // Create a new match document in the matches collection
                FirebaseFirestore.instance
                    .collection('fields/${widget.field.id}/matches')
                    .add({
                  'matchDate': DateFormat('dd MMM yyyy').format(selectedDate),
                  'fieldId': widget.field.id,
                  'userId': userId,
                  'price': price,
                  'duration': selectedDuration,
                  'startingHour': selectedTime.format(context),
                  'matchType': selectedMatchType.name,
                  'fieldImage': widget.field['fieldImages'],
                  'matchServices': widget.field['fieldServices'].toString(),
                  'matchSportType': widget.field['fieldSports'].toString(),
                  'matchHeldAt': widget.field['fieldName'],
                }).then((value) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Booking Confirmation'),
                        content: Text('Booking successful!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }).catchError((error) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Booking failed. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Booking Confirmation'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                          Text(
                              'Selected Time: ${selectedTime.format(context)}'),
                          Text(
                              'Selected Duration: ${selectedDuration.toString()} hours'),
                          Text(
                              'Match Type: ${selectedMatchType == MatchType.private ? 'Private' : 'Public'} Match'),
                          Text('Total Price: ${price.toStringAsFixed(2)} JD'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Player()),
                            );
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
