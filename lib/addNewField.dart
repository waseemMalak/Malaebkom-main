import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../pickers/user_image_picker.dart';

class FieldOwnerForm extends StatefulWidget {
  @override
  _FieldOwnerFormState createState() => _FieldOwnerFormState();
}

class _FieldOwnerFormState extends State<FieldOwnerForm> {
  final _formKey = GlobalKey<FormState>();
  final _fieldNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _fieldImagesController = TextEditingController();
  final _fieldServicesController = TextEditingController();

  final _openingHoursController = TextEditingController();
  TimeOfDay _openingHoursStart = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _openingHoursEnd = TimeOfDay(hour: 20, minute: 0);

  final List<String> _services = [
    'Football',
    'Water',
    'Toilets',
  ];
  String _selectedService = '';

  @override
  void initState() {
    super.initState();
    _selectedService = _services.isNotEmpty ? _services[0] : '';
  }

  void dispose() {
    _fieldNameController.dispose();
    _locationController.dispose();
    _fieldImagesController.dispose();
    _fieldServicesController.dispose();

    _openingHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Field'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _fieldNameController,
                  decoration: InputDecoration(
                    labelText: 'Field Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a field name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fieldImagesController,
                  decoration: InputDecoration(
                    labelText: 'Field Images',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter at least one image URL';
                    }
                    return null;
                  },
                ),
                // TextFormField(
                //   controller: _fieldServicesController,
                //   decoration: InputDecoration(
                //     labelText: 'Field Services',
                //   ),
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter at least one service';
                //     }
                //     return null;
                //   },
                // ),
                DropdownButtonFormField<String>(
                  value: _selectedService,
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value!;
                    });
                  },
                  items: _services
                      .map((service) => DropdownMenuItem(
                            value: service,
                            child: Text(service),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Field Services',
                  ),
                ),

                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Opening Hours"),
                    SizedBox(
                      height: 5,
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () => _selectOpeningHoursStart(context),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          'From: ${_formatTimeOfDay(_openingHoursStart)}',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectOpeningHoursEnd(context),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          'To: ${_formatTimeOfDay(_openingHoursEnd)}',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _addField();
                    }
                  },
                  child: Text('Add Field'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectOpeningHoursStart(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _openingHoursStart,
    );
    if (picked != null && picked != _openingHoursStart) {
      setState(() {
        _openingHoursStart = picked;
      });
    }
  }

  void _selectOpeningHoursEnd(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _openingHoursEnd,
    );
    if (picked != null && picked != _openingHoursEnd) {
      setState(() {
        _openingHoursEnd = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    String hour = (timeOfDay.hour % 12).toString().padLeft(2, '0');
    String minute = timeOfDay.minute.toString().padLeft(2, '0');
    String period = timeOfDay.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _addField() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference fieldRef =
          FirebaseFirestore.instance.collection('fields').doc();
      await FirebaseFirestore.instance.collection('fields').add({
        'fieldName': _fieldNameController.text,
        'location': _locationController.text,
        'fieldImages': _fieldImagesController.text.split(','),
        // 'fieldServices': _fieldServicesController.text.split(','),
        'fieldServices': _selectedService.split(','),
        'openingHours':
            '${_formatTimeOfDay(_openingHoursStart)} - ${_formatTimeOfDay(_openingHoursEnd)}',
        'userId': userId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Field added successfully')),
      );
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding field')),
      );
    }
  }
}
