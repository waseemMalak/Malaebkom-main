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
  final _fieldOwnerIdController = TextEditingController();
  final _openingHoursController = TextEditingController();

  @override
  void dispose() {
    _fieldNameController.dispose();
    _locationController.dispose();
    _fieldImagesController.dispose();
    _fieldServicesController.dispose();
    _fieldOwnerIdController.dispose();
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
                TextFormField(
                  controller: _fieldServicesController,
                  decoration: InputDecoration(
                    labelText: 'Field Services',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter at least one service';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fieldOwnerIdController,
                  decoration: InputDecoration(
                    labelText: 'Field Owner ID',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a field owner ID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _openingHoursController,
                  decoration: InputDecoration(
                    labelText: 'Opening Hours',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter opening hours';
                    }
                    return null;
                  },
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

  void _addField() async {
    try {
      await FirebaseFirestore.instance.collection('fields').add({
        'fieldName': _fieldNameController.text,
        'location': _locationController.text,
        'fieldImages': _fieldImagesController.text.split(','),
        'fieldServices': _fieldServicesController.text.split(','),
        'fieldOwnerId': _fieldOwnerIdController.text,
        'openingHours': _openingHoursController.text,
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
