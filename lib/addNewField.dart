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

class FieldOwnerForm extends StatefulWidget {
  @override
  _FieldOwnerFormState createState() => _FieldOwnerFormState();
}

class UserImagePicker extends StatefulWidget {
  final Function(List<File>) imagePickFn;

  UserImagePicker(this.imagePickFn);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  List<File> _pickedImages = [];

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      imageQuality: 50,
      maxWidth: 1500,
      maxHeight: 1500,
    );
    if (pickedFiles != null) {
      setState(() {
        _pickedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
      widget.imagePickFn(_pickedImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: Icon(Icons.image),
          label: Text('Select Images'),
        ),
        SizedBox(height: 10),
        _pickedImages.isEmpty
            ? Text('No images selected.')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pickedImages.map((image) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _pickedImages.remove(image);
                            });
                            widget.imagePickFn(_pickedImages);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
      ],
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng _pickedLocation = LatLng(31.9632, 35.9306);

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pickedLocation,
          zoom: 14,
        ),
        onTap: _selectLocation,
        markers: {
          if (_pickedLocation != null)
            Marker(
              markerId: MarkerId('m1'),
              position: _pickedLocation,
            ),
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 25.0, bottom: 20.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_pickedLocation);
            },
          ),
        ),
      ),
    );
  }
}

class _FieldOwnerFormState extends State<FieldOwnerForm> {
  final _formKey = GlobalKey<FormState>();
  final _fieldNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _fieldImagesController = TextEditingController();
  final _fieldServicesController = TextEditingController();
  final _priceController = TextEditingController(text: '0');

  final _openingHoursController = TextEditingController();
  TimeOfDay _openingHoursStart = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _openingHoursEnd = TimeOfDay(hour: 20, minute: 0);

  late GoogleMapController _controller;
  LatLng _pickedLocation = LatLng(31.9632, 35.9306); // Set default value her

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FieldOwnerForm(),
      ),
    );
    if (selectedLocation != null) {
      setState(() {
        _pickedLocation = selectedLocation;
      });
    }
  }

  Future<void> _navigateToMap() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MapPage(),
      ),
    );
    // Do something with the selectedLocation
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

  List<String> _selectedServices = [];
  List<String> _selectedSportsType = [];
  List<String> _pickedImages = [];

  List<Asset> _fieldImages = <Asset>[];
  LatLng _location = LatLng(0, 0);

  Future<List<String>> _uploadImages(List<Asset> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      ByteData? byteData = await image.getByteData();
      Uint8List imageData = byteData.buffer.asUint8List();
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('fieldImages/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putData(imageData);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  @override
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
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
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
                      hintText: 'Enter Field Name ',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a field name';
                      }
                      return null;
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      final LatLng selectedLocation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(),
                        ),
                      );
                      if (selectedLocation != null) {
                        setState(() {
                          _locationController.text =
                              '${selectedLocation.latitude}, ${selectedLocation.longitude}';
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          hintText: 'Tap to select location',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      hintText: 'Enter Price Per Hour',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            child: Icon(Icons.keyboard_arrow_up),
                            onTap: () {
                              setState(() {
                                double currentValue =
                                    double.parse(_priceController.text);
                                double newValue = currentValue + 1.0;
                                _priceController.text =
                                    newValue.toStringAsFixed(2);
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            child: Icon(Icons.keyboard_arrow_down),
                            onTap: () {
                              setState(() {
                                double currentValue =
                                    double.parse(_priceController.text);
                                double newValue = currentValue - 1.0;
                                if (newValue < 0) {
                                  newValue = 0;
                                }
                                _priceController.text =
                                    newValue.toStringAsFixed(2);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (await Permission.photos.request().isGranted) {
                        List<Asset> resultList = <Asset>[];
                        try {
                          resultList = await MultiImagePicker.pickImages(
                            maxImages: 10,
                            enableCamera: true,
                            selectedAssets: resultList,
                          );
                        } on Exception catch (e) {
                          print(e);
                        }
                        setState(() {
                          _fieldImages = resultList;
                        });
                      } else {
                        // Handle the case where the user denied permission
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        SizedBox(width: 10),
                        Text('Select Images'),
                      ],
                    ),
                  ),
                  if (_fieldImages.isNotEmpty)
                    Container(
                      height: 100.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fieldImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          Asset asset = _fieldImages[index];
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100.0,
                                  height: 100.0,
                                  child: AssetThumb(
                                    asset: asset,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon:
                                        Icon(Icons.delete, color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        _fieldImages.remove(asset);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(
                    height: 10,
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
                    height: 10,
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
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Opening Hours:"),
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
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey,
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
      //choose oneVv
      // List<String> imageUrls = await _uploadImagesToStorage(fieldRef.id);
      // List<String> imageUrls = await _pickedImages();
      List<String> imageUrls = await _uploadImages(_fieldImages);

      await FirebaseFirestore.instance.collection('fields').add({
        'fieldName': _fieldNameController.text,
        'price': double.parse(_priceController.text),
        'location': _pickedLocation.toString(),
        // 'fieldImages': _fieldImagesController.text.split(','),
        'fieldImages': imageUrls,
        // 'fieldServices': _fieldServicesController.text.split(','),
        'fieldServices': _selectedServices.join(','),
        'fieldSports': _selectedSportsType.join(','),
        'openingHours':
            '${_formatTimeOfDay(_openingHoursStart)} - ${_formatTimeOfDay(_openingHoursEnd)}',
        'userId': userId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Field added successfully')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FieldOwnerApp()),
      );

      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding field')),
      );
    }
  }
}
