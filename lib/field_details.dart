import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'field_owner.dart';
import '../pickers/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class FieldDetails extends StatefulWidget {
  final Field field;
  FieldDetails({required this.field, Key? key}) : super(key: key);

  @override
  _FieldDetailsState createState() => _FieldDetailsState();
}

class _FieldDetailsState extends State<FieldDetails> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imagePathController;
  late TextEditingController _priceController;
  late TextEditingController _idController;
  late TextEditingController _fieldServicesContorller;
  late TextEditingController _fieldSportsContorller;

  @override
  void dispose() {
    _nameController.dispose();
    _imagePathController.dispose();
    _priceController.dispose();
    _fieldServicesContorller.dispose();
    _fieldSportsContorller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.field.fieldName);
    _imagePathController = TextEditingController(text: widget.field.imagePath);
    _priceController =
        TextEditingController(text: widget.field.price.toString());
    _idController = TextEditingController(text: widget.field.fieldId);
    // _fieldServicesContorller =
    //     TextEditingController(text: widget.field.fieldServices.join(', '));

    final List<String> fieldServices = widget.field.fieldServices;
    _fieldServicesContorller =
        TextEditingController(text: fieldServices.join(', '));

    final List<String> fieldSports = widget.field.fieldSports;
    _fieldSportsContorller =
        TextEditingController(text: fieldSports.join(', '));

    _services.forEach((service) {
      if (fieldServices.contains(service)) {
        _selectedServices.add(service);
      }
    });
    _sportsType.forEach((sportType) {
      if (fieldServices.contains(sportType)) {
        _selectedSportsType.add(sportType);
      }
    });

    super.initState();
  }

  final List<String> _services = [
    'Football',
    'Basketball',
    'Tennis ball',
    'Tennis racket',
    'Water',
    'Toilets',
    'Showers',
    'Kits',
    'Outdoor',
    'Indoor',
    'Led Lights',
  ];
  List<String> _selectedServices = [];

  final List<String> _sportsType = [
    'Football',
    'Basketball',
    'Tennis',
    'Bowling',
    'Golf',
    'Archery',
    'Baseball',
    'Rugby',
    'Volleyball',
  ];
  List<String> _selectedSportsType = [];

  Future<List<String>> getServicesFromFirestore() async {
    final servicesSnapshot = await FirebaseFirestore.instance
        .collection('fields')
        .doc(widget.field.fieldId)
        .get();

    final List<String> firestoreServices =
        List<String>.from(servicesSnapshot.data()!['fieldServices']);

    return firestoreServices;
  }

  Future<List<String>> getSportsFromFirestore() async {
    final servicesSnapshot = await FirebaseFirestore.instance
        .collection('fields')
        .doc(widget.field.fieldId)
        .get();

    final List<String> firestoreServices =
        List<String>.from(servicesSnapshot.data()!['fieldSports']);

    return firestoreServices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field.fieldName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }

                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _imagePathController,
                decoration: InputDecoration(
                  labelText: 'Image Path',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image path';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 3,
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      'Field Services',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 120, // Set a fixed height for the list view
                      child: ListView.builder(
                        itemCount: _services.length,
                        itemBuilder: (BuildContext context, int index) {
                          final service = _services[index];
                          return CheckboxListTile(
                            title: Text(service),
                            value: _selectedServices.contains(service),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value!) {
                                  _selectedServices.add(service);
                                } else {
                                  _selectedServices.remove(service);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      'Field suitable sport type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 120, // Set a fixed height for the list view
                      child: ListView.builder(
                        itemCount: _sportsType.length,
                        itemBuilder: (BuildContext context, int index) {
                          final sportType = _sportsType[index];
                          return CheckboxListTile(
                            title: Text(sportType),
                            value: _selectedSportsType.contains(sportType),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value!) {
                                  _selectedSportsType.add(sportType);
                                } else {
                                  _selectedSportsType.remove(sportType);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedField = Field(
                      fieldName: _nameController.text,
                      imagePath: _imagePathController.text,
                      fieldId: widget.field.fieldId,
                      price: double.parse(_priceController.text),
                      fieldServices: _selectedServices,
                      fieldSports: _selectedSportsType,
                    );
                    await updateFieldInFirestore(
                        widget.field.fieldId, updatedField);
                    Navigator.pop(context);
                  }
                },
                child: Text('Update Field Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> updateFieldInFirestore(String fieldId, Field newField) async {
  try {
    await FirebaseFirestore.instance.collection('fields').doc(fieldId).update({
      'fieldName': newField.fieldName,
      'price': newField.price,
      'fieldServices': newField.fieldServices,
      'fieldSports': newField.fieldSports,
    });
  } catch (error) {
    print('Error updating field: $error');
  }
}
